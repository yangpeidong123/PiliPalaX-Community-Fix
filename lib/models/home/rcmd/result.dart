import 'package:PiliPalaX/utils/id_utils.dart';

class RecVideoItemAppModel {
  RecVideoItemAppModel({
    this.id,
    this.aid,
    this.bvid,
    this.cid,
    this.pic,
    this.stat,
    this.duration,
    this.title,
    this.isFollowed,
    this.owner,
    this.rcmdReason,
    this.goto,
    this.param,
    this.uri,
    this.talkBack,
    this.bangumiView,
    this.bangumiFollow,
    this.bangumiBadge,
    this.cardType,
    this.adInfo,
    this.dislikeReasons,
    this.desc,
  });

  int? id;
  int? aid;
  String? bvid;
  int? cid;
  String? pic;
  RcmdStat? stat;
  int? duration;
  String? title;
  int? isFollowed;
  RcmdOwner? owner;
  String? rcmdReason;
  String? goto;
  int? param;
  String? uri;
  String? talkBack;
  // 番剧
  String? bangumiView;
  String? bangumiFollow;
  String? bangumiBadge;

  String? cardType;
  Map? adInfo;
  List<DislikeReason>? dislikeReasons;
  String? desc;

  RecVideoItemAppModel.fromJson(Map<String, dynamic> json) {
    id = json['player_args'] != null
        ? json['player_args']['aid']
        : int.parse(json['param'] ?? '-1');
    aid = json['player_args'] != null ? json['player_args']['aid'] : -1;
    bvid = aid != -1 ? IdUtils.av2bv(aid!) : '';
    cid = json['player_args'] != null ? json['player_args']['cid'] : -1;
    pic = json['cover'];
    stat = RcmdStat.fromJson(json);
    // 改用player_args中的duration作为原始数据（秒数）
    duration =
        json['player_args'] != null ? json['player_args']['duration'] : -1;
    //duration = json['cover_right_text'];
    title = json['title'];
    owner = RcmdOwner.fromJson(json);
    rcmdReason = json['rcmd_reason'];
    // 由于app端api并不会直接返回与owner的关注状态
    // 所以借用推荐原因是否为“已关注”、“新关注”判别关注状态，从而与web端接口等效
    isFollowed = (rcmdReason == '已关注') || (rcmdReason == '新关注') ? 1 : 0;
    // 如果是，就无需再显示推荐原因，交由view统一处理即可
    if (isFollowed == 1) {
      rcmdReason = null;
    }
    goto = json['goto'];
    param = int.parse(json['param']);
    uri = json['uri'];
    talkBack = json['talk_back'];

    if (json['goto'] == 'bangumi') {
      bangumiView = json['cover_left_text_1'];
      bangumiFollow = json['cover_left_text_2'];
      bangumiBadge = json['cover_right_text'];
    }

    cardType = json['card_type'];
    adInfo = json['ad_info'];
    json['three_point_v2']?.forEach((v) {
      if (v['type'] == 'dislike' && v['reasons'] != null) {
        dislikeReasons = <DislikeReason>[];
        v['reasons'].forEach((vi) {
          dislikeReasons!.add(DislikeReason.fromJson(vi));
        });
      }
    });
    desc = json['desc'];
  }
}

class RcmdStat {
  RcmdStat({
    this.view,
    this.like,
    this.danmu,
  });
  String? view;
  String? like;
  String? danmu;

  RcmdStat.fromJson(Map<String, dynamic> json) {
    view = json["cover_left_text_1"];
    danmu = json['cover_left_text_2'] ?? '-';
  }
}

class RcmdOwner {
  RcmdOwner({this.name, this.mid});

  String? name;
  int? mid;

  RcmdOwner.fromJson(Map<String, dynamic> json) {
    name = json['goto'] == 'av'
        ? json['args']['up_name']
        : json['desc_button'] != null
            ? json['desc_button']['text']
            : '';
    mid = json['args']['up_id'] ?? -1;
  }
}
//
// class ThreePoint {
//   ThreePoint({
//     this.dislikeReasons,
//     this.feedbacks,
//     this.watchLater,
//   });
//
//   List<DislikeReason>? dislikeReasons;
//   List<FeedbackReason>? feedbacks;
//   int? watchLater;
//
//   ThreePoint.fromJson(Map<String, dynamic> json) {
//     if (json['dislike_reasons'] != null) {
//       dislikeReasons = [];
//       json['dislike_reasons'].forEach((v) {
//         dislikeReasons!.add(DislikeReason.fromJson(v));
//       });
//     }
//     if (json['feedbacks'] != null) {
//       feedbacks = [];
//       json['feedbacks'].forEach((v) {
//         feedbacks!.add(FeedbackReason.fromJson(v));
//       });
//     }
//     watchLater = json['watch_later'];
//   }
// }

class DislikeReason {
  DislikeReason({
    this.id,
    this.name,
    this.toast,
  });

  int? id;
  String? name;
  String? toast;

  DislikeReason.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    toast = json['toast'];
  }
}

// class FeedbackReason {
//   FeedbackReason({
//     this.id,
//     this.name,
//     this.toast,
//   });
//
//   int? id;
//   String? name;
//   String? toast;
//
//   FeedbackReason.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     name = json['name'];
//     toast = json['toast'];
//   }
// }
