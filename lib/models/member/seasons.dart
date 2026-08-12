class MemberSeasonsAndSeriesDataModel {
  MemberSeasonsAndSeriesDataModel({
    this.page,
    this.seasonsList,
    this.seriesList,
  });

  MemberSeasonsAndSeriesPage? page;
  List<MemberSeasonsList>? seasonsList;
  List<MemberSeriesList>? seriesList;

  MemberSeasonsAndSeriesDataModel.fromJson(Map<String, dynamic> json) {
    page = json['page'] != null
        ? MemberSeasonsAndSeriesPage.fromJson(json['page'])
        : null;
    seasonsList = (json['seasons_list'] as List<dynamic>?)
            ?.map((e) => MemberSeasonsList.fromJson(e))
            .toList() ??
        [];
    seriesList = (json['series_list'] as List<dynamic>?)
            ?.map((e) => MemberSeriesList.fromJson(e))
            .toList() ??
        [];
  }
}

class MemberSeasonsAndSeriesPage {
  MemberSeasonsAndSeriesPage({
    this.pageNum,
    this.pageSize,
    this.total,
  });
  int? pageNum;
  int? pageSize;
  int? total;
  MemberSeasonsAndSeriesPage.fromJson(Map<String, dynamic> json) {
    print("bbbb");
    print(json);
    pageNum = json['page_num'];
    pageSize = json['page_size'];
    total = json['total'];
  }
}

abstract class SeasonsOrSeriesList<T> {
  SeasonsOrSeriesList({
    this.archives,
    this.recentAids,
    this.aids,
    this.page,
    this.meta,
  });

  List<MemberArchiveItem>? archives;
  List<int>? recentAids;
  List<int>? aids;
  Map<String, dynamic>? page;
  T? meta; // 使用泛型 T 作为 meta 的类型
}

class MemberSeasonsList extends SeasonsOrSeriesList<SeasonMeta> {
  MemberSeasonsList({
    super.archives,
    super.recentAids,
    super.aids,
    super.page,
    super.meta,
  });
  MemberSeasonsList.fromJson(Map<String, dynamic> json) {
    archives = (json['archives'] as List<dynamic>?)
            ?.map((e) => MemberArchiveItem.fromJson(e))
            .toList() ??
        [];
    meta = json['meta'] != null ? SeasonMeta.fromJson(json['meta']) : null;
    recentAids = (json['recentAids'] as List<dynamic>?)?.cast<int>();
    aids = (json['aids'] as List<dynamic>?)?.cast<int>() ?? [];
    page = json['page'] as Map<String, dynamic>?;
  }
}

class MemberSeriesList extends SeasonsOrSeriesList<SeriesMeta> {
  MemberSeriesList({
    super.archives,
    super.recentAids,
    super.aids,
    super.page,
    super.meta,
  });
  MemberSeriesList.fromJson(Map<String, dynamic> json) {
    archives = (json['archives'] as List<dynamic>?)
            ?.map((e) => MemberArchiveItem.fromJson(e))
            .toList() ??
        [];
    meta = json['meta'] != null ? SeriesMeta.fromJson(json['meta']) : null;
    recentAids = (json['recentAids'] as List<dynamic>?)?.cast<int>() ?? [];
    aids = (json['aids'] as List<dynamic>?)?.cast<int>();
    page = json['page'] as Map<String, dynamic>?;
  }
}

class MemberArchiveItem {
  MemberArchiveItem({
    this.aid,
    this.bvid,
    this.ctime,
    this.duration,
    this.pic,
    this.cover,
    this.pubdate,
    this.view,
    this.title,
    this.state,
    this.enableVt,
    this.ugc_pay,
    this.interactiveVideo,
    this.vtDisplay,
    this.playbackPosition,
  });

  int? aid;
  String? bvid;
  int? ctime;
  int? duration;
  String? pic;
  String? cover;
  int? pubdate;
  int? view;
  String? title;
  int? state;
  dynamic enableVt;
  int? ugc_pay;
  bool? interactiveVideo;
  String? vtDisplay;
  int? playbackPosition;

  MemberArchiveItem.fromJson(Map<String, dynamic> json) {
    aid = json['aid'];
    bvid = json['bvid'];
    ctime = json['ctime'];
    duration = json['duration'];
    pic = json['pic'];
    cover = json['pic'];
    pubdate = json['pubdate'];
    view = json['stat']['view'];
    title = json['title'];
    state = json['state'];
    enableVt = json['enable_vt'];
    ugc_pay = json['ugc_pay'];
    interactiveVideo = json['interactive_video'];
    vtDisplay = json['vt_display'];
    playbackPosition = json['playback_position'];
  }
}

class SeasonMeta {
  SeasonMeta({
    this.cover,
    this.description,
    this.mid,
    this.name,
    this.ptime,
    this.seasonId,
    this.total,
  });

  String? cover;
  String? description;
  int? mid;
  String? name;
  int? ptime;
  int? seasonId;
  int? total;

  SeasonMeta.fromJson(Map<String, dynamic> json) {
    cover = json['cover'];
    description = json['description'];
    mid = json['mid'];
    name = json['name'];
    ptime = json['ptime'];
    seasonId = json['season_id'];
    total = json['total'];
  }
}

class SeriesMeta {
  SeriesMeta({
    this.cover,
    this.description,
    this.mid,
    this.name,
    this.ptime,
    this.seriesId,
    this.total,
  });

  String? cover;
  String? description;
  int? mid;
  String? name;
  int? ptime;
  int? seriesId;
  int? total;

  SeriesMeta.fromJson(Map<String, dynamic> json) {
    cover = json['cover'];
    description = json['description'];
    mid = json['mid'];
    name = json['name'];
    ptime = json['ptime'];
    seriesId = json['series_id'];
    total = json['total'];
  }
}
