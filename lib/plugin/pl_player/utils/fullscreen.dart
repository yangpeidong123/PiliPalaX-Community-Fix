import 'dart:async';
import 'dart:io';
import 'dart:ui' show Color;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:auto_orientation/auto_orientation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../../utils/storage.dart';

Timer? screenTimer;
void stopScreenTimer() {
  screenTimer?.cancel();
  screenTimer = null;
}

//横屏
Future<void> landScape() async {
  dynamic document;
  try {
    if (kIsWeb) {
      await document.documentElement?.requestFullscreen();
    } else if (Platform.isAndroid || Platform.isIOS) {
      await AutoOrientation.landscapeAutoMode(forceSensor: true);
    } else if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      await const MethodChannel('com.alexmercerind/media_kit_video')
          .invokeMethod(
        'Utils.EnterNativeFullscreen',
      );
    }
  } catch (exception, stacktrace) {
    debugPrint('$exception.toString('));
    debugPrint('$stacktrace.toString('));
  }
}

//竖屏
Future<void> verticalScreenForTwoSeconds() async {
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  screenTimer = Timer(const Duration(seconds: 2), () {
    autoScreen();
    screenTimer = null;
  });
}

//竖屏
Future<void> verticalScreen() async {
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
}

//全向
Future<void> autoScreen() async {
  if (!GStorage.setting
      .get(SettingBoxKey.allowRotateScreen, defaultValue: true)) {
    return;
  }
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    // DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
}

Future<void> fullAutoModeForceSensor() async {
  await AutoOrientation.fullAutoMode(forceSensor: true);
}

/// 隐藏状态栏 + 导航栏（全屏沉浸模式）
/// 使用 immersiveSticky：用户可滑动边缘临时显示系统栏，数秒后自动隐藏
Future<void> hideStatusBar() async {
  if (Platform.isAndroid) {
    // 全屏沉浸：隐藏顶部状态栏和底部导航栏（三大金刚键）
    // 用户从边缘滑入可临时显示，自动再隐藏（YouTube 式行为）
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
    );
  } else if (Platform.isIOS) {
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
    );
  } else {
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
    );
  }
}

/// 退出全屏，恢复系统栏显示（导航栏 + 状态栏）
Future<void> showStatusBar() async {
  dynamic document;
  late SystemUiMode mode = SystemUiMode.edgeToEdge;
  try {
    if (kIsWeb) {
      document.exitFullscreen();
    } else if (Platform.isAndroid || Platform.isIOS) {
      if (Platform.isAndroid &&
          (await DeviceInfoPlugin().androidInfo).version.sdkInt < 29) {
        // Android 8：manual 模式确保导航栏完全恢复显示
        mode = SystemUiMode.manual;
      }
      await SystemChrome.setEnabledSystemUIMode(
        mode,
        overlays: SystemUiOverlay.values,
      );
      // 恢复导航栏透明背景（与 main.dart 的初始设置一致）
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        systemNavigationBarColor: Color(0x00000000),
        systemNavigationBarDividerColor: Color(0x00000000),
      ));
    } else if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      await const MethodChannel('com.alexmercerind/media_kit_video')
          .invokeMethod(
        'Utils.ExitNativeFullscreen',
      );
    }
  } catch (exception, stacktrace) {
    debugPrint('$exception.toString('));
    debugPrint('$stacktrace.toString('));
  }
}