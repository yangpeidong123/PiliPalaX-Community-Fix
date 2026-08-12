import 'dart:async';

import 'package:PiliPalaX/models/common/side_bar_position.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:PiliPalaX/common/widgets/network_img_layer.dart';
import 'package:PiliPalaX/utils/feed_back.dart';
import './controller.dart';
import 'package:PiliPalaX/common/widgets/spring_physics.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  final HomeController _homeController = Get.put(HomeController());
  List videoList = [];
  late Stream<bool> stream;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    stream = _homeController.searchBarStream.stream;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // Brightness currentBrightness = MediaQuery.of(context).platformBrightness;
    // // 设置状态栏图标的亮度
    // if (_homeController.enableGradientBg) {
    //   SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    //     statusBarIconBrightness: currentBrightness == Brightness.light
    //         ? Brightness.dark
    //         : Brightness.light,
    //   ));
    // }
    return Scaffold(
      extendBody: true,
      // extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        toolbarHeight: 0,
        elevation: 0,
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarIconBrightness:
              Theme.of(context).brightness == Brightness.dark
                  ? Brightness.light
                  : Brightness.dark,
        ),
      ),
      body: Column(
        children: [
          if (_homeController.sideBarPosition == SideBarPosition.none ||
              ((_homeController.sideBarPosition ==
                          SideBarPosition.leftHorizontal ||
                      _homeController.sideBarPosition ==
                          SideBarPosition.rightHorizontal) &&
                  MediaQuery.of(context).orientation == Orientation.portrait))
            CustomAppBar(
              stream: _homeController.hideSearchBar
                  ? stream
                  : StreamController<bool>.broadcast().stream,
              ctr: _homeController,
            ),
          if (_homeController.tabs.length > 1) ...[
            if (_homeController.enableGradientBg) ...[
              const CustomTabs(),
            ] else ...[
              const SizedBox(height: 4),
              SizedBox(
                width: double.infinity,
                height: 42,
                child: Align(
                  alignment: Alignment.center,
                  child: TabBar(
                    controller: _homeController.tabController,
                    tabs: [
                      for (var i in _homeController.tabs) Tab(text: i['label'])
                    ],
                    isScrollable: true,
                    dividerColor: Colors.transparent,
                    enableFeedback: true,
                    splashBorderRadius: BorderRadius.circular(10),
                    tabAlignment: TabAlignment.center,
                    onTap: (value) {
                      feedBack();
                      if (_homeController.initialIndex.value == value) {
                        _homeController.tabsCtrList[value]().animateToTop();
                      }
                      _homeController.initialIndex.value = value;
                    },
                  ),
                ),
              ),
            ],
          ] else ...[
            const SizedBox(height: 6),
          ],
          Expanded(
            child: TabBarView(
              physics: const CustomTabBarViewScrollPhysics(),
              controller: _homeController.tabController,
              children: _homeController.tabsPageList,
            ),
          ),
        ],
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double height;
  final Stream<bool>? stream;
  final HomeController ctr;

  const CustomAppBar({
    super.key,
    this.height = kToolbarHeight,
    this.stream,
    required this.ctr,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: stream,
      initialData: true,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return AnimatedOpacity(
          opacity: snapshot.data ? 1 : 0,
          duration: const Duration(milliseconds: 300),
          child: AnimatedContainer(
            curve: Curves.easeInOutCubicEmphasized,
            duration: const Duration(milliseconds: 500),
            height: snapshot.data ? 52 : 0,
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 0),
            child: SearchBarAndUser(
              ctr: ctr,
            ),
          ),
        );
      },
    );
  }
}

class SearchBarAndUser extends StatelessWidget {
  const SearchBarAndUser({
    super.key,
    required this.ctr,
  });

  final HomeController ctr;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SearchBar(ctr: ctr),
        const SizedBox(width: 4),
        Obx(() => ctr.userLogin.value
            ? ClipRect(
                child: IconButton(
                  tooltip: '消息',
                  onPressed: () => Get.toNamed('/whisper'),
                  icon: const Icon(
                    Icons.notifications_none,
                  ),
                ),
              )
            : const SizedBox.shrink()),
        const SizedBox(width: 8),
        Semantics(
            label: "我的",
            child: Obx(
              () => ctr.userLogin.value
                  ? Stack(
                      children: [
                        NetworkImgLayer(
                          type: 'avatar',
                          width: 34,
                          height: 34,
                          src: ctr.userFace.value,
                        ),
                        Positioned.fill(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => ctr.showUserInfoDialog(context),
                              splashColor: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer
                                  .withOpacity(0.3),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(50),
                              ),
                            ),
                          ),
                        )
                      ],
                    )
                  : DefaultUser(
                      callback: () => ctr.showUserInfoDialog(context)),
            )),
      ],
    );
  }
}

