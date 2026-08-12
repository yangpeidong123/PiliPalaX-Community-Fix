import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'storage.dart';

void feedBack() {
  Box<dynamic> setting = GStorage.setting;
  // 设置中是否开启
  final bool enable =
      setting.get(SettingBoxKey.feedBackEnable, defaultValue: false) as bool;
  if (enable) {
    HapticFeedback.lightImpact();
  }
}
