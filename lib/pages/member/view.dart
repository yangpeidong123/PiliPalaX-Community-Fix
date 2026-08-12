import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:PiliPalaX/pages/member/index.dart';
import 'package:PiliPalaX/utils/utils.dart';

import '../member_archive/view.dart';
import '../member_dynamics/view.dart';
import '../member_seasons_and_series/view.dart';
import 'widgets/profile.dart';
import 'package:PiliPalaX/common/widgets/spring_physics.dart';

class MemberPage extends StatefulWidget {
  const MemberPage({super.key});

  @override
  State<MemberPage> createState() => _MemberPageState();
}

class _MemberPageState extends State<MemberPage>
    with SingleTickerProviderStateMixin {
  late String heroTag;
  late MemberController _memberController;
  late Future _futureBuilderFuture;
  // late Future _memberSeasonsFuture;
  // late Future _memberCoinsFuture;

  // final ScrollController _extendNestCtr = ScrollController();
  // final StreamController<bool> appbarStream = StreamController<bool>();
  late int mid;

  @override
  void initState() {
    super.initState();
    mid = int.parse(Get.parameters['mid']!);
    heroTag = Get.arguments?['heroTag'] ?? Utils.makeHeroTag(mid);
    _memberController = Get.put(MemberController(), tag: heroTag);
    _futureBuilderFuture = _memberController.getInfo();
    // _memberSeasonsFuture = _memberController.getMemberSeasons();
    // _memberCoinsFuture = _memberController.getRecentCoinVideo();
    // _extendNestCtr.addListener(
    //   () {
    //     final double offset = _extendNestCtr.position.pixels;
    //     if (offset > 100) {
    //       appbarStream.add(true);
    //     } else {
    //       appbarStream.add(false);
    //     }
    //   },
    // );
  }

  @override
  void dispose() {
    // _extendNestCtr.removeListener(() {});
    // _extendNestCtr.dispose();
    // appbarStream.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isHorizontal = context.width > context.height;
    return Scaffold(
      primary: true,
      appBar: AppBar(
        actions: [
          IconButton(
            tooltip: '搜索',
            onPressed: () => Get.toNamed(
                '/memberSearch?mid=$mid&uname=${_memberController.memberInfo.value.card!.name!}'),
            icon: const Icon(Icons.search_outlined),
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (BuildContext context) => <PopupMenuEntry>[
              if (_memberController.ownerMid != _memberController.mid) ...[
                PopupMenuItem(
                  onTap: () => _memberController.blockUser(context),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.block, size: 19),
                      const SizedBox(width: 10),
                      Text(_memberController.attribute.value != 128
                          ? '加入黑名单'
                          : '移除黑名单'),
                    ],
                  ),
                )
              ],
              PopupMenuItem(
                onTap: () => _memberController.shareUser(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.share_outlined, size: 19),
                    const SizedBox(width: 10),
                    Text(_memberController.ownerMid != _memberController.mid
                        ? '分享UP主'
                        : '分享我的主页'),
                  ],
                ),
              ),
              PopupMenuItem(
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(text: _memberController.mid.toString()),
                  );
                  SmartDialog.showToast('已复制${_memberController.mid}至剪贴板');
                },
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.copy, size: 19),
                  const SizedBox(width: 10),
                  Text('复制UID：${_memberController.mid}')
                ]),
              ),
            ],
          ),
        ],
      ),
      body: NestedScrollView(
        floatHeaderSlivers: false,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverToBoxAdapter(
              child: profileWidget(isHorizontal),
            ),
            SliverPersistentHeader(
              delegate: _MySliverPersistentHeaderDelegate(
                child: ColoredBox(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: TabBar(
                    labelPadding: const EdgeInsets.symmetric(horizontal: 15),
                    tabAlignment: TabAlignment.center,
                    isScrollable: true,
                    tabs: const [
                      Tab(text: '动态'),
                      Tab(text: '投稿'),
                      Tab(text: '合集/列表'),
                      // Tab(text: '图文'),
                      // Tab(text: '收藏'),
                      // Tab(text: '投币'),
                      // Tab(text: '赞过'),
                    ],
                    controller: _memberController.tabController,
                  ),
                ),
              ),
              pinned: true,
            ),
          ];
        },
        body: TabBarView(
          physics: const CustomTabBarViewScrollPhysics(),
          controller: _memberController.tabController,
          children: [
            MemberDynamicsPage(mid: mid),
            MemberArchivePage(mid: mid),
            MemberSeasonsAndSeriesPage(mid: mid),
            // MemberDynamicsPage(mid: mid),
            // MemberDynamicsPage(mid: mid),
            // MemberDynamicsPage(mid: mid),
            // MemberDynamicsPage(mid: mid),
          ],
        ),
      ),
    );
  }

  Widget profileWidget(bool isHorizontal) {
    return Padding(
      padding: const EdgeInsets.only(left: 18, right: 18, bottom: 20),
      child: FutureBuilder(
        future: _futureBuilderFuture,
        builder: (context, snapshot) {
          print("snapshot:${snapshot.connectionState} ${snapshot.hasData}");
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            Map data = snapshot.data!;
            print(data);
            if (data['status']) {
              return Obx(
                () => Stack(
                    alignment: AlignmentDirectional.center,
                    children: [profilePanelAndDetailInfo(isHorizontal, false)]),
              );
            } else {
              return profilePanelAndDetailInfo(isHorizontal, true);
            }
          } else {
            // 骨架屏
            return profilePanelAndDetailInfo(isHorizontal, true);
          }
        },
      ),
    );
  }

  Widget profilePanelAndDetailInfo(bool isHorizontal, bool loadingStatus) {
    print("loadingStatus:$loadingStatus");
    if (isHorizontal) {
      return Row(
        children: [
          Expanded(
              child: ProfilePanel(
                  ctr: _memberController, loadingStatus: loadingStatus)),
          const SizedBox(width: 20),
          Expanded(child: profileDetailInfo()),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfilePanel(ctr: _memberController, loadingStatus: loadingStatus),
        const SizedBox(height: 10),
        profileDetailInfo(),
      ],
    );
  }

  Widget profileDetailInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
                child: Text(
              _memberController.memberInfo.value.card?.name ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(fontWeight: FontWeight.bold, height: 2),
            )),
            const SizedBox(width: 4),
            if (_memberController.memberInfo.value.card?.level != null)
              Image.asset(
                'assets/images/lv/lv${_memberController.memberInfo.value.card!.level}.png',
                height: 11,
                semanticLabel: '等级${_memberController.memberInfo.value.card!.level}',
              ),
            const SizedBox(width: 6),
            if (_memberController.memberInfo.value.card?.vip?.status == 1) ...[
              if (_memberController
                      .memberInfo.value.card!.vip?.label?['image'] !=
                  '')
                Image.network(
                  _memberController
                      .memberInfo.value.card!.vip!.label!['image'],
                  height: 20,
                  semanticLabel:
                      _memberController.memberInfo.value.card!.vip!.label!['text'],
                )
              else if (_memberController.memberInfo.value.card!.vip
                      ?.label?['img_label_uri_hans_static'] !=
                  '')
                Image.network(
                  _memberController.memberInfo.value.card!.vip!
                      .label!['img_label_uri_hans_static'],
                  height: 20,
                  semanticLabel:
                      _memberController.memberInfo.value.card!.vip!.label!['text'],
                ),
            ],
          ],
        ),
        if (_memberController.memberInfo.value.card?.officialVerify != null &&
            _memberController.memberInfo.value.card?.officialVerify!['title'] != '') ...[
          // const SizedBox(height: 2),
          Text.rich(
            maxLines: 2,
            TextSpan(
              text: _memberController.memberInfo.value.card!.officialVerify!['role'] == 1
                  ? '个人认证：'
                  : '机构认证：',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
              ),
              children: [
                TextSpan(
                  text: _memberController.memberInfo.value.card!.officialVerify!['title'],
                ),
              ],
            ),
            softWrap: true,
          ),
        ],
        const SizedBox(height: 6),
        SelectableText(
          _memberController.memberInfo.value.card?.sign ?? '',
        ),
      ],
    );
  }
}

class _MySliverPersistentHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double _minExtent = 40;
  final double _maxExtent = 40;
  final Widget child;

  _MySliverPersistentHeaderDelegate({required this.child});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    //创建child子组件
    //shrinkOffset：child偏移值minExtent~maxExtent
    //overlapsContent：SliverPersistentHeader覆盖其他子组件返回true，否则返回false
    return child;
  }

  //SliverPersistentHeader最大高度
  @override
  double get maxExtent => _maxExtent;

  //SliverPersistentHeader最小高度
  @override
  double get minExtent => _minExtent;

  @override
  bool shouldRebuild(covariant _MySliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
