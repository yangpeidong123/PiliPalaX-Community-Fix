import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/home/rcmd/result.dart';
import '../../models/model_rec_video_item.dart';
import 'my_dialog.dart';
import 'overlay_pop.dart';
import 'stat/danmu.dart';
import 'stat/view.dart';
import '../../http/dynamics.dart';
import '../../http/search.dart';
import '../../models/common/search_type.dart';
import '../../utils/id_utils.dart';
import '../../utils/utils.dart';
import '../constants.dart';
import 'badge.dart';
import 'network_img_layer.dart';
import 'pressable.dart';
import 'video_popup_menu.dart';

// 视频卡片 - 垂直布局
class VideoCardV extends StatelessWidget {
  final dynamic videoItem;
  // final Function()? longPress;
  // final Function()? longPressEnd;

  const VideoCardV({
    super.key,
    required this.videoItem,
    // this.longPress,
    // this.longPressEnd,
  });

  bool isStringNumeric(String str) {
    RegExp numericRegex = RegExp(r'^\d+$');
    return numericRegex.hasMatch(str);
  }

  void onPushDetail(heroTag) async {
    String goto = videoItem.goto;
    debugPrint("goto $goto");
    switch (goto) {
      case 'bangumi':
        if (videoItem.bangumiBadge == '电影') {
          SmartDialog.showToast('暂不支持电影观看');
          return;
        }
        int epId = videoItem.param;
        SmartDialog.showLoading(msg: '资源获取中');
        var result = await SearchHttp.bangumiInfo(seasonId: null, epId: epId);
        SmartDialog.dismiss();
        if (result['status']) {
          var bangumiDetail = result['data'];
          int cid = bangumiDetail.episodes!.first.cid;
          String bvid = IdUtils.av2bv(bangumiDetail.episodes!.first.aid);
          Get.toNamed(
            '/video?bvid=$bvid&cid=$cid&epId=$epId',
            arguments: {
              'pic': videoItem.pic,
              'heroTag': heroTag,
              'videoType': SearchType.media_bangumi,
            },
          );
        } else {
          SmartDialog.showToast(result['msg']);
        }
        break;
      case 'av':
        debugPrint("currentRoute: ${Get.currentRoute}");
        String bvid = videoItem.bvid ?? IdUtils.av2bv(videoItem.aid);
        Get.toNamed(
          '/video?bvid=$bvid&cid=${videoItem.cid}',
          arguments: {
            // 'videoItem': videoItem,
            'pic': videoItem.pic,
            'heroTag': heroTag,
          },
          // preventDuplicates: false,
        );
        break;
      // 动态
      case 'picture':
        try {
          String dynamicType = 'picture';
          String uri = videoItem.uri;
          String id = '';
          if (videoItem.uri.startsWith('bilibili://article/')) {
            // https://www.bilibili.com/read/cv27063554
            dynamicType = 'read';
            RegExp regex = RegExp(r'\d+');
            Match match = regex.firstMatch(videoItem.uri)!;
            String matchedNumber = match.group(0)!;
            videoItem.param = int.parse(matchedNumber);
            id = 'cv${videoItem.param}';
          }
          if (uri.startsWith('http')) {
            String path = Uri.parse(uri).path;
            if (isStringNumeric(path.split('/')[1])) {
              // 请求接口
              var res =
                  await DynamicsHttp.dynamicDetail(id: path.split('/')[1]);
              if (res['status']) {
                Get.toNamed('/dynamicDetail', arguments: {
                  'item': res['data'],
                  'floor': 1,
                  'action': 'detail'
                });
              } else {
                SmartDialog.showToast(res['msg']);
              }
              return;
            }
          }
          Get.toNamed('/htmlRender', parameters: {
            'url': uri,
            'title': videoItem.title,
            'id': id,
            'dynamicType': dynamicType
          });
        } catch (err) {
          SmartDialog.showToast(err.toString());
        }
        break;
      default:
        SmartDialog.showToast(videoItem.goto);
        Get.toNamed(
          '/webview',
          parameters: {
            'url': videoItem.uri,
            'type': 'url',
            'pageTitle': videoItem.title,
          },
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    String heroTag = Utils.makeHeroTag(videoItem.id);
    List<VideoCustomAction> actions =
        VideoCustomActions(videoItem, context).actions;
    return RepaintBoundary(child: Stack(children: [
      Semantics(
        label: Utils.videoItemSemantics(videoItem),
        excludeSemantics: true,
        customSemanticsActions: <CustomSemanticsAction, void Function()>{
          for (var item in actions)
            CustomSemanticsAction(label: item.title): item.onTap!,
        },
        child: Card(
          color: Theme.of(context).colorScheme.surface.withOpacity(0.4),
          elevation: 0,
          clipBehavior: Clip.hardEdge,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: StyleString.mdRadius,
          ),
          child: GestureDetector(
            onLongPress: () {
              // longPress!();
            },
            child: Pressable(
              onTap: () async => onPushDetail(heroTag),
              borderRadius: StyleString.mdRadius,
              child: Column(
                children: [
                  AspectRatio(
                    aspectRatio: StyleString.aspectRatio,
                    child: LayoutBuilder(builder: (context, boxConstraints) {
                      double maxWidth = boxConstraints.maxWidth;
                      double maxHeight = boxConstraints.maxHeight;
                      // print('heroTagV: $heroTag');
                      return Stack(
                        children: [
                          GestureDetector(
                            onLongPress: () {
                              // 弹窗显示封面
                              MyDialog.show(
                                  context, OverlayPop(videoItem: videoItem));
                            },
                            behavior: HitTestBehavior.translucent,
                            child: Hero(
                              tag: heroTag,
                              // 封面沿弧线路径滑向播放器，形成"滑动到播放位置"的连贯效果
                              createRectTween: (Rect? begin, Rect? end) {
                                return MaterialRectCenterArcTween(
                                  begin: begin,
                                  end: end,
                                );
                              },
                              flightShuttleBuilder: (
                                BuildContext flightContext,
                                Animation<double> animation,
                                HeroFlightDirection flightDirection,
                                BuildContext fromHeroContext,
                                BuildContext toHeroContext,
                              ) {
                                return Material(
                                  type: MaterialType.transparency,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.zero,
                                    child: CachedNetworkImage(
                                      imageUrl: videoItem.pic,
                                      fit: BoxFit.cover,
                                      fadeOutDuration: const Duration(milliseconds: 120),
                                      fadeInDuration: const Duration(milliseconds: 120),
                                    ),
                                  ),
                                );
                              },
                              child: NetworkImgLayer(
                                src: videoItem.pic,
                                width: maxWidth,
                                height: maxHeight,
                              ),
                            ),
                          ),
                          if (videoItem.duration > 0)
                            PBadge(
                              bottom: 6,
                              right: 7,
                              size: 'small',
                              type: 'gray',
                              text: Utils.timeFormat(videoItem.duration),
                              // semanticsLabel:
                              //     '时长${Utils.durationReadFormat(Utils.timeFormat(videoItem.duration))}',
                            )
                        ],
                      );
                    }),
                  ),
                  VideoContent(videoItem: videoItem)
                ],
              ),
            ),
          ),
        ),
      ),
      if (videoItem.goto == 'av')
        Positioned(
            right: -5,
            bottom: -2,
            child: VideoPopupMenu(
              size: 29,
              iconSize: 17,
              actions: actions,
            )),
    ]));
  }
}

