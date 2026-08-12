import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../http/user.dart';
import '../../utils/download.dart';
import '../constants.dart';
import 'network_img_layer.dart';

class OverlayPop extends StatelessWidget {
  const OverlayPop({super.key, this.videoItem});

  final dynamic videoItem;

  @override
  Widget build(BuildContext context) {
    final double imgWidth = min(Get.height, Get.width) - 8 * 2;
    print('videoItem.title: ${videoItem.title}');
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      width: imgWidth,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Stack(
            children: [
              NetworkImgLayer(
                width: imgWidth,
                height: imgWidth / StyleString.aspectRatio,
                src: (videoItem.runtimeType.toString() == "DynamicArchiveModel")
                    ? videoItem.cover ?? ''
                    : videoItem.pic ?? videoItem.cover ?? '',
                quality: 100,
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(20))),
                  child: IconButton(
                    tooltip: '关闭',
                    style: ButtonStyle(
                      padding: WidgetStateProperty.all(EdgeInsets.zero),
                    ),
                    onPressed: Get.back,
                    icon: const Icon(
                      Icons.close,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
            child: Row(
              children: [
                if (videoItem.title is String)
                  Expanded(
                    child: SelectableText(
                      videoItem.title ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize:
                            Theme.of(context).textTheme.bodyMedium!.fontSize,
                        height: 1.42,
                        letterSpacing: 0.3,
                      ),
                      // overflow: TextOverflow.ellipsis,
                    ),
                  )
                else
                  Expanded(
                    child: RichText(
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      text: TextSpan(
                        children: [
                          for (final i in videoItem.title) ...[
                            TextSpan(
                              text: i['text'] as String,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .fontSize,
                                letterSpacing: 0.3,
                                color: i['type'] == 'em'
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ]
                        ],
                      ),
                    ),
                  ),
                if (videoItem.runtimeType.toString() != 'LiveItemModel')
                  SizedBox(
                    width: 30,
                    child: IconButton(
                      tooltip: '稍后再看',
                      icon: Icon(MdiIcons.clockTimeEightOutline, size: 20),
                      onPressed: () async {
                        var res = await UserHttp.toViewLater(
                            bvid: videoItem.bvid as String);
                        SmartDialog.showToast(res['msg']);
                      },
                    ),
                  ),
                const SizedBox(width: 4),
                SizedBox(
                    width: 30,
                    child: IconButton(
                      tooltip: '保存封面图',
                      onPressed: () async {
                        await DownloadUtils.downloadImg(
                          context,
                          videoItem.pic ?? videoItem.cover ?? '',
                        );
                        // closeFn!();
                      },
                      icon: const Icon(Icons.download_outlined, size: 20),
                    ))
              ],
            ),
          ),
        ],
      ),
    );
  }
}
