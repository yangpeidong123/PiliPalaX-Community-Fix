import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:PiliPalaX/common/constants.dart';
import 'package:PiliPalaX/common/skeleton/video_card_h.dart';
import 'package:PiliPalaX/common/widgets/http_error.dart';
import 'package:PiliPalaX/common/widgets/video_card_h.dart';
import 'package:PiliPalaX/pages/home/index.dart';
import 'package:PiliPalaX/pages/main/index.dart';
import 'package:PiliPalaX/pages/rank/zone/index.dart';

import '../../../utils/grid.dart';

class ZonePage extends StatefulWidget {
  const ZonePage({super.key, this.rid, this.tid})
      : assert(
            rid != null || tid != null, 'Either rid or tid must be provided');

  final int? rid;
  final int? tid;

  @override
  State<ZonePage> createState() => _ZonePageState();
}

class _ZonePageState extends State<ZonePage>
    with AutomaticKeepAliveClientMixin {
  late ZoneController _zoneController;
  Future? _futureBuilderFuture;
  late ScrollController scrollController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _zoneController =
        Get.put(ZoneController(), tag: (widget.rid ?? widget.tid).toString());
    _futureBuilderFuture =
        _zoneController.queryRankFeed('init', widget.rid, widget.tid);
    scrollController = _zoneController.scrollController;
    StreamController<bool> mainStream =
        Get.find<MainController>().bottomBarStream;
    StreamController<bool> searchBarStream =
        Get.find<HomeController>().searchBarStream;
    scrollController.addListener(
      () {
        if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200) {
          if (!_zoneController.isLoadingMore) {
            _zoneController.isLoadingMore = true;
            _zoneController.onLoad();
          }
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
    scrollController.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RefreshIndicator(
      displacement: 10.0,
      edgeOffset: 10.0,
      onRefresh: () async {
        return await _zoneController.onRefresh();
      },
      child: CustomScrollView(
        cacheExtent: 3500,
        controller: scrollController,
        slivers: [
          SliverPadding(
            // 单列布局 EdgeInsets.zero
            padding: const EdgeInsets.fromLTRB(
                StyleString.cardSpace, StyleString.safeSpace, 0, 0),
            sliver: FutureBuilder(
              future: _futureBuilderFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                  Map data = snapshot.data as Map;
                  if (data['status']) {
                    return Obx(
                      () => SliverGrid(
                        gridDelegate: SliverGridDelegateWithExtentAndRatio(
                            mainAxisSpacing: StyleString.safeSpace,
                            crossAxisSpacing: StyleString.safeSpace,
                            maxCrossAxisExtent: Grid.maxRowWidth * 2,
                            childAspectRatio: StyleString.aspectRatio * 2.4,
                            mainAxisExtent: 13),
                        delegate: SliverChildBuilderDelegate((context, index) {
                          return VideoCardH(
                            videoItem: _zoneController.videoList[index],
                            showPubdate: true,
                          );
                        }, childCount: _zoneController.videoList.length),
                      ),
                    );
                  } else {
                    return HttpError(
                      errMsg: data['msg'],
                      fn: () {
                        setState(() {
                          _futureBuilderFuture = _zoneController.queryRankFeed(
                              'init', widget.rid, widget.tid);
                        });
                      },
                    );
                  }
                } else {
                  // 骨架屏
                  return SliverGrid(
                    gridDelegate: SliverGridDelegateWithExtentAndRatio(
                        mainAxisSpacing: StyleString.safeSpace,
                        crossAxisSpacing: StyleString.safeSpace,
                        maxCrossAxisExtent: Grid.maxRowWidth * 2,
                        childAspectRatio: StyleString.aspectRatio * 2.4,
                        mainAxisExtent: 0),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return const VideoCardHSkeleton();
                    }, childCount: 10),
                  );
                }
              },
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: MediaQuery.of(context).padding.bottom + 10,
            ),
          )
        ],
      ),
    );
  }
}