class VideoContent extends StatelessWidget {
  final dynamic videoItem;
  const VideoContent({super.key, required this.videoItem});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(6, 5, 6, 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(videoItem.title + "\n",
                      // semanticsLabel: "${videoItem.title}",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        height: 1.38,
                      )),
                ),
              ],
            ),
            const Spacer(),
            // const SizedBox(height: 2),
            VideoStat(
              videoItem: videoItem,
            ),
            Row(
              children: [
                if (videoItem.goto == 'bangumi') ...[
                  PBadge(
                    text: videoItem.bangumiBadge,
                    stack: 'normal',
                    size: 'small',
                    type: 'line',
                    fs: 9,
                  )
                ],
                if (videoItem.rcmdReason != null) ...[
                  PBadge(
                    text: videoItem.rcmdReason,
                    stack: 'normal',
                    size: 'small',
                    type: 'color',
                  )
                ],
                if (videoItem.goto == 'picture') ...[
                  const PBadge(
                    text: '动态',
                    stack: 'normal',
                    size: 'small',
                    type: 'line',
                    fs: 9,
                  )
                ],
                if (videoItem.isFollowed == 1) ...[
                  const PBadge(
                    text: '已关注',
                    stack: 'normal',
                    size: 'small',
                    type: 'color',
                  )
                ],
                Expanded(
                  flex: 1,
                  child: Text(
                    videoItem.owner.name.toString(),
                    // semanticsLabel: "Up主：${videoItem.owner.name}",
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    style: TextStyle(
                      height: 1.5,
                      fontSize:
                          Theme.of(context).textTheme.labelMedium!.fontSize,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ),
                if (videoItem.goto == 'av') const SizedBox(width: 10)
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class VideoStat extends StatelessWidget {
  final dynamic videoItem;

  const VideoStat({
    super.key,
    required this.videoItem,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        StatView(
          theme: 'gray',
          view: videoItem.stat.view,
          goto: videoItem.goto,
        ),
        const SizedBox(width: 6),
        if (videoItem.goto != 'picture')
          StatDanMu(
            theme: 'gray',
            danmu: videoItem.stat.danmu,
          ),
        if (videoItem is RecVideoItemModel) ...<Widget>[
          const Spacer(),
          Expanded(
              flex: 0,
              child: RichText(
                maxLines: 1,
                text: TextSpan(
                    style: TextStyle(
                      fontSize:
                          Theme.of(context).textTheme.labelSmall!.fontSize,
                      color: Theme.of(context)
                          .colorScheme
                          .outline
                          .withOpacity(0.8),
                    ),
                    text:
                        Utils.formatTimestampToRelativeTime(videoItem.pubdate)),
              )),
          const SizedBox(width: 2),
        ],
        if (videoItem is RecVideoItemAppModel &&
            videoItem.desc != null &&
            videoItem.desc.contains(' · ')) ...<Widget>[
          const Spacer(),
          Expanded(
              flex: 0,
              child: RichText(
                maxLines: 1,
                text: TextSpan(
                    style: TextStyle(
                      fontSize:
                          Theme.of(context).textTheme.labelSmall!.fontSize,
                      color: Theme.of(context)
                          .colorScheme
                          .outline
                          .withOpacity(0.8),
                    ),
                    text: Utils.shortenChineseDateString(
                        videoItem.desc.split(' · ').last)),
              )),
          const SizedBox(width: 2),
        ]
      ],
    );
  }
}
