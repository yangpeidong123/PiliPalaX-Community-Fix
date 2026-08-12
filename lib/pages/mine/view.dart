// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:flex_seed_scheme/flex_seed_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:PiliPalaX/common/constants.dart';
import 'package:PiliPalaX/common/widgets/network_img_layer.dart';
import 'package:PiliPalaX/models/common/theme_type.dart';
import 'package:PiliPalaX/models/user/info.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../utils/storage.dart';
import 'controller.dart';

class MinePage extends StatefulWidget {
  const MinePage({super.key});

  @override
  State<MinePage> createState() => _MinePageState();
}

class _MinePageState extends State<MinePage> {
  final MineController mineController = Get.put(MineController());
  late Future _futureBuilderFuture;

  @override
  void initState() {
    super.initState();
    _futureBuilderFuture = mineController.queryUserInfo();

    mineController.userLogin.listen((status) {
      if (mounted) {
        _futureBuilderFuture = mineController.queryUserInfo();
        _futureBuilderFuture.then((value) => setState(() {}));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 宽度以最长的行为准，便于两端对齐
    return IntrinsicWidth(
        child: Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 8),
        Row(
            // mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 12),
              InkWell(
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/logo/logo_android_2.png',
                      width: 30,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'PiliPalaX',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ],
                ),
                onTap: () {
                  FlexSchemeVariant _dynamicSchemeVariant =
                      FlexSchemeVariant.values[GStorage.setting
                          .get(SettingBoxKey.schemeVariant, defaultValue: 10)];

                  showMenu<FlexSchemeVariant>(
                    context: context,
                    position: const RelativeRect.fromLTRB(0, 0, 0, 0),
                    initialValue: _dynamicSchemeVariant,
                    items: FlexSchemeVariant.values
                        .map(
                          (item) => PopupMenuItem<FlexSchemeVariant>(
                            value: item,
                            height: 35,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(item.icon, size: 20),
                                const SizedBox(width: 10),
                                Text(item.variantName),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ).then((selectedItem) {
                    if (selectedItem != null) {
                      _dynamicSchemeVariant = selectedItem;
                      GStorage.setting
                          .put(SettingBoxKey.schemeVariant, selectedItem.index);
                      (context as Element).markNeedsBuild();
                      Get.forceAppUpdate();
                    }
                  });
                },
              ),
              const Expanded(
                flex: 255,
                child: SizedBox(
                  width: 10,
                ),
              ),
              IconButton(
                iconSize: 40.0,
                padding: const EdgeInsets.all(8),
                // constraints: const BoxConstraints(),
                style: const ButtonStyle(
                  tapTargetSize:
                      MaterialTapTargetSize.shrinkWrap, // the '2023' part
                ),
                tooltip: "${MineController.anonymity ? '退出' : '进入'}无痕模式",
                onPressed: () {
                  MineController.onChangeAnonymity(context);
                  setState(() {});
                },
                icon: Icon(
                  MineController.anonymity
                      ? MdiIcons.incognito
                      : MdiIcons.incognitoOff,
                  size: 24,
                ),
              ),
              IconButton(
                iconSize: 40.0,
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(),
                style: const ButtonStyle(
                  tapTargetSize:
                      MaterialTapTargetSize.shrinkWrap, // the '2023' part
                ),
                //system -> dark -> light -> system
                tooltip:
                    '切换至${mineController.themeType.value == ThemeType.system ? '深色' : (mineController.themeType.value == ThemeType.dark ? '浅色' : '跟随系统')}主题',
                onPressed: () {
                  mineController.onChangeTheme();
                  setState(() {});
                },
                icon: Icon(
                  mineController.themeType.value == ThemeType.system
                      ? MdiIcons.themeLightDark
                      : mineController.themeType.value == ThemeType.light
                          ? MdiIcons.weatherSunny
                          : MdiIcons.weatherNight,
                  size: 24,
                ),
              ),
              IconButton(
                iconSize: 40.0,
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(),
                style: const ButtonStyle(
                  tapTargetSize:
                      MaterialTapTargetSize.shrinkWrap, // the '2023' part
                ),
                tooltip: '设置',
                onPressed: () => {
                  Get.back(),
                  Get.toNamed('/setting', preventDuplicates: false),
                },
                icon: Icon(
                  MdiIcons.cogs,
                  size: 24,
                ),
              ),
              const SizedBox(width: 10),
            ]),
        const SizedBox(height: 10),
        FutureBuilder(
          future: _futureBuilderFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.data == null || !snapshot.data['status']) {
                return userInfoBuild(mineController, context);
              }
              return Obx(() => userInfoBuild(mineController, context));
            } else {
              return userInfoBuild(mineController, context);
            }
          },
        ),
      ],
    ));
  }

  Widget userInfoBuild(_mineController, context) {
    LevelInfo? levelInfo = _mineController.userInfo.value.levelInfo;
    TextStyle style = TextStyle(
        fontSize: Theme.of(context).textTheme.titleMedium!.fontSize,
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.bold);
    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // const SizedBox(width: 20),
              GestureDetector(
                onTap: () => _mineController.onLogin(),
                child: ClipOval(
                  child: Container(
                    width: 55,
                    height: 55,
                    color: Theme.of(context).colorScheme.onInverseSurface,
                    child: Center(
                      child: _mineController.userInfo.value.face != null
                          ? NetworkImgLayer(
                              src: _mineController.userInfo.value.face,
                              semanticsLabel: '头像',
                              width: 55,
                              height: 55)
                          : Image.asset(
                              'assets/images/noface.jpeg',
                              semanticLabel: "默认头像",
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 13),
              IntrinsicWidth(
                  child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _mineController.userInfo.value.uname ?? '点击头像登录',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(width: 4),
                      Image.asset(
                        'assets/images/lv/lv${_mineController.userInfo.value.levelInfo?.currentLevel ?? '0'}.png',
                        height: 10,
                        semanticLabel:
                            '等级：${_mineController.userInfo.value.levelInfo?.currentLevel ?? '0'}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text.rich(TextSpan(children: [
                    TextSpan(
                        text: '硬币',
                        style: TextStyle(
                            fontSize: Theme.of(context)
                                    .textTheme
                                    .labelSmall!
                                    .fontSize! -
                                2,
                            color: Theme.of(context).colorScheme.outline)),
                    const WidgetSpan(
                        alignment: PlaceholderAlignment.baseline,
                        baseline: TextBaseline.alphabetic,
                        child: SizedBox(width: 1.5)),
                    TextSpan(
                        text: (_mineController.userInfo.value.money ?? '-')
                            .toString(),
                        style: TextStyle(
                            fontSize: Theme.of(context)
                                .textTheme
                                .labelSmall!
                                .fontSize,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary)),
                    const WidgetSpan(
                        alignment: PlaceholderAlignment.baseline,
                        baseline: TextBaseline.alphabetic,
                        child: SizedBox(width: 5)),
                    TextSpan(
                        text: "经验",
                        style: TextStyle(
                            fontSize: Theme.of(context)
                                    .textTheme
                                    .labelSmall!
                                    .fontSize! -
                                2,
                            color: Theme.of(context).colorScheme.outline)),
                    const WidgetSpan(
                        alignment: PlaceholderAlignment.baseline,
                        baseline: TextBaseline.alphabetic,
                        child: SizedBox(width: 1.5)),
                    TextSpan(
                        text: "${levelInfo?.currentExp ?? '-'}",
                        semanticsLabel: "当前${levelInfo?.currentExp ?? '-'}",
                        style: TextStyle(
                            fontSize: Theme.of(context)
                                .textTheme
                                .labelSmall!
                                .fontSize,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary)),
                    TextSpan(
                        text: "/${levelInfo?.nextExp ?? '-'}",
                        semanticsLabel: "升级需${levelInfo?.nextExp ?? '-'}",
                        style: TextStyle(
                            fontSize: Theme.of(context)
                                .textTheme
                                .labelSmall!
                                .fontSize!,
                            color: Theme.of(context).colorScheme.outline)),
                  ])),
                  // const SizedBox(height: 4),
                  // Text.rich(TextSpan(children: [
                  // ])),
                  // Text.rich(
                  //     textAlign: TextAlign.right,
                  //     TextSpan(children: [
                  //
                  //     ])),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: 140,
                    child: LinearProgressIndicator(
                      minHeight: 2,
                      value: levelInfo != null
                          ? (levelInfo.currentExp! / levelInfo.nextExp!)
                          : 0,
                      backgroundColor:
                          Theme.of(context).colorScheme.inversePrimary,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary),
                    ),
                  ),
                ],
              )),
              // const SizedBox(width: 20),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
              width: 240,
              height: 100,
              child: GridView.count(
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                children: [
                  InkWell(
                    onTap: () => _mineController.pushDynamic(),
                    borderRadius: StyleString.mdRadius,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                            return ScaleTransition(
                                scale: animation, child: child);
                          },
                          child: Text(
                              (_mineController.userStat.value.dynamicCount ??
                                      '-')
                                  .toString(),
                              key: ValueKey<String>(_mineController
                                  .userStat.value.dynamicCount
                                  .toString()),
                              style: style),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '动态',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () => _mineController.pushFollow(),
                    borderRadius: StyleString.mdRadius,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                            return ScaleTransition(
                                scale: animation, child: child);
                          },
                          child: Text(
                              (_mineController.userStat.value.following ?? '-')
                                  .toString(),
                              key: ValueKey<String>(_mineController
                                  .userStat.value.following
                                  .toString()),
                              style: style),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '关注',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () => _mineController.pushFans(),
                    borderRadius: StyleString.mdRadius,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                            return ScaleTransition(
                                scale: animation, child: child);
                          },
                          child: Text(
                              (_mineController.userStat.value.follower ?? '-')
                                  .toString(),
                              key: ValueKey<String>(_mineController
                                  .userStat.value.follower
                                  .toString()),
                              style: style),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '粉丝',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              )),
        ]);
  }
}

class ActionItem extends StatelessWidget {
  final Icon? icon;
  final Function? onTap;
  final String? text;

  const ActionItem({
    super.key,
    this.icon,
    this.onTap,
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: StyleString.mdRadius,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon!.icon!),
          const SizedBox(height: 8),
          Text(
            text!,
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ],
      ),
    );
  }
}
