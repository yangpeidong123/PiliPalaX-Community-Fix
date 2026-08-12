class ReplyPage {
  ReplyPage({
    this.num,
    this.size,
    this.count,
    this.acount,
  });

  int? num;
  int? size;
  int? count;
  int? acount;

  ReplyPage.fromJson(Map<String, dynamic> json) {
    num = json['num'];
    size = json['size'];
    count = json['count'];
    acount = json['acount'];
  }
}

class ReplyCursor {
  ReplyCursor({
    this.isBegin,
    this.prev,
    this.next,
    this.isEnd,
    this.mode,
    this.modeText,
    this.allCount,
    this.supportMode,
    this.name,
    this.paginationReply,
    this.sessionId,
  });

  bool? isBegin;
  int? prev;
  int? next;
  bool? isEnd;
  int? mode;
  String? modeText;
  int? allCount;
  List<int>? supportMode;
  String? name;
  PaginationReply? paginationReply;
  String? sessionId;

  ReplyCursor.fromJson(Map<String, dynamic> json) {
    isBegin = json['is_begin'];
    prev = json['prev'];
    next = json['next'];
    isEnd = json['is_end'];
    mode = json['mode'];
    modeText = json['mode_text'];
    allCount = json['all_count'] ?? 0;
    supportMode = json['support_mode'].cast<int>();
    name = json['name'];
    paginationReply = json['pagination_reply'] != null
        ? PaginationReply.fromJson(json['pagination_reply'])
        : null;
    sessionId = json['session_id'];
  }
}

class PaginationReply {
  PaginationReply({
    this.nextOffset,
    this.prevOffset,
  });
  String? nextOffset;
  String? prevOffset;
  PaginationReply.fromJson(Map<String, dynamic> json) {
    nextOffset = json['next_offset'];
    prevOffset = json['prev_offset'];
  }
}
