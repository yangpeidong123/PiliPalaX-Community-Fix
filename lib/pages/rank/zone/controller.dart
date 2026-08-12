import 'package:PiliPalaX/utils/extension.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:PiliPalaX/http/video.dart';
import 'package:PiliPalaX/models/model_hot_video_item.dart';

class ZoneController extends GetxController {
  final ScrollController scrollController = ScrollController();
  RxList<HotVideoItemModel> videoList = <HotVideoItemModel>[].obs;
  bool isLoadingMore = false;
  bool flag = false;
  int? rid;
  int? tid;

  // 获取推荐
  Future queryRankFeed(String type, int? rid, int? tid) async {
    print('queryRankFeed: $type, $rid, $tid');
    this.rid = rid;
    this.tid = tid;
    late dynamic res;
    if (rid != null) {
      res = await VideoHttp.getRankVideoList(rid);
    } else {
      res = await VideoHttp.getRegionVideoList(tid!, 1, 50);
    }
    if (res['status']) {
      if (type == 'init') {
        videoList.value = res['data'];
      } else if (type == 'onRefresh') {
        videoList.clear();
        videoList.addAll(res['data']);
      } else if (type == 'onLoad') {
        videoList.clear();
        videoList.addAll(res['data']);
      }
    }
    isLoadingMore = false;
    return res;
  }

  // 下拉刷新
  Future onRefresh() async {
    queryRankFeed('onRefresh', rid, tid);
  }

  // 上拉加载
  Future onLoad() async {
    queryRankFeed('onLoad', rid, tid);
  }

  // 返回顶部并刷新
  void animateToTop() {
    scrollController.animToTop();
  }
}
