// ignore_for_file: avoid_print

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

class ApiInterceptor extends Interceptor {
  // @override
  // void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
  //   print("请求之前");
  //   // 在请求之前添加头部或认证信息
  //   options.headers['Authorization'] = 'Bearer token';
  //   options.headers['Content-Type'] = 'application/json';
  //   handler.next(options);
  // }

  // @override
  // void onResponse(Response response, ResponseInterceptorHandler handler) {
  //   try {
  //     if (response.statusCode == 302) {
  //       final List<String> locations = response.headers['location']!;
  //       if (locations.isNotEmpty) {
  //         if (locations.first.startsWith('https://www.mcbbs.net')) {
  //           print('ApiInterceptor@@@@@: ${locations.first}');
  //           final Uri uri = Uri.parse(locations.first);
  //           final String? accessKey = uri.queryParameters['access_key'];
  //           final String? mid = uri.queryParameters['mid'];
  //           try {
  //             Box localCache = GStorage.localCache;
  //             localCache.put(LocalCacheKey.accessKey,
  //                 <String, String?>{'mid': mid, 'value': accessKey});
  //           } catch (_) {}
  //         }
  //       }
  //     }
  //   } catch (err) {
  //     print('ApiInterceptor: $err');
  //   }

  //   handler.next(response);
  // }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // 处理网络请求错误
    // handler.next(err);
    String url = err.requestOptions.uri.toString();
    print('🌹🌹ApiInterceptor: $url');
    // 屏蔽弹幕、心跳、人数请求的错误提示
    if (!url.contains('heartbeat') &&
        !url.contains('seg.so') &&
        !url.contains('online/total')) {
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
        return '服务器异常，请稍后重试！';
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
        return '$res网络异常 ${error.error}';
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
