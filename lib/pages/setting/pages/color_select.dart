import 'package:flex_seed_scheme/flex_seed_scheme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:PiliPalaX/models/common/color_type.dart';
import 'package:PiliPalaX/utils/storage.dart';

import '../../../models/common/theme_type.dart';
import 'package:PiliPalaX/pages/setting/widgets/select_dialog.dart';
import '../controller.dart';

class ColorSelectPage extends StatefulWidget {
  const ColorSelectPage({super.key});

  @override
  State<ColorSelectPage> createState() => _ColorSelectPageState();
}

class _ColorSelectPageState extends State<ColorSelectPage> {
  final ColorSelectController ctr = Get.put(ColorSelectController());
  final SettingController settingController = Get.put(SettingController());
  FlexSchemeVariant _dynamicSchemeVariant = FlexSchemeVariant.values[
      GStorage.setting.get(SettingBoxKey.schemeVariant, defaultValue: 10)];

  @override
  Widget build(BuildContext context) {
    // 获取当前主题的 ColorScheme
    final colorScheme = Theme.of(context).colorScheme;
    // 用于预览的颜色
    final List<Color> previewColors = [
      colorScheme.primary,
      colorScheme.primaryContainer,
      colorScheme.onPrimary,
      colorScheme.onPrimaryContainer,
      colorScheme.secondary,
      colorScheme.secondaryContainer,
      colorScheme.onSecondary,
      colorScheme.onSecondaryContainer,
      colorScheme.surface,
      colorScheme.onSurface,
      colorScheme.outline,
      colorScheme.outlineVariant,
    ];
    TextStyle titleStyle = Theme.of(context).textTheme.titleMedium!;
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('设置应用主题'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 10),
          // 颜色预览
          ListTile(
              title: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
                width: 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var color in previewColors)
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: color,
                    ),
                  ),
              ],
            ),
          )),
          ListTile(
            dense: false,
            onTap: () async {
              ThemeType? result = await showDialog(
                context: context,
                builder: (context) {
                  return SelectDialog<ThemeType>(
                      title: '主题模式',
                      value: settingController.themeType.value,
                      values: ThemeType.values.map((e) {
                        return {'title': e.description, 'value': e};
                      }).toList());
                },
              );
              if (result != null) {
                settingController.themeType.value = result;
                settingController.themeType.value = result;
                ctr.setting.put(SettingBoxKey.themeMode, result.code);
                Get.forceAppUpdate();
              }
            },
            leading: Container(
              width: 40,
              alignment: Alignment.center,
              child: const Icon(Icons.flashlight_on_outlined),
            ),
            title: Text('主题模式', style: titleStyle),
            subtitle: Obx(() =>
                Text('当前模式：${settingController.themeType.value.description}')),
          ),
          Builder(
            builder: (context) => ListTile(
              title: Row(children: [
                Text('色彩风格', style: titleStyle),
                const Spacer(),
                PopupMenuButton(
                  initialValue: _dynamicSchemeVariant,
                  onSelected: (item) async {
                    _dynamicSchemeVariant = item;
                    await GStorage.setting
                        .put(SettingBoxKey.schemeVariant, item.index);
                    (context as Element).markNeedsBuild();
                    Get.forceAppUpdate();
                  },
                  itemBuilder: (context) => FlexSchemeVariant.values
                      .map((item) => PopupMenuItem<FlexSchemeVariant>(
                            height: 35,
                            value: item,
                            child: Row(children: [
                              Icon(item.icon),
                              const SizedBox(width: 10),
                              Text(item.variantName),
                            ]),
                          ))
                      .toList(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_dynamicSchemeVariant.icon,
                          size: 18,
                          color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        _dynamicSchemeVariant.variantName,
                        style: TextStyle(
                          height: 1,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        strutStyle: const StrutStyle(leading: 0, height: 1),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        size: 20,
                        Icons.keyboard_arrow_right,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    ],
                  ),
                ),
              ]),
              leading: Container(
                width: 40,
                alignment: Alignment.center,
                child: const Icon(Icons.palette_outlined),
              ),
              subtitle: Text(
                _dynamicSchemeVariant.description,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
          Obx(
            () => RadioListTile(
              value: 0,
              title: Text('动态取色', style: titleStyle),
              groupValue: ctr.type.value,
              onChanged: (dynamic val) async {
                ctr.type.value = 0;
                ctr.setting.put(SettingBoxKey.dynamicColor, true);
                Get.forceAppUpdate();
              },
            ),
          ),
          Obx(
            () => RadioListTile(
              value: 1,
              title: Text('指定颜色', style: titleStyle),
              groupValue: ctr.type.value,
              onChanged: (dynamic val) async {
                ctr.type.value = 1;
                ctr.setting.put(SettingBoxKey.dynamicColor, false);
                Get.forceAppUpdate();
              },
            ),
          ),
          Obx(
            () => Padding(
              padding: const EdgeInsets.only(top: 12, left: 12, right: 12),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 22,
                runSpacing: 18,
                children: [
                  ...ctr.colorThemes.map(
                    (e) {
                      final index = ctr.colorThemes.indexOf(e);
                      return GestureDetector(
                        onTap: () {
                          ctr.currentColor.value = index;
                          ctr.type.value = 1;
                          ctr.setting.put(SettingBoxKey.dynamicColor, false);
                          ctr.setting.put(SettingBoxKey.customColor, index);
                          Get.forceAppUpdate();
                        },
                        child: Column(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: e['color'].withOpacity(0.8),
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(
                                  width: 2,
                                  color: ctr.currentColor.value == index
                                      ? (ctr.type.value == 1 ? Colors.black : Colors.black38)
                                      : e['color'].withOpacity(0.8),
                                ),
                              ),
                              child: AnimatedOpacity(
                                opacity: ctr.currentColor.value == index
                                    ? (ctr.type.value == 1? 1 : 0.2)
                                    : 0,
                                duration: const Duration(milliseconds: 200),
                                child: const Icon(
                                  Icons.done,
                                  color: Colors.black,
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              e['label'],
                              style: TextStyle(
                                fontSize: 12,
                                color: ctr.currentColor.value != index
                                    ? Theme.of(context).colorScheme.outline
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // 展示 ColorScheme 的颜色
          ListTile(
            title: Center(child: Text('${colorScheme.toStringShort()} 可用颜色表')),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: GridView.extent(
                shrinkWrap: true, // 自动调整高度
                physics: const NeverScrollableScrollPhysics(), // 禁用滚动
                maxCrossAxisExtent: 120, childAspectRatio: 4.5,
                mainAxisSpacing: 5, crossAxisSpacing: 5,
                children: _buildColorSchemeDisplay(colorScheme),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildColorSchemeDisplay(ColorScheme colorScheme) {
    String colorSchemeString = colorScheme.toString();
    final leftBracketIndex = colorSchemeString.indexOf('(');

    if (leftBracketIndex != -1) {
      colorSchemeString = colorSchemeString.substring(leftBracketIndex + 1);
    }

    final colorEntries = colorSchemeString
        .split(',')
        .where((line) => line.contains('Color('))
        .map((line) {
      final parts = line.split(':');
      final key = parts[0].trim();
      final color = parts[1].trim();
      return MapEntry(key, Color(int.parse(color.substring(8, 16), radix: 16)));
    }).toList();

    return colorEntries.map((entry) {
      return SizedBox(
        width: 80, // 固定宽度
        height: 40, // 固定高度
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: entry.value,
                border: Border.all(color: Colors.black, width: 1),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
                child: Text(entry.key,
                    maxLines: 3,
                    style: const TextStyle(
                      fontSize: 10,
                    ))),
          ],
        ),
      );
    }).toList();
  }
}

class ColorSelectController extends GetxController {
  Box setting = GStorage.setting;
  RxBool dynamicColor = true.obs;
  RxInt type = 0.obs;
  late final List<Map<String, dynamic>> colorThemes;
  RxInt currentColor = 0.obs;

  @override
  void onInit() {
    colorThemes = colorThemeTypes;
    // 默认使用动态取色
    dynamicColor.value =
        setting.get(SettingBoxKey.dynamicColor, defaultValue: true);
    type.value = dynamicColor.value ? 0 : 1;
    currentColor.value =
        setting.get(SettingBoxKey.customColor, defaultValue: 0);
    super.onInit();
  }
}
