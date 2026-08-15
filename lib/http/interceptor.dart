// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:math' show pow;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

class ApiInterceptor extends Interceptor {
  ApiInterceptor(this._dio);

  final Dio _dio;

  /// 429 请求重试：最多重试 3 次，指数退避
  static const int _maxRetries = 3;

  /// 用于标记重试次数的 extra key，防止无限重试
  static const String _retryCountKey = '_retryCount';

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final String url = err.requestOptions.uri.toString();

    // 获取当前重试次数
    final int retryCount =
        err.requestOptions.extra[_retryCountKey] as int? ?? 0;

    // 屏蔽弹幕、心跳、人数请求的错误提示
    final bool isSilent = url.contains('heartbeat') ||
        url.contains('seg.so') ||
        url.contains('online/total');

    // 429 限流 / 5xx 服务端错误：静默重试，不弹 Toast
    final int? statusCode = err.response?.statusCode;
    final bool shouldRetry = retryCount < _maxRetries &&
        (statusCode == 429 ||
            (statusCode != null && statusCode >= 500 && statusCode < 600));

    if (shouldRetry) {
      // 指数退避：1s, 2s, 4s
      final int delayMs = 1000 * pow(2, retryCount).toInt();
      await Future.delayed(Duration(milliseconds: delayMs));

      try {
        // 标记重试次数，防止无限循环
        final RequestOptions newOptions = err.requestOptions.copyWith(
          extra: {
            ...err.requestOptions.extra,
            _retryCountKey: retryCount + 1,
          },
        );
        final response = await _dio.fetch(newOptions);
        handler.resolve(response);
        return;
      } on DioException catch (e) {
        // 重试后仍然失败，继续交给下一个处理器
        if (!isSilent && (e.response?.statusCode == 429 ||
            (e.response?.statusCode != null &&
                e.response!.statusCode! >= 500 &&
                e.response!.statusCode! < 600))) {
          // 如果是 429/5xx 且重试次数耗尽，显示提示
          if (retryCount + 1 >= _maxRetries && !isSilent) {
            SmartDialog.showToast(
              '请求频繁，请稍后重试',
              displayType: SmartToastType.onlyRefresh,
              displayTime: const Duration(milliseconds: 1200),
            );
          }
        }
        handler.next(e);
        return;
      }
    }

    // 其他错误弹 Toast 提示（弹幕/心跳/人数除外）
    if (!isSilent) {
      SmartDialog.showToast(
        await dioError(err) + url,
        displayType: SmartToastType.onlyRefresh,
        displayTime: const Duration(milliseconds: 1200),
      );
    }
    super.onError(err, handler);
  }

  static Future<String> dioError(DioException error) async {
    switch (error.type) {
      case DioExceptionType.badCertificate:
        return '证书有误！';
      case DioExceptionType.badResponse:
        if (error.response?.statusCode == 429) {
          return '请求过快，请稍后重试！';
        }
        return '服务器异常(${error.response?.statusCode})，请稍后重试！';
      case DioExceptionType.cancel:
        return '请求已被取消，请重新请求';
      case DioExceptionType.connectionError:
        return '连接错误，请检查网络设置';
      case DioExceptionType.connectionTimeout:
        return '网络连接超时，请检查网络设置';
      case DioExceptionType.receiveTimeout:
        return '响应超时，请稍后重试！';
      case DioExceptionType.sendTimeout:
        return '发送请求超时，请检查网络设置';
      case DioExceptionType.unknown:
        final String res = await checkConnect();
        return '$res网络异常';
      default:
        return '未知错误，请稍后重试';
    }
  }

  static Future<String> checkConnect() async {
    final List<ConnectivityResult> connectivityResults =
        await (Connectivity().checkConnectivity());

    final connectionTypes = connectivityResults
        .map((result) {
          switch (result) {
            case ConnectivityResult.mobile:
              return '流量';
            case ConnectivityResult.wifi:
              return 'Wi-Fi';
            case ConnectivityResult.ethernet:
              return '局域';
            case ConnectivityResult.vpn:
              return '代理';
            case ConnectivityResult.other:
              return '其他';
            case ConnectivityResult.none:
              return '无';
            default:
              return '';
          }
        })
        .where((type) => type.isNotEmpty)
        .toList();

    return connectionTypes.join('、');
  }
}
