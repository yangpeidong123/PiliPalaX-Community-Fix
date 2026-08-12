import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:PiliPalaX/http/member.dart';
import 'package:PiliPalaX/models/member/seasons.dart';

class MemberSeasonController extends GetxController {
  final ScrollController scrollController = ScrollController();
  late int mid;
  late int seasonId;
  int pn = 1;
  int ps = 30;
  int count = 0;
  Rx<SeasonMeta> meta = SeasonMeta(name: "Ta的合集", total: 0).obs;
  RxList<MemberArchiveItem> seasonsList = <MemberArchiveItem>[].obs;
  late Map page;

  @override
  void onInit() {
    super.onInit();
    mid = int.parse(Get.parameters['mid']!);
    seasonId = int.parse(Get.parameters['seasonId']!);
  }

  // 获取合集详情
  Future getSeasonDetail(type) async {
    if (type == 'onRefresh') {
      pn = 1;
    }
    var res = await MemberHttp.getSeasonDetail(
      mid: mid,
      seasonId: seasonId,
      pn: pn,
      ps: ps,
      sortReverse: false,
    );
    if (res['status']) {
      seasonsList.addAll(res['data'].archives);
      page = res['data'].page;
      pn += 1;
      meta.value = res['data'].meta;
    }
    return res;
  }

  // 上拉加载
  Future onLoad() async {
    getSeasonDetail('onLoad');
  }

  Future onRefresh() async {
    getSeasonDetail('onRefresh');
  }
}
