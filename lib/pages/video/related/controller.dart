import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:PiliPalaX/http/video.dart';
import '../../../../models/model_hot_video_item.dart';

class RelatedController extends GetxController {
  // 视频aid
  String bvid = Get.parameters['bvid'] ?? "";
  // 推荐视频列表
  RxList relatedVideoList = <HotVideoItemModel>[].obs;

  Future<dynamic> queryRelatedVideo() async {
    return VideoHttp.relatedVideoList(bvid: bvid).then((value) {
      if (value['status']) {
        relatedVideoList.value = value['data'];
      } else {
        SmartDialog.showToast(value['msg']);
      }
      return value;
    });
  }
}
