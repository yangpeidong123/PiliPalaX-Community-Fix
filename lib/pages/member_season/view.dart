import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:PiliPalaX/common/constants.dart';
import '../../utils/grid.dart';
import 'controller.dart';
import 'widgets/item.dart';

class MemberSeasonPage extends StatefulWidget {
  const MemberSeasonPage({super.key});

  @override
  State<MemberSeasonPage> createState() => _MemberSeasonPageState();
}

class _MemberSeasonPageState extends State<MemberSeasonPage> {
  final MemberSeasonController _memberSeasonController =
      Get.put(MemberSeasonController());
  late Future _futureBuilderFuture;
  late ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    _futureBuilderFuture = _memberSeasonController.getSeasonDetail('init');
    scrollController = _memberSeasonController.scrollController;
    scrollController.addListener(
      () {
        if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200) {
          EasyThrottle.throttle(
              'member_archives', const Duration(milliseconds: 500), () {
            _memberSeasonController.onLoad();
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          titleSpacing: 0,
          centerTitle: false,
          title: Obx(
            () => Text(
                '${_memberSeasonController.meta.value.name}(${_memberSeasonController.meta.value.total})',
                style: Theme.of(context).textTheme.titleMedium),
          )
          // title: Text('Ta的专栏', style: Theme.of(context).textTheme.titleMedium),
          ),
      body: Padding(
        padding: const EdgeInsets.only(
          left: StyleString.safeSpace,
          right: StyleString.safeSpace,
        ),
        child: SingleChildScrollView(
          controller: _memberSeasonController.scrollController,
          child: FutureBuilder(
            future: _futureBuilderFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.data != null) {
                  Map data = snapshot.data as Map;
                  List list = _memberSeasonController.seasonsList;
                  if (data['status']) {
                    return Obx(
                      () => list.isNotEmpty
                          ? LayoutBuilder(
                              builder: (context, boxConstraints) {
                                return GridView.builder(
                                  gridDelegate:
                                      SliverGridDelegateWithExtentAndRatio(
                                    mainAxisSpacing: StyleString.cardSpace,
                                    crossAxisSpacing: StyleString.cardSpace,
                                    maxCrossAxisExtent: Grid.maxRowWidth,
                                    childAspectRatio: 0.94,
                                    mainAxisExtent: 0,
                                  ),
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: _memberSeasonController
                                      .seasonsList.length,
                                  itemBuilder: (context, i) {
                                    return MemberSeasonItem(
                                      seasonItem: _memberSeasonController
                                          .seasonsList[i],
                                    );
                                  },
                                );
                              },
                            )
                          : const Text('暂无数据'),
                    );
                  } else {
                    return const Text('查询出错');
                  }
                } else {
                  return const Text('返回异常');
                }
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
