import 'dart:developer';

import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:PiliPalaX/common/constants.dart';
import '../member/widgets/seasons.dart';
import 'controller.dart';

class MemberSeasonsAndSeriesPage extends StatefulWidget {
  const MemberSeasonsAndSeriesPage({super.key, required this.mid});
  final int mid;

  @override
  State<MemberSeasonsAndSeriesPage> createState() =>
      _MemberSeasonsAndSeriesPageState();
}

class _MemberSeasonsAndSeriesPageState
    extends State<MemberSeasonsAndSeriesPage> {
  late MemberSeasonsAndSeriesController _ctr;
  late Future _futureBuilderFuture;
  late ScrollController scrollController;
  late int mid;

  @override
  void initState() {
    super.initState();
    mid = widget.mid;
    _ctr = Get.put(MemberSeasonsAndSeriesController(mid: mid));
    _futureBuilderFuture = _ctr.onRefresh();
  }

  Widget commonWidget(msg) {
    return SliverPadding(
      padding: const EdgeInsets.only(
        top: 20,
        bottom: 30,
      ),
      sliver: SliverToBoxAdapter(
        child: Center(
          child: Text(
            msg,
            style: Theme.of(context)
                .textTheme
                .labelMedium!
                .copyWith(color: Theme.of(context).colorScheme.outline),
          ),
        ),
      ),
    );
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
              'member_dynamics', const Duration(milliseconds: 1000), () {
            _ctr.onLoad();
          });
        }
        return true;
      },
      child: RefreshIndicator(
        displacement: 10.0,
        edgeOffset: 10.0,
        onRefresh: _ctr.onRefresh,
        child: CustomScrollView(
          cacheExtent: 3500,
          physics: const ClampingScrollPhysics(),
          slivers: [
            FutureBuilder(
              future: _futureBuilderFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  log(snapshot.toString());
                  if (snapshot.data == null) {
                    print("none");
                    return commonWidget('请求到的数据为空');
                  }
                  if (snapshot.data['status']) {
                    if (_ctr.seasonsList.isEmpty && _ctr.seriesList.isEmpty) {
                      print("none");
                      return commonWidget('用户没有设置合集或视频列表');
                    } else {
                      return Obx(() => SliverPadding(
                          padding: const EdgeInsets.all(StyleString.safeSpace),
                          //为什么要在RxList类型加toList：
                          //https://stackoverflow.com/questions/70156279/flutter-getx-using-recative-list-as-argument-gives-imporper-use-of-getx-error
                          sliver: MemberSeasonsAndSeriesPanel(
                              seasonsList: _ctr.seasonsList.toList(),
                              seriesList: _ctr.seriesList.toList())));
                    }
                  } else {
                    // 请求错误
                    return const SliverToBoxAdapter();
                  }
                } else {
                  return const SliverToBoxAdapter();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
