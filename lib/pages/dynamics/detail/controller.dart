import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:PiliPalaX/http/html.dart';
import 'package:PiliPalaX/http/reply.dart';
import 'package:PiliPalaX/models/common/reply_sort_type.dart';
import 'package:PiliPalaX/models/video/reply/item.dart';
import 'package:PiliPalaX/utils/feed_back.dart';
import 'package:PiliPalaX/utils/storage.dart';

class DynamicDetailController extends GetxController {
  DynamicDetailController(this.oid, this.type);
  int? oid;
  int? type;
  dynamic item;
  int? floor;
  String nextOffset = "";
  bool isLoadingMore = false;
  RxString noMore = ''.obs;
  RxList<ReplyItemModel> replyList = <ReplyItemModel>[].obs;
  RxInt acount = 0.obs;
  final ScrollController scrollController = ScrollController();

  ReplySortType _sortType = ReplySortType.time;
  RxString sortTypeTitle = ReplySortType.time.titles.obs;
  RxString sortTypeLabel = ReplySortType.time.labels.obs;
  Box setting = GStorage.setting;

  @override
  void onInit() {
    super.onInit();
    item = Get.arguments['item'];
    floor = Get.arguments['floor'];
    if (floor == 1) {
      acount.value =
          int.parse(item!.modules!.moduleStat!.comment!.count ?? '0');
    }
    int defaultReplySortIndex =
        setting.get(SettingBoxKey.replySortType, defaultValue: 0);
    if (defaultReplySortIndex == 2) {
      setting.put(SettingBoxKey.replySortType, 0);
      defaultReplySortIndex = 0;
    }
    _sortType = ReplySortType.values[defaultReplySortIndex];
    sortTypeTitle.value = _sortType.titles;
    sortTypeLabel.value = _sortType.labels;
  }

  Future queryReplyList({reqType = 'init'}) async {
    if (reqType == 'init') {
      nextOffset = "";
      noMore.value = "";
    }
    if (isLoadingMore) return;
    if (noMore.value == '没有更多了') return;
    isLoadingMore = true;
    var res = await ReplyHttp.replyList(
      oid: oid!,
      nextOffset: nextOffset,
      type: type!,
      sort: _sortType.index,
    );
    isLoadingMore = false;
    if (res['status']) {
      List<ReplyItemModel> replies = res['data'].replies;
      acount.value = res['data'].cursor.allCount ?? 0;
      nextOffset = res['data'].cursor.paginationReply.nextOffset ?? "";
      if (replies.isNotEmpty) {
        noMore.value = '加载中...';
        if (res['data'].cursor.isEnd == true) {
          noMore.value = '没有更多了';
        }
      } else {
        noMore.value =
            nextOffset == "" && reqType == 'init' ? '还没有评论' : '没有更多了';
      }
      if (reqType == 'init') {
        // 添加置顶回复
        if (res['data'].upper.top != null) {
          bool flag = res['data']
              .topReplies
              .any((reply) => reply.rpid == res['data'].upper.top.rpid);
          if (!flag) {
            replies.insert(0, res['data'].upper.top);
          }
        }
        replies.insertAll(0, res['data'].topReplies);
        replyList.value = replies;
      } else {
        replyList.addAll(replies);
      }
    } else {
      SmartDialog.showToast(res['msg']);
    }
    return res;
  }

  // 排序搜索评论
  queryBySort() {
    feedBack();
    switch (_sortType) {
      case ReplySortType.time:
        _sortType = ReplySortType.like;
        break;
      case ReplySortType.like:
        _sortType = ReplySortType.time;
        break;
      default:
    }
    sortTypeTitle.value = _sortType.titles;
    sortTypeLabel.value = _sortType.labels;
    replyList.clear();
    queryReplyList(reqType: 'init');
  }

  // 根据jumpUrl获取动态html
  reqHtmlByOpusId(int id) async {
    var res = await HtmlHttp.reqHtml(id, 'opus');
    oid = res['commentId'];
  }
}
