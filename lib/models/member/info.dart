class MemberInfoModel {
  MemberInfoModel({
    this.card,
    this.liveRoom,
  });

  Card? card;
  LiveRoom? liveRoom;

  MemberInfoModel.fromJson(Map<String, dynamic> json) {
    card = json['card'] != null ? Card.fromJson(json['card']) : null;
    liveRoom = json['live'] != null ? LiveRoom.fromJson(json['live']) : null;
  }
}

class Card {
  Card(
      {this.mid,
      this.name,
      this.face,
      this.sign,
      this.level,
      this.isFollow,
      this.isFollowed,
      this.relationStatus,
      this.officialVerify,
      this.professionVerify,
      this.vip,
      this.fans,
      this.attention,
      this.likes
      // this.liveRoom,
      });

  String? mid;
  String? name;
  String? face;
  String? sign;
  int? level;
  bool? isFollow;
  bool? isFollowed;
  int? relationStatus;
  Map? officialVerify;
  Map? professionVerify;
  Vip? vip;
  int? fans;
  int? attention;
  int? likes;
  // LiveRoom? liveRoom;

  Card.fromJson(Map<String, dynamic> json) {
    mid = json['mid'];
    name = json['name'];
    face = json['face'];
    sign = json['sign'] == '' ? '该用户还没有签名' : json['sign'].replaceAll('\n', '');
    level = json['level_info']?['level'] ?? 0;

    isFollow = json['relation']?['is_follow'] == 1;
    isFollowed = json['relation']?['is_followed'] == 1;
    relationStatus = json['relation']?['status'] ?? 0;
    officialVerify = json['official_verify'];
    professionVerify = json['profession_verify'];
    vip = Vip.fromJson(json['vip']);

    fans = json['fans'];
    attention = json['attention'];
    likes = json['likes']?['like_num'];
    // liveRoom =
    //     json['live_room'] != null ? LiveRoom.fromJson(json['live_room']) : null;
  }
}

class Vip {
  Vip({
    this.type,
    this.status,
    this.dueDate,
    this.label,
  });

  int? type;
  int? status;
  int? dueDate;
  Map? label;

  Vip.fromJson(Map<String, dynamic> json) {
    type = json['vipType'];
    status = json['vipStatus'];
    dueDate = json['vipDueDate'];
    label = json['label'];
  }
}

class LiveRoom {
  LiveRoom({
    this.roomStatus,
    this.liveStatus,
    this.url,
    this.title,
    this.cover,
    this.roomId,
    this.roundStatus,
  });

  int? roomStatus;
  int? liveStatus;
  String? url;
  String? title;
  String? cover;
  int? roomId;
  int? roundStatus;

  LiveRoom.fromJson(Map<String, dynamic> json) {
    roomStatus = json['roomStatus'];
    liveStatus = json['liveStatus'];
    url = json['url'];
    title = json['title'];
    cover = json['cover'];
    roomId = json['roomid'];
    roundStatus = json['roundStatus'];
  }
}
