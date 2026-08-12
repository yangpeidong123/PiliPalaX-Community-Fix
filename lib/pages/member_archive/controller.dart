import 'package:PiliPalaX/utils/app_scheme.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:PiliPalaX/http/member.dart';
import 'package:PiliPalaX/models/member/archive.dart';

class MemberArchiveController extends GetxController {
  MemberArchiveController({required this.mid});
  final int mid;
  int pn = 1;
  int count = 0;
  String episodicButtonText = "播放全部";
  String episodicButtonUri = "";
  RxMap<String, String> currentOrder = <String, String>{}.obs;
  List<Map<String, String>> orderList = [
    {'type': 'pubdate', 'label': '最新发布'},
    {'type': 'click', 'label': '最多播放'},
    {'type': 'stow', 'label': '最多收藏'},
  ];
  RxList<VListItemModel> archivesList = <VListItemModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    currentOrder.value = orderList.first;
  }

  // 获取用户投稿
  Future getMemberArchive(type) async {
    if (type == 'init' || type == 'refresh') {
      pn = 1;
    }
    if (type == 'refresh') {
      archivesList.clear();
    }
    var res = await MemberHttp.memberArchive(
      mid: mid,
      pn: pn,
      order: currentOrder['type']!,
    );
    if (res['status']) {
      episodicButtonText = res['data'].episodicButton?.text ?? "";
      episodicButtonUri = res['data'].episodicButton?.uri ?? "";
      if (type == 'init' || type == 'refresh') {
        archivesList.value = res['data'].list.vlist;
      }
      if (type == 'onLoad') {
        archivesList.addAll(res['data'].list.vlist);
      }
      count = res['data'].page['count'];
      pn += 1;
    } else {
      SmartDialog.showToast(res['msg']);
    }
    return res;
  }

  toggleSort() async {
    List<String> typeList = orderList.map((e) => e['type']!).toList();
    int index = typeList.indexOf(currentOrder['type']!);
    if (index == orderList.length - 1) {
      currentOrder.value = orderList.first;
    } else {
      currentOrder.value = orderList[index + 1];
    }
    getMemberArchive('init');
  }

  episodicButton() async {
    if (episodicButtonUri.isNotEmpty) {
      PiliScheme.routePush(Uri.parse('https:$episodicButtonUri'));
    } else {
      SmartDialog.showToast('暂无播放链接');
    }
  }

  // 上拉加载
  Future onLoad() async {
    await getMemberArchive('onLoad');
  }

  Future onRefresh() async {
    await getMemberArchive('refresh');
  }
}
