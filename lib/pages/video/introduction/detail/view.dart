import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:PiliPalaX/common/constants.dart';
import 'package:PiliPalaX/pages/mine/controller.dart';
import 'package:PiliPalaX/pages/video/index.dart';
import 'package:PiliPalaX/common/widgets/network_img_layer.dart';
import 'package:PiliPalaX/common/widgets/stat/danmu.dart';
import 'package:PiliPalaX/common/widgets/stat/view.dart';
import 'package:PiliPalaX/models/video_detail_res.dart';
import 'package:PiliPalaX/pages/video/introduction/detail/controller.dart';
import 'package:PiliPalaX/pages/video/widgets/ai_detail.dart';
import 'package:PiliPalaX/utils/feed_back.dart';
import 'package:PiliPalaX/utils/storage.dart';
import 'package:PiliPalaX/utils/utils.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'package:PiliPalaX/pages/video/introduction/widgets/action_item.dart';
import 'package:PiliPalaX/pages/video/introduction/widgets/action_row_item.dart';
import 'package:PiliPalaX/pages/video/introduction/widgets/fav_panel.dart';
import 'package:PiliPalaX/pages/video/introduction/widgets/intro_detail.dart';
import 'package:PiliPalaX/pages/video/introduction/widgets/page.dart';
import 'package:PiliPalaX/pages/video/introduction/widgets/season.dart';

class VideoIntroPanel extends StatefulWidget {
  const VideoIntroPanel({required this.heroTag, super.key});
  final String heroTag;

  @override
  State<VideoIntroPanel> createState() => _VideoIntroPanelState();
}

class _VideoIntroPanelState extends State<VideoIntroPanel>
    with AutomaticKeepAliveClientMixin {
  late String heroTag;
  late VideoIntroController videoIntroController;
  VideoDetailData? videoDetail;
  // late Future? _futureBuilderFuture;

  // 添加页面缓存
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    /// fix 全屏时参数丢失
    // if (Get.arguments != null) {
    //   heroTag = Get.arguments['heroTag'];
    // }
    heroTag = widget.heroTag;
    videoIntroController = Get.put(VideoIntroController(), tag: heroTag);
    // _futureBuilderFuture = videoIntroController.queryVideoIntro();
    videoIntroController.videoDetail.listen((value) {
      videoDetail = value;
    });
  }

  @override
  void dispose() {
    videoIntroController.onClose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Obx(() => videoIntroController.videoDetail.value.title == null
        ? VideoInfo(
            loadingStatus: true,
            videoDetail: videoDetail,
            heroTag: heroTag,
          )
        : VideoInfo(
            //key:herotag
            key: ValueKey(heroTag),
            loadingStatus: false,
            videoDetail: videoIntroController.videoDetail.value,
            heroTag: heroTag,
          ));
  }
}

class VideoInfo extends StatefulWidget {
  final bool loadingStatus;
  final VideoDetailData? videoDetail;
  final String? heroTag;

  const VideoInfo(
      {super.key, this.loadingStatus = false, this.videoDetail, this.heroTag});

  @override
  State<VideoInfo> createState() => _VideoInfoState();
}

class _VideoInfoState extends State<VideoInfo> with TickerProviderStateMixin {
  // final String heroTag = Get.arguments['heroTag'];
  late String heroTag;
  late final VideoIntroController videoIntroController;
  late final VideoDetailController videoDetailCtr;
  late final Map<dynamic, dynamic> videoItem;

  final Box<dynamic> setting = GStorage.setting;

  late final bool loadingStatus; // 加载状态

  late bool isExpanded;

  late int mid;
  late String memberHeroTag;
  late bool enableAi;
  late bool defaultExpandIntroduction;
  bool isProcessing = false;
  void Function()? handleState(Future Function() action) {
    return isProcessing
        ? null
        : () async {
            setState(() => isProcessing = true);
            await action();
            setState(() => isProcessing = false);
          };
  }