class UserAndSearchVertical extends StatelessWidget {
  const UserAndSearchVertical({
    super.key,
    required this.ctr,
  });

  final HomeController ctr;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Semantics(
            label: "我的",
            child: Obx(
              () => ctr.userLogin.value
                  ? Stack(
                      children: [
                        NetworkImgLayer(
                          type: 'avatar',
                          width: 34,
                          height: 34,
                          src: ctr.userFace.value,
                        ),
                        Positioned.fill(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => ctr.showUserInfoDialog(context),
                              splashColor: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer
                                  .withOpacity(0.3),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(50),
                              ),
                            ),
                          ),
                        )
                      ],
                    )
                  : DefaultUser(
                      callback: () => ctr.showUserInfoDialog(context)),
            )),
        const SizedBox(height: 8),
        Obx(() => ctr.userLogin.value
            ? IconButton(
                tooltip: '消息',
                onPressed: () => Get.toNamed('/whisper'),
                icon: const Icon(
                  Icons.notifications_none,
                ),
              )
            : const SizedBox.shrink()),
        IconButton(
          icon: const Icon(
            Icons.search_outlined,
            semanticLabel: '搜索',
          ),
          onPressed: () => Get.toNamed('/search'),
        ),
      ],
    );
  }
}

class DefaultUser extends StatelessWidget {
  const DefaultUser({super.key, this.callback});
  final Function? callback;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 38,
      height: 38,
      child: IconButton(
        tooltip: '默认用户头像',
        style: ButtonStyle(
          padding: WidgetStateProperty.all(EdgeInsets.zero),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            return Theme.of(context).colorScheme.onInverseSurface;
          }),
        ),
        onPressed: () => callback?.call(),
        icon: Icon(
          Icons.person_rounded,
          size: 22,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class CustomTabs extends StatefulWidget {
  const CustomTabs({super.key});

  @override
  State<CustomTabs> createState() => _CustomTabsState();
}

class _CustomTabsState extends State<CustomTabs> {
  final HomeController _homeController = Get.put(HomeController());

  void onTap(int index) {
    feedBack();
    if (_homeController.initialIndex.value == index) {
      _homeController.tabsCtrList[index]().animateToTop();
    }
    _homeController.initialIndex.value = index;
    _homeController.tabController.index = index;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      margin: const EdgeInsets.only(top: 4),
      child: Obx(
        () => ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 14.0),
          scrollDirection: Axis.horizontal,
          itemCount: _homeController.tabs.length,
          separatorBuilder: (BuildContext context, int index) {
            return const SizedBox(width: 10);
          },
          itemBuilder: (BuildContext context, int index) {
            String label = _homeController.tabs[index]['label'];
            return Obx(
              () => CustomChip(
                onTap: () => onTap(index),
                label: label,
                selected: index == _homeController.initialIndex.value,
              ),
            );
          },
        ),
      ),
    );
  }
}

class CustomChip extends StatelessWidget {
  final Function onTap;
  final String label;
  final bool selected;
  const CustomChip({
    super.key,
    required this.onTap,
    required this.label,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorTheme = Theme.of(context).colorScheme;
    final TextStyle chipTextStyle = selected
        ? const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)
        : const TextStyle(fontSize: 13);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    const VisualDensity visualDensity =
        VisualDensity(horizontal: -4.0, vertical: -2.0);
    return InputChip(
      side: selected
          ? BorderSide(
              color: colorScheme.secondary.withOpacity(0.2),
              width: 2,
            )
          : BorderSide.none,
      // backgroundColor: colorTheme.primaryContainer.withOpacity(0.1),
      // selectedColor: colorTheme.secondaryContainer.withOpacity(0.8),
      color: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
        return colorTheme.secondaryContainer.withOpacity(0.6);
      }),
      padding: const EdgeInsets.fromLTRB(6, 1, 6, 1),
      label: Text(label, style: chipTextStyle),
      onPressed: () => onTap(),
      selected: selected,
      showCheckmark: false,
      visualDensity: visualDensity,
    );
  }
}

class SearchBar extends StatelessWidget {
  const SearchBar({
    super.key,
    required this.ctr,
  });

  final HomeController? ctr;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        width: 250,
        height: 44,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
        ),
        child: Material(
          color: colorScheme.onSecondaryContainer.withOpacity(0.05),
          child: InkWell(
            splashColor: colorScheme.primaryContainer.withOpacity(0.3),
            onTap: () => Get.toNamed(
              '/search',
              parameters: {'hintText': ctr!.defaultSearch.value},
            ),
            child: Row(
              children: [
                const SizedBox(width: 14),
                Icon(
                  Icons.search_outlined,
                  color: colorScheme.onSecondaryContainer,
                  semanticLabel: '搜索',
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Obx(
                    () => Text(
                      ctr!.defaultSearch.value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: colorScheme.outline),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
