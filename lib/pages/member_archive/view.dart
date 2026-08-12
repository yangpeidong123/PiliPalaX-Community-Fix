import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:PiliPalaX/common/widgets/video_card_h.dart';
import 'package:PiliPalaX/utils/utils.dart';
import '../../common/constants.dart';
import '../../common/widgets/http_error.dart';
import '../../models/member/archive.dart';
import '../../utils/grid.dart';
import 'controller.dart';

class MemberArchivePage extends StatefulWidget {
  const MemberArchivePage({super.key, required this.mid});
  final int mid;

  @override
  State<MemberArchivePage> createState() => _MemberArchivePageState();
}

class _MemberArchivePageState extends State<MemberArchivePage> {
  late MemberArchiveController _memberArchivesController;
  late Future _futureBuilderFuture;
  late int mid;

  @override
  void initState() {
    super.initState();
    mid = widget.mid;
    final String heroTag = Utils.makeHeroTag(mid);
    _memberArchivesController =
        Get.put(MemberArchiveController(mid: mid), tag: heroTag);
    _futureBuilderFuture = _memberArchivesController.getMemberArchive('init');
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        if ((scrollNotification is ScrollEndNotification &&
                scrollNotification.metrics.extentAfter == 0) ||
            (scrollNotification is ScrollUpdateNotification &&
                scrollNotification.metrics.maxScrollExtent -
                        scrollNotification.metrics.pixels <=
                    200)) {
          // 触发分页加载
          EasyThrottle.throttle(
              'member_archives', const Duration(milliseconds: 500), () {
            _memberArchivesController.onLoad();
          });
        }
        return true;
      },
      child: RefreshIndicator(
        displacement: 10.0,
        edgeOffset: 10.0,
        onRefresh: _memberArchivesController.onRefresh, // 下拉刷新时触发的异步操作
        child: CustomScrollView(
          cacheExtent: 3500,
          physics: const ClampingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Row(children: [
                TextButton.icon(
                  icon: const Icon(Icons.play_circle_outline, size: 20),
                  onPressed: _memberArchivesController.episodicButton,
                  label: Text(_memberArchivesController.episodicButtonText),
                ),
                const Spacer(),
                Obx(
                  () => TextButton.icon(
                    icon: const Icon(Icons.sort, size: 20),
                    onPressed: _memberArchivesController.toggleSort,
                    label:
                        Text(_memberArchivesController.currentOrder['label']!),
                  ),
                ),
              ]),
            ),
            SliverPadding(
              padding:
                  const EdgeInsets.symmetric(horizontal: StyleString.safeSpace),
              sliver: FutureBuilder(
                future: _futureBuilderFuture,
                builder: (BuildContext context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const SliverToBoxAdapter();
                  }
                  if (snapshot.data == null) {
                    return HttpError(
                        errMsg: "投稿页出现错误",
                        fn: _memberArchivesController.onRefresh);
                  }
                  Map data = snapshot.data as Map;
                  List<VListItemModel> list =
                      _memberArchivesController.archivesList;
                  if (!data['status']) {
                    return HttpError(
                        errMsg: snapshot.data['msg'],
                        fn: _memberArchivesController.onRefresh);
                  }
                  return Obx(() {
                    if (list.isEmpty) return const SliverToBoxAdapter();
                    return SliverGrid(
                      gridDelegate: SliverGridDelegateWithExtentAndRatio(
                          mainAxisSpacing: StyleString.safeSpace,
                          crossAxisSpacing: StyleString.safeSpace,
                          maxCrossAxisExtent: Grid.maxRowWidth * 2,
                          childAspectRatio: StyleString.aspectRatio * 2.4,
                          mainAxisExtent: 0),
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, index) {
                          return VideoCardH(
                            videoItem: list[index],
                            showOwner: false,
                            showPubdate: true,
                          );
                        },
                        childCount: list.length,
                      ),
                    );
                  });
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
