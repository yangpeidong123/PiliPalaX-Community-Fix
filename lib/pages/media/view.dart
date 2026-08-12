import 'dart:async';

import 'package:PiliPalaX/pages/setting/style_setting.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:PiliPalaX/common/widgets/network_img_layer.dart';
import 'package:PiliPalaX/models/user/fav_folder.dart';
import 'package:PiliPalaX/pages/main/index.dart';
import 'package:PiliPalaX/pages/media/index.dart';
import 'package:PiliPalaX/utils/utils.dart';

import '../../common/constants.dart';

class MediaPage extends StatefulWidget {
  const MediaPage({super.key});

  @override
  State<MediaPage> createState() => _MediaPageState();
}

class _MediaPageState extends State<MediaPage>
    with AutomaticKeepAliveClientMixin {
  late MediaController mediaController;
  late Future _futureBuilderFuture;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    mediaController = Get.put(MediaController());
    _futureBuilderFuture = mediaController.queryFavFolder();
    ScrollController scrollController = mediaController.scrollController;
    StreamController<bool> mainStream =
        Get.find<MainController>().bottomBarStream;

    mediaController.userLogin.listen((status) {
      setState(() {
        _futureBuilderFuture = mediaController.queryFavFolder();
      });
    });
    scrollController.addListener(
      () {
        final ScrollDirection direction =
            scrollController.position.userScrollDirection;
        if (direction == ScrollDirection.forward) {
          mainStream.add(true);
        } else if (direction == ScrollDirection.reverse) {
          mainStream.add(false);
        }
      },
    );
  }

  @override
  void dispose() {
    mediaController.scrollController.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    Color primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        toolbarHeight: 30,
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarIconBrightness:
              Theme.of(context).brightness == Brightness.light
                  ? Brightness.dark
                  : Brightness.light,
        ),
      ),
      body: SingleChildScrollView(
        controller: mediaController.scrollController,
        child: Column(
          children: [
            ListTile(
              leading: null,
              title: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text(
                  '媒体库',
                  style: TextStyle(
                    fontSize: Theme.of(context).textTheme.titleLarge!.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              trailing: IconButton(
                tooltip: '设置',
                onPressed: () {
                  Get.toNamed('/setting');
                },
                icon: const Icon(
                  Icons.settings_outlined,
                  size: 20,
                ),
              ),
            ),
            // 网格视图替代 for 循环
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 20,
              ),
              child: GridView.builder(
                padding: EdgeInsets.zero,
                physics:
                    const NeverScrollableScrollPhysics(), // 禁用GridView自己的滚动，防止冲突
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 400,
                  crossAxisSpacing: 0, // 网格之间的水平间距
                  mainAxisSpacing: 0, // 网格之间的垂直间距
                  mainAxisExtent: 60,
                ),
                itemCount: mediaController.list.length,
                itemBuilder: (context, index) {
                  var item = mediaController.list[index];
                  return GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => item['onTap'](),
                    child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Row(
                          // mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              item['icon'],
                              color: primary,
                              size: 22, // 图标大小
                            ),
                            const SizedBox(width: 12), // 图标和文字之间的间距
                            Text(
                              item['title'],
                              style: TextStyle(
                                  fontSize: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .fontSize),
                              // textAlign: TextAlign.center, // 文字居中
                            ),
                            const Spacer(),
                          ],
                        )),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Obx(() => mediaController.userLogin.value
                ? favFolder(mediaController, context)
                : const SizedBox(height: 0))
          ],
        ),
      ),
    );
  }

  Widget favFolder(mediaController, context) {
    return Column(
      children: [
        // Divider(
        //   height: 0,
        //   color: Theme.of(context).dividerColor.withOpacity(0.1),
        // ),
        ListTile(
          onTap: () => Get.toNamed('/fav'),
          leading: null,
          dense: true,
          title: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Obx(
              () => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '我的收藏 (${mediaController.favFolderData.value.count ?? 0})  ',
                    style: TextStyle(
                        fontSize:
                            Theme.of(context).textTheme.titleMedium!.fontSize,
                        fontWeight: FontWeight.bold),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
            ),
          ),
          trailing: IconButton(
            tooltip: '刷新',
            onPressed: () {
              setState(() {
                _futureBuilderFuture = mediaController.queryFavFolder();
              });
            },
            icon: const Icon(
              Icons.refresh,
              size: 20,
            ),
          ),
        ),
        SizedBox(
          width: double.infinity,
          height: 200,
          child: FutureBuilder(
            future: _futureBuilderFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done ||
                  !snapshot.hasData) {
                return const SizedBox();
              }
              Map data = snapshot.data as Map;
              if (!data['status']) {
                return SizedBox(
                  height: 160,
                  child: Center(child: Text(data['msg'])),
                );
              }
              return Obx(
                () {
                  List favFolderList =
                      mediaController.favFolderData.value.list!;
                  int favFolderCount =
                      mediaController.favFolderData.value.count!;
                  int extra = favFolderCount > favFolderList.length ? 1 : 0;
                  return ListView.builder(
                    padding: const EdgeInsets.only(left: StyleString.safeSpace),
                    itemCount: favFolderList.length + extra,
                    itemBuilder: (context, index) {
                      if (index < favFolderList.length) {
                        return Padding(
                            padding: const EdgeInsets.only(
                                left: StyleString.cardSpace),
                            child: FavFolderItem(
                                item: mediaController
                                    .favFolderData.value.list![index],
                                index: index));
                      }
                      return Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: IconButton(
                            tooltip: '查看更多',
                            style: ButtonStyle(
                              padding: WidgetStateProperty.all(EdgeInsets.zero),
                              backgroundColor:
                                  WidgetStateProperty.resolveWith((states) {
                                return Theme.of(context)
                                    .colorScheme
                                    .primaryContainer
                                    .withOpacity(0.5);
                              }),
                            ),
                            onPressed: () => Get.toNamed('/fav'),
                            icon: Icon(
                              Icons.arrow_forward_ios,
                              size: 18,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      );
                    },
                    scrollDirection: Axis.horizontal,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class FavFolderItem extends StatelessWidget {
  const FavFolderItem({super.key, this.item, this.index});
  final FavFolderItemData? item;
  final int? index;
  @override
  Widget build(BuildContext context) {
    String heroTag = Utils.makeHeroTag(item!.fid);

    return GestureDetector(
      onTap: () => Get.toNamed('/favDetail',
          arguments: item,
          parameters: {'mediaId': item!.id.toString(), 'heroTag': heroTag}),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 160,
            height: 130,
            margin: const EdgeInsets.only(bottom: 8),
            child: LayoutBuilder(
              builder: (context, BoxConstraints box) {
                return Hero(
                  tag: heroTag,
                  child: NetworkImgLayer(
                    src: item!.cover,
                    width: box.maxWidth,
                    height: box.maxHeight,
                  ),
                );
              },
            ),
          ),
          Text(
            ' ${item!.title}',
            overflow: TextOverflow.fade,
            maxLines: 1,
          ),
          Text(
            ' 共${item!.mediaCount}条视频',
            style: Theme.of(context)
                .textTheme
                .labelSmall!
                .copyWith(color: Theme.of(context).colorScheme.outline),
          )
        ],
      ),
    );
  }
}
