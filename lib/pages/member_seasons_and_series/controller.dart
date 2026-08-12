import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:PiliPalaX/http/member.dart';
import 'package:PiliPalaX/models/member/seasons.dart';

class MemberSeasonsAndSeriesController extends GetxController {
  MemberSeasonsAndSeriesController({required this.mid});
  final int mid;
  int pn = 1;
  int ps = 20;
  int total = 0;
  int currentTotal = 0;
  RxList<MemberSeasonsList> seasonsList = <MemberSeasonsList>[].obs;
  RxList<MemberSeriesList> seriesList = <MemberSeriesList>[].obs;
  late Map page;

  // @override
  // void onInit() {
  //   super.onInit();
  // }

  // 请求专栏
  Future getMemberSeasonsAndSeries(String type) async {
    var res = await MemberHttp.getMemberSeasonsAndSeries(mid, pn, ps);
    if (!res['status']) {
      SmartDialog.showToast("用户专栏请求异常：${res['msg']}");
    } else {
      if (res['data'].seasonsList.isNotEmpty) {
        seasonsList.addAll(res['data'].seasonsList);
      }
      if (res['data'].seriesList.isNotEmpty) {
        seriesList.addAll(res['data'].seriesList);
      }
      if (res['data'].page?.total != null && res['data'].page!.total! > 0) {
        total = res['data'].page!.total!;
        print("getMemberSeasonsAndSeries total: $total");
      }
      currentTotal = seasonsList.length + seriesList.length;
    }
    return res;
  }

  // 上拉加载
  Future onLoad() async {
    if (currentTotal >= total) return;
    pn += 1;
    return await getMemberSeasonsAndSeries('onLoad');
  }

  Future onRefresh() async {
    pn = 1;
    seasonsList.clear();
    seriesList.clear();
    currentTotal = 0;
    return await getMemberSeasonsAndSeries('onRefresh');
  }
}
