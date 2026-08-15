import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:PiliPalaX/utils/extension.dart';
import 'package:PiliPalaX/utils/global_data.dart';
import '../../utils/storage.dart';
import '../constants.dart';

Box<dynamic> setting = GStorage.setting;

class NetworkImgLayer extends StatelessWidget {
  const NetworkImgLayer({
    super.key,
    this.src,
    required this.width,
    required this.height,
    this.type,
    this.fadeOutDuration,
    this.fadeInDuration,
    // 图片质量 默认1%
    this.quality,
    this.origAspectRatio,
    this.semanticsLabel,
    this.ignoreHeight,
  });

  final String? src;
  final double width;
  final double height;
  final String? type;
  final Duration? fadeOutDuration;
  final Duration? fadeInDuration;
  final int? quality;
  final double? origAspectRatio;
  final String? semanticsLabel;
  final bool? ignoreHeight;

  @override
  Widget build(BuildContext context) {
    final int defaultImgQuality = GlobalData().adaptiveImgQuality;
    int? memCacheWidth, memCacheHeight;
    if (width > height || (origAspectRatio != null && origAspectRatio! > 1)) {
      memCacheWidth = width.cacheSize(context);
    } else if (width < height ||
        (origAspectRatio != null && origAspectRatio! < 1)) {
      memCacheHeight = height.cacheSize(context);
    } else {
      // 不能同时设置，否则会导致图片变形
      memCacheWidth = width.cacheSize(context);
      // memCacheHeight = height.cacheSize(context);
    }
    late Widget res;
    if (src?.isEmpty != false) {
      res = placeholder(context);
    } else {
      String srcUrl = src!;
      if (srcUrl.startsWith('http://')) {
        srcUrl = srcUrl.substring(5);
      }
      if (srcUrl.startsWith('//')) {
        srcUrl = 'https:$srcUrl';
      }
      // 构建图片 URL：加入 WebP 压缩 + 质量参数 + 按需裁剪
      final String processedUrl = _buildImageUrl(
        srcUrl,
        quality: quality ?? defaultImgQuality,
        width: width,
        height: height,
        type: type,
      );
      res = ClipRRect(
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.circular(
          type == 'avatar'
              ? 50
              : type == 'emote'
                  ? 0
                  : StyleString.imgRadius.x,
        ),
        child: CachedNetworkImage(
          imageUrl: processedUrl,
          width: width,
          height: ignoreHeight == null || ignoreHeight == false ? height : null,
          memCacheWidth: memCacheWidth,
          memCacheHeight: memCacheHeight,
          fit: BoxFit.cover,
          fadeOutDuration: fadeOutDuration ?? const Duration(milliseconds: 120),
          fadeInDuration: fadeInDuration ?? const Duration(milliseconds: 120),
          filterQuality: FilterQuality.low,
          // 添加 Referer 头，避免 B站 CDN 防盗链拦截
          httpHeaders: const {
            'Referer': 'https://www.bilibili.com/',
            'User-Agent':
                'Mozilla/5.0 (Linux; Android 8.0; vivo Y71A) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
          },
          errorWidget: (BuildContext context, String url, Object error) {
            // CDN 加载失败时，尝试去掉 WebP 参数使用原图
            final String fallbackUrl = url.replaceAll(RegExp(r'@\d+q\.webp.*'), '');
            if (fallbackUrl != url) {
              return CachedNetworkImage(
                imageUrl: fallbackUrl,
                width: width,
                height: ignoreHeight == null || ignoreHeight == false ? height : null,
                memCacheWidth: memCacheWidth,
                memCacheHeight: memCacheHeight,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.low,
                httpHeaders: const {
                  'Referer': 'https://www.bilibili.com/',
                },
                errorWidget: (_, __, ___) => placeholder(context),
                placeholder: (_, __) => placeholder(context),
              );
            }
            return placeholder(context);
          },
          placeholder: (BuildContext context, String url) =>
              placeholder(context),
        ),
      );
    }
    if (semanticsLabel != null) {
      return Semantics(
        label: semanticsLabel,
        child: res,
      );
    }
    return res;
  }

  /// 构建带压缩参数的图片 URL
  /// B站图床支持 WebP 格式和裁剪参数，按需裁减可节省流量
  String _buildImageUrl(
    String srcUrl, {
    required int quality,
    required double width,
    required double height,
    String? type,
  }) {
    final baseUrl = '$srcUrl@${quality}q.webp';
    // 头像/表情不添加裁剪，避免变形
    if (type == 'avatar' || type == 'emote') {
      return baseUrl;
    }
    // 非方形图片添加裁剪参数，减少传输体积
    if (width > 0 && height > 0 && width != height) {
      final int w = (width * 2).round();
      final int h = (height * 2).round();
      // 使用 B站 imageView2 裁剪模式，限制最大宽高
      return '$baseUrl&imageView2/1/w/$w/h/$h';
    }
    return baseUrl;
  }

  Widget placeholder(BuildContext context) {
    return Container(
      width: width,
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onInverseSurface.withOpacity(0.4),
        borderRadius: BorderRadius.circular(type == 'avatar'
            ? 50
            : type == 'emote'
                ? 0
                : StyleString.imgRadius.x),
      ),
      child: type == 'bg'
          ? const SizedBox()
          : Center(
              child: Image.asset(
                type == 'avatar'
                    ? 'assets/images/noface.jpeg'
                    : 'assets/images/loading.png',
                width: width,
                height: height,
                cacheWidth: width.cacheSize(context),
                cacheHeight: height.cacheSize(context),
              ),
            ),
    );
  }
}
