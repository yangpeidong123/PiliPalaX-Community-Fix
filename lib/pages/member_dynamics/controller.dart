import 'package:get/get.dart';
import 'package:PiliPalaX/http/member.dart';
import 'package:PiliPalaX/models/dynamics/result.dart';

class MemberDynamicsController extends GetxController {
  MemberDynamicsController({required this.mid});
  final int mid;
  String offset = '';
  int count = 0;
  bool hasMore = true;
  RxList<DynamicItemModel> dynamicsList = <DynamicItemModel>[].obs;

  Future getMemberDynamic(type) async {
    if (type == 'onRefresh') {
      offset = '';
      dynamicsList.clear();
    }
    if (offset == '-1') {
      return;
    }
    var res = await MemberHttp.memberDynamic(
      offset: offset,
      mid: mid,
    );
    if (res['status']) {
      dynamicsList.addAll(res['data'].items);
      offset = res['data'].offset != '' ? res['data'].offset : '-1';
      hasMore = res['data'].hasMore;
    }
    return res;
  }

  // 上拉加载
  Future onLoad() async {
    await getMemberDynamic('onLoad');
  }

  Future onRefresh() async {
    await getMemberDynamic('onRefresh');
  }
}
