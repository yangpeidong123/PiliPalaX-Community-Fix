import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:PiliPalaX/http/member.dart';
import 'package:PiliPalaX/models/member/seasons.dart';

class MemberSeriesController extends GetxController {
  final ScrollController scrollController = ScrollController();
  late int mid;
  late int seriesId;
  int pn = 1;
  int ps = 30;
  int count = 0;
  // Rx<SeriesMeta?> meta = SeriesMeta(name: "Ta的视频列表", total: 0).obs;
  RxList<MemberArchiveItem> seriesList = <MemberArchiveItem>[].obs;
  Rx<Map<String, dynamic>?> page = Rx<Map<String, dynamic>>({"total": 0});

  @override
  void onInit() {
    super.onInit();
    mid = int.parse(Get.parameters['mid']!);
    seriesId = int.parse(Get.parameters['seriesId']!);
  }

  // 获取视频列表详情
  Future getSeriesDetail(type) async {
    if (type == 'onRefresh') {
      pn = 1;
    }
    var res = await MemberHttp.getSeriesDetail(
      mid: mid,
      seriesId: seriesId,
      pn: pn,
      ps: ps,
      sortReverse: false,
    );
    if (res['status']) {
      seriesList.addAll(res['data'].archives);
      page.value = res['data'].page;
      pn += 1;
      // meta.value = res['data'].meta;
    }
    return res;
  }

  // 上拉加载
  Future onLoad() async {
    await getSeriesDetail('onLoad');
  }

  Future onRefresh() async {
    await getSeriesDetail('onRefresh');
  }
}