  @override
  void initState() {
    super.initState();
    heroTag = widget.heroTag!;
    videoIntroController = Get.put(VideoIntroController(), tag: heroTag);
    videoDetailCtr = Get.find<VideoDetailController>(tag: heroTag);
    videoItem = videoIntroController.videoItem!;

    loadingStatus = widget.loadingStatus;
    enableAi = setting.get(SettingBoxKey.enableAi, defaultValue: true);
    defaultExpandIntroduction = setting
        .get(SettingBoxKey.defaultExpandIntroduction, defaultValue: true);
    isExpanded = defaultExpandIntroduction;
  }

  // 收藏
  showFavBottomSheet({type = 'tap'}) {
    if (videoIntroController.userInfo == null) {
      SmartDialog.showToast('账号未登录');
      return;
    }
    final bool enableDragQuickFav =
        setting.get(SettingBoxKey.enableQuickFav, defaultValue: false);
    // 快速收藏 &
    // 点按 收藏至默认文件夹
    // 长按选择文件夹
    if (enableDragQuickFav) {
      if (type == 'tap') {
        videoIntroController.actionFavVideo(type: 'default');
      } else {
        showModalBottomSheet(
          context: context,
          useRootNavigator: true,
          isScrollControlled: true,
          builder: (BuildContext context) {
            return FavPanel(ctr: videoIntroController);
          },
        );
      }
    } else if (type != 'longPress') {
      showModalBottomSheet(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return FavPanel(ctr: videoIntroController);
        },
      );
    }
  }

  // 视频介绍
  // showIntroDetail() {
  //   if (loadingStatus) {
  //     return;
  //   }
  //   feedBack();
  //   showBottomSheet(
  //     context: context,
  //     enableDrag: true,
  //     builder: (BuildContext context) {
  //       return IntroDetail(videoDetail: widget.videoDetail!);
  //     },
  //   );
  // }

  // 用户主页
  onPushMember() {
    feedBack();
    mid = !loadingStatus
        ? widget.videoDetail!.owner!.mid
        : videoItem['owner'].mid;
    memberHeroTag = Utils.makeHeroTag(mid);
    String face = !loadingStatus
        ? widget.videoDetail!.owner!.face
        : videoItem['owner'].face;
    Get.toNamed('/member?mid=$mid',
        arguments: {'face': face, 'heroTag': memberHeroTag});
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    return SliverLayoutBuilder(
      builder: (BuildContext context, SliverConstraints constraints) {
        bool isHorizontal = constraints.crossAxisExtent >
            constraints.viewportMainAxisExtent * 1.25;
        return SliverPadding(
          padding: const EdgeInsets.only(
              left: StyleString.safeSpace,
              right: StyleString.safeSpace,
              top: 10),
          sliver: SliverToBoxAdapter(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(
                    child: GestureDetector(
                  onTap: onPushMember,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 1, horizontal: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        NetworkImgLayer(
                          type: 'avatar',
                          src: loadingStatus
                              ? videoItem['owner']?.face ?? ""
                              : widget.videoDetail!.owner!.face,
                          width: 30,
                          height: 30,
                          fadeInDuration: Duration.zero,
                          fadeOutDuration: Duration.zero,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loadingStatus
                                  ? videoItem['owner']?.name ?? ""
                                  : widget.videoDetail!.owner!.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 12, color: t.colorScheme.primary),
                              // semanticsLabel: "Up主：${owner.name}",
                            ),
                            const SizedBox(height: 0),
                            Obx(() => Text(
                                  Utils.numFormat(videoIntroController
                                      .userStat.value['follower']),
                                  semanticsLabel:
                                      "${Utils.numFormat(videoIntroController.userStat.value['follower'])}粉丝",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: t.colorScheme.outline,
                                  ),
                                )),
                          ],
                        )),
                        followButton(context, t),
                      ],
                    ),
                  ),
                )),
                if (isHorizontal) ...[
                  const SizedBox(width: 10),
                  Expanded(child: actionGrid(context, videoIntroController)),
                ]
              ]),
              // 合集
              if (!loadingStatus && widget.videoDetail?.ugcSeason != null) ...[
                Obx(
                  () => SeasonPanel(
                    heroTag: heroTag,
                    ugcSeason: widget.videoDetail!.ugcSeason!,
                    cid: videoIntroController.lastPlayCid.value != 0
                        ? videoIntroController.lastPlayCid.value
                        : widget.videoDetail!.pages!.first.cid,
                    changeFuc: videoIntroController.changeSeasonOrbangu,
                  ),
                ),
                const SizedBox(height: 2),
              ],
              if (!loadingStatus &&
                  widget.videoDetail?.pages != null &&
                  widget.videoDetail!.pages!.length > 1) ...[
                Obx(() => PagesPanel(
                      heroTag: heroTag,
                      pages: widget.videoDetail!.pages!,
                      cid: videoIntroController.lastPlayCid.value,
                      bvid: videoIntroController.bvid,
                      changeFuc: videoIntroController.changeSeasonOrbangu,
                    )),
                const SizedBox(height: 2),
              ],
              ListTileTheme(
                key: const PageStorageKey<String>('视频信息'),
                contentPadding: EdgeInsets.zero,
                dense: true,
                horizontalTitleGap: 0.0,
                minLeadingWidth: 0,
                minVerticalPadding: 0,
                child: ExpansionTile(
                  initiallyExpanded: isExpanded,
                  collapsedShape: const RoundedRectangleBorder(),
                  shape: const RoundedRectangleBorder(),
                  showTrailingIcon: false,
                  // trailing: Column(children: [
                  //   Icon(
                  //     isExpanded
                  //         ? Icons.keyboard_arrow_up
                  //         : Icons.keyboard_arrow_down,
                  //     color: t.colorScheme.outline,
                  //   )
                  // ]),
                  onExpansionChanged: (bool expanded) {
                    feedBack();
                    setState(() {
                      isExpanded = expanded;
                    });
                  },
                  title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onLongPress: () {
                            feedBack();
                            String title = widget.videoDetail?.title ??
                                videoItem['title'] ??
                                "";
                            Clipboard.setData(ClipboardData(text: title));
                            SmartDialog.showToast("已复制标题：「$title」到剪贴板");
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                      child: Text(
                                    widget.videoDetail?.title ??
                                        videoItem['title'] ??
                                        "",
                                    // !loadingStatus
                                    //     ? "${widget.videoDetail?.title}"
                                    //     : videoItem['title'] ?? "",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      height: 1.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: isExpanded ? 999 : 2,
                                    overflow: TextOverflow.ellipsis,
                                  )),
                                  Icon(
                                    isExpanded
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    size: 20,
                                    color: t.colorScheme.outline,
                                  )
                                ]),
                          ),
                        ),
                        Row(
                          children: <Widget>[
                            StatView(
                              theme: 'gray',
                              view: !loadingStatus
                                  ? widget.videoDetail?.stat?.view ?? '-'
                                  : videoItem['stat']?.view ?? '-',
                              size: 'medium',
                            ),
                            const SizedBox(width: 10),
                            StatDanMu(
                              theme: 'gray',
                              danmu: !loadingStatus
                                  ? widget.videoDetail?.stat?.danmu ?? '-'
                                  : videoItem['stat']?.danmu ?? '-',
                              size: 'medium',
                            ),
                            const SizedBox(width: 10),
                            Text(
                              Utils.dateFormat(
                                  !loadingStatus
                                      ? widget.videoDetail?.pubdate
                                      : videoItem['pubdate'],
                                  formatType: 'detail'),
                              style: TextStyle(
                                fontSize: 12,
                                color: t.colorScheme.outline,
                              ),
                            ),
                            if (MineController.anonymity) ...<Widget>[
                              const SizedBox(width: 10),
                              Icon(
                                MdiIcons.incognito,
                                size: 15,
                                color: t.colorScheme.outline,
                                semanticLabel: '无痕',
                              ),
                            ],
                            const SizedBox(width: 10),
                            if (videoIntroController.isShowOnlineTotal)
                              Obx(
                                () => Text(
                                  '${videoIntroController.total.value}人在看',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: t.colorScheme.outline,
                                  ),
                                ),
                              ),
                            const Spacer(),
                            const SizedBox(width: 10),
                          ],
                        ),
                      ]),
                  children: [
                    Row(children: [
                      if (widget.videoDetail != null)
                        Expanded(
                          child: IntroDetail(
                            videoDetail: widget.videoDetail,
                            enableAi: enableAi,
                            aiConclusion: videoIntroController.aiConclusion,
                          ),
                        )
                    ]),
                  ],
                ),
              ),
              Obx(
                () => videoIntroController.queryVideoIntroData.value["status"]
                    ? const SizedBox()
                    : Center(
                        child: TextButton.icon(
                          icon: const Icon(Icons.refresh),
                          onPressed: () {
                            videoIntroController
                                .queryVideoIntroData.value["status"] = true;
                            videoIntroController.queryVideoIntro();
                          },
                          label: const Text("点此重新加载"),
                        ),
                      ),
              ),
              const SizedBox(height: 8),
              // 点赞收藏转发 布局样式1
              // SingleChildScrollView(
              //   padding: const EdgeInsets.only(top: 7, bottom: 7),
              //   scrollDirection: Axis.horizontal,
              //   child: actionRow(
              //     context,
              //     videoIntroController,
              //     videoDetailCtr,
              //   ),
              // ),
              // 点赞收藏转发 布局样式2
              if (!isHorizontal) actionGrid(context, videoIntroController),
            ],
          )),
        );
      },
    );
  }

  Obx followButton(BuildContext context, ThemeData t) {
    return Obx(
      () => TextButton(
        onPressed: () => videoIntroController.actionRelationMod(context),
        style: TextButton.styleFrom(
          visualDensity: VisualDensity.compact,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          padding: const EdgeInsets.only(left: 6, right: 6),
          foregroundColor:
              (videoIntroController.followStatus['attribute'] ?? 0) != 0
                  ? t.colorScheme.outline
                  : t.colorScheme.onPrimary,
          backgroundColor:
              (videoIntroController.followStatus['attribute'] ?? 0) != 0
                  ? t.colorScheme.onInverseSurface
                  : t.colorScheme.primary, // 设置按钮背景色
        ),
        child: Text(
          ((videoIntroController.followStatus['attribute'] ?? 0) != 0)
              ? '已关注'
              : '关注',
          style: TextStyle(fontSize: t.textTheme.labelMedium!.fontSize),
        ),
      ),
    );
  }

  Widget actionGrid(BuildContext context, videoIntroController) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return Container(
        margin: const EdgeInsets.only(top: 1),
        height: 48,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Obx(
              () => ActionItem(
                  icon: const Icon(Icons.thumb_up_outlined),
                  selectIcon: const Icon(Icons.thumb_up),
                  onTap: handleState(videoIntroController.actionLikeVideo),
                  onLongPress: handleState(videoIntroController.actionOneThree),
                  selectStatus: videoIntroController.hasLike.value,
                  loadingStatus: loadingStatus,
                  semanticsLabel: '点赞',
                  text: !loadingStatus
                      ? Utils.numFormat(widget.videoDetail!.stat!.like!)
                      : '-'),
            ),
            Obx(
              () => ActionItem(
                  icon: const Icon(Icons.thumb_down_outlined),
                  selectIcon: const Icon(Icons.thumb_down),
                  onTap: handleState(videoIntroController.actionDislikeVideo),
                  selectStatus: videoIntroController.hasDislike.value,
                  loadingStatus: loadingStatus,
                  semanticsLabel: '点踩',
                  text: "点踩"),
            ),
            // ActionItem(
            //     icon: const Icon(FontAwesomeIcons.clock),
            //     onTap: () => videoIntroController.actionShareVideo(),
            //     selectStatus: false,
            //     loadingStatus: loadingStatus,
            //     text: '稍后再看'),
            Obx(
              () => ActionItem(
                  icon: const Icon(Icons.offline_bolt_outlined),
                  selectIcon: const Icon(Icons.offline_bolt),
                  onTap: handleState(videoIntroController.actionCoinVideo),
                  selectStatus: videoIntroController.hasCoin.value,
                  loadingStatus: loadingStatus,
                  semanticsLabel: '投币',
                  text: !loadingStatus
                      ? Utils.numFormat(widget.videoDetail!.stat!.coin!)
                      : '-'),
            ),
            Obx(
              () => ActionItem(
                  icon: Icon(MdiIcons.starPlusOutline),
                  selectIcon: Icon(MdiIcons.star),
                  onTap: () => showFavBottomSheet(),
                  onLongPress: () => showFavBottomSheet(type: 'longPress'),
                  selectStatus: videoIntroController.hasFav.value,
                  loadingStatus: loadingStatus,
                  semanticsLabel: '收藏',
                  text: !loadingStatus
                      ? Utils.numFormat(widget.videoDetail!.stat!.favorite!)
                      : '-'),
            ),
            ActionItem(
                icon: Icon(MdiIcons.chatOutline),
                onTap: () => videoDetailCtr.tabCtr
                    .animateTo(videoDetailCtr.tabCtr.index == 1 ? 0 : 1),
                selectStatus: false,
                loadingStatus: loadingStatus,
                semanticsLabel: '评论',
                text: !loadingStatus
                    ? Utils.numFormat(widget.videoDetail!.stat!.reply!)
                    : '评论'),
            ActionItem(
                icon: const Icon(Icons.share_outlined),
                onTap: () => videoIntroController.actionShareVideo(),
                selectStatus: false,
                loadingStatus: loadingStatus,
                semanticsLabel: '分享',
                text: !loadingStatus
                    ? Utils.numFormat(widget.videoDetail!.stat!.share!)
                    : '分享'),
          ],
        ),
      );
    });
  }

  Widget actionRow(BuildContext context, videoIntroController, videoDetailCtr) {
    return Row(children: <Widget>[
      Obx(
        () => ActionRowItem(
          icon: const Icon(FontAwesomeIcons.thumbsUp),
          onTap: handleState(videoIntroController.actionLikeVideo),
          selectStatus: videoIntroController.hasLike.value,
          loadingStatus: loadingStatus,
          text:
              !loadingStatus ? widget.videoDetail!.stat!.like!.toString() : '-',
        ),
      ),
      const SizedBox(width: 8),
      Obx(
        () => ActionRowItem(
          icon: Icon(MdiIcons.starFourPointsOutline),
          selectIcon: Icon(MdiIcons.starFourPoints),
          onTap: handleState(videoIntroController.actionCoinVideo),
          selectStatus: videoIntroController.hasCoin.value,
          loadingStatus: loadingStatus,
          text:
              !loadingStatus ? widget.videoDetail!.stat!.coin!.toString() : '-',
        ),
      ),
      const SizedBox(width: 8),
      Obx(
        () => ActionRowItem(
          icon: const Icon(FontAwesomeIcons.heart),
          onTap: () => showFavBottomSheet(),
          onLongPress: () => showFavBottomSheet(type: 'longPress'),
          selectStatus: videoIntroController.hasFav.value,
          loadingStatus: loadingStatus,
          text: !loadingStatus
              ? widget.videoDetail!.stat!.favorite!.toString()
              : '-',
        ),
      ),
      const SizedBox(width: 8),
      ActionRowItem(
        icon: const Icon(FontAwesomeIcons.comment),
        onTap: () {
          videoDetailCtr.tabCtr.animateTo(1);
        },
        selectStatus: false,
        loadingStatus: loadingStatus,
        text:
            !loadingStatus ? widget.videoDetail!.stat!.reply!.toString() : '-',
      ),
      const SizedBox(width: 8),
      ActionRowItem(
          icon: const Icon(FontAwesomeIcons.share),
          onTap: () => videoIntroController.actionShareVideo(),
          selectStatus: false,
          loadingStatus: loadingStatus,
          // text: !loadingStatus
          //     ? widget.videoDetail!.stat!.share!.toString()
          //     : '-',
          text: '转发'),
    ]);
  }
}
