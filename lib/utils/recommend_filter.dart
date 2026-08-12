// import 'dart:math';

import 'storage.dart';

class RecommendFilter {
  // static late int filterUnfollowedRatio;
  static late int minDurationForRcmd;
  static late int minLikeRatioForRecommend;
  static late bool exemptFilterForFollowed;
  static late bool applyFilterToRelatedVideos;
  static late bool disableRelatedVideos;
  static late List<String> banWordList;

  RecommendFilter() {
    update();
  }

  static void update() {
    var setting = GStorage.setting;
    // filterUnfollowedRatio =
    //     setting.get(SettingBoxKey.filterUnfollowedRatio, defaultValue: 0);
    minDurationForRcmd =
        setting.get(SettingBoxKey.minDurationForRcmd, defaultValue: 0);
    minLikeRatioForRecommend =
        setting.get(SettingBoxKey.minLikeRatioForRecommend, defaultValue: 0);
    banWordList = (setting.get(SettingBoxKey.banWordForRecommend,
            defaultValue: '') as String)
        .split(' ');
    exemptFilterForFollowed =
        setting.get(SettingBoxKey.exemptFilterForFollowed, defaultValue: true);
    applyFilterToRelatedVideos = setting
        .get(SettingBoxKey.applyFilterToRelatedVideos, defaultValue: true);

    disableRelatedVideos =
        setting.get(SettingBoxKey.disableRelatedVideos, defaultValue: false);
  }

  static bool filter(dynamic videoItem, {bool relatedVideos = false}) {
    if (relatedVideos && !applyFilterToRelatedVideos) {
      return false;
    }
    //由于相关视频中没有已关注标签，只能视为非关注视频
    if (!relatedVideos &&
        videoItem.isFollowed == 1 &&
        exemptFilterForFollowed) {
      return false;
    }
    if (videoItem.duration > 0 && videoItem.duration < minDurationForRcmd) {
      return true;
    }
    if (videoItem.stat.view is int &&
        videoItem.stat.view > -1 &&
        videoItem.stat.like is int &&
        videoItem.stat.like > -1 &&
        videoItem.stat.like * 100 <
            minLikeRatioForRecommend * videoItem.stat.view) {
      return true;
    }
    for (var word in banWordList) {
      if (word.isNotEmpty && videoItem.title.contains(word)) return true;
    }
    return false;
  }
}
