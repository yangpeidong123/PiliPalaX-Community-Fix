import 'dart:async';

import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:PiliPalaX/common/constants.dart';
import 'package:PiliPalaX/common/skeleton/video_card_v.dart';
import 'package:PiliPalaX/common/widgets/http_error.dart';
import 'package:PiliPalaX/common/widgets/video_card_v.dart';
import 'package:PiliPalaX/common/widgets/staggered_animation.dart';
import 'package:PiliPalaX/pages/home/index.dart';
import 'package:PiliPalaX/pages/main/index.dart';

import '../../utils/grid.dart';
import 'controller.dart';

class RcmdPage extends StatefulWidget {
  const RcmdPage({super.key});

  @override
  State<RcmdPage> createState() => _RcmdPageState();
}

class _RcmdPageState extends State<RcmdPage>
    with AutomaticKeepAliveClientMixin {
  final RcmdController _rcmdController = Get.put(RcmdController());
  late Future _futureBuilderFuture;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _futureBuilderFuture = _rcmdController.queryRcmdFeed('init');
    ScrollController scrollController = _rcmdController.scrollController;
    StreamController<bool> mainStream =
        Get.find<MainController>().bottomBarStream;
    StreamController<bool> searchBarStream =
        Get.find<HomeController>().searchBarStream;
    scrollController.addListener(
      () {
        if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200) {
          EasyThrottle.throttle(
              'my-throttler', const Duration(milliseconds: 200), () {
            _rcmdController.onLoad();
          });
        }
        final ScrollDirection direction =
            scrollController.position.userScrollDirection;
        if (direction == ScrollDirection.forward) {
          mainStream.add(true);
          searchBarStream.add(true);
        } else if (direction == ScrollDirection.reverse) {
          mainStream.add(false);
          searchBarStream.add(false);
        }
      },
    );
  }

  @override
  void dispose() {
    _rcmdController.scrollController.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      clipBehavior: Clip.hardEdge,
      margin: const EdgeInsets.only(
          left: StyleString.safeSpace, right: StyleString.safeSpace),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(StyleString.imgRadius),
      ),
      child: RefreshIndicator(
        displacement: 10.0,
        edgeOffset: 10.0,
        onRefresh: () async {
          await _rcmdController.onRefresh();
          await Future.delayed(const Duration(milliseconds: 300));
        },
        child: CustomScrollView(
          cacheExtent: 3500,
          controller: _rcmdController.scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding:
                  const EdgeInsets.fromLTRB(0, StyleString.cardSpace, 0, 0),
              sliver: FutureBuilder(
                future: _futureBuilderFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done &&
                      snapshot.data != null) {
                    Map data = snapshot.data as Map;
                    if (data['status']) {
                      return Obx(
                        () => contentGrid(
                            _rcmdController,
                            _rcmdController.videoList.isEmpty
                                ? []
                                : _rcmdController.videoList),
                      );
                    } else {
                      return HttpError(
                        errMsg: data['msg'],
                        fn: () {
                          setState(() {
                            _futureBuilderFuture =
                                _rcmdController.queryRcmdFeed('init');
                          });
                        },
                      );
                    }
                  } else {
                    return contentGrid(_rcmdController, []);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget contentGrid(ctr, videoList) {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithExtentAndRatio(
        // 行间距
        mainAxisSpacing: StyleString.cardSpace,
        // 列间距
        crossAxisSpacing: StyleString.cardSpace,
        // 最大宽度
        maxCrossAxisExtent: Grid.maxRowWidth,
        childAspectRatio: StyleString.aspectRatio,
        mainAxisExtent: MediaQuery.textScalerOf(context).scale(90),
      ),
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return videoList!.isNotEmpty
              ? StaggeredFadeIn(
                  index: index,
                  child: VideoCardV(videoItem: videoList[index]),
                )
              : const VideoCardVSkeleton();
        },
        childCount: videoList!.isNotEmpty ? videoList!.length : 10,
      ),
    );
  }
}
