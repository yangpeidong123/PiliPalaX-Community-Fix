import 'package:PiliPalaX/models/video/reply/item.dart';

import 'config.dart';
import 'page.dart';
import 'upper.dart';

class ReplyData {
  ReplyData({
    this.cursor,
    this.config,
    this.replies,
    this.topReplies,
    this.upper,
  });

  ReplyCursor? cursor;
  ReplyConfig? config;
  late List<ReplyItemModel>? replies;
  late List<ReplyItemModel>? topReplies;
  ReplyUpper? upper;

  ReplyData.fromJson(Map<String, dynamic> json) {
    cursor = ReplyCursor.fromJson(json['cursor']);
    config = ReplyConfig.fromJson(json['config']);
    replies = json['replies'] != null
        ? List<ReplyItemModel>.from(json['replies']
            .map<ReplyItemModel>(
                (item) => ReplyItemModel.fromJson(item, json['upper']['mid'])))
        : <ReplyItemModel>[];
    topReplies = json['top_replies'] != null
        ? List<ReplyItemModel>.from(json['top_replies']
            .map<ReplyItemModel>((item) => ReplyItemModel.fromJson(
                item, json['upper']['mid'],
                isTopStatus: true)))
        : <ReplyItemModel>[];
    upper = ReplyUpper.fromJson(json['upper']);
  }
}

class ReplyReplyData {
  ReplyReplyData({
    this.page,
    this.config,
    this.replies,
    this.topReplies,
    this.upper,
    this.root,
  });

  ReplyPage? page;
  ReplyConfig? config;
  late List<ReplyItemModel>? replies;
  late List<ReplyItemModel>? topReplies;
  ReplyUpper? upper;
  ReplyItemModel? root;

  ReplyReplyData.fromJson(Map<String, dynamic> json) {
    page = ReplyPage.fromJson(json['page']);
    config = ReplyConfig.fromJson(json['config']);
    replies = json['replies'] != null
        ? List<ReplyItemModel>.from(json['replies']
        .map<ReplyItemModel>(
            (item) => ReplyItemModel.fromJson(item, json['upper']['mid'])))
        : <ReplyItemModel>[];
    topReplies = json['top_replies'] != null
        ? List<ReplyItemModel>.from(json['top_replies']
        .map<ReplyItemModel>((item) => ReplyItemModel.fromJson(
        item, json['upper']['mid'],
        isTopStatus: true)))
        : <ReplyItemModel>[];
    upper = ReplyUpper.fromJson(json['upper']);
    root = ReplyItemModel.fromJson(json['root'], json['upper']['mid']);
  }
}
