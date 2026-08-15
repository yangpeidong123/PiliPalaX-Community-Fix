import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/rendering.dart';
// import 'package:PiliPalaX/plugin/pl_player/android_window.dart';
import 'package:PiliPalaX/plugin/pl_player/view.dart';

// import 'package:android_window/android_window.dart';
// import 'package:android_window/main.dart' as android_window;
import 'package:PiliPalaX/utils/cache_manage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:hive/hive.dart';
import 'package:PiliPalaX/common/widgets/custom_toast.dart';
import 'package:PiliPalaX/http/init.dart';
import 'package:PiliPalaX/models/common/color_type.dart';
import 'package:PiliPalaX/models/common/theme_type.dart';
import 'package:PiliPalaX/pages/search/index.dart';
import 'package:PiliPalaX/pages/video/index.dart';
import 'package:PiliPalaX/router/app_pages.dart';
import 'package:PiliPalaX/pages/main/view.dart';
import 'package:PiliPalaX/services/service_locator.dart';
import 'package:PiliPalaX/utils/app_scheme.dart';
import 'package:PiliPalaX/utils/data.dart';
import 'package:PiliPalaX/utils/storage.dart';
import 'package:media_kit/media_kit.dart'; // Provides [Player], [Media], [Playlist] etc.
import 'package:PiliPalaX/utils/recommend_filter.dart';
import 'package:catcher_2/catcher_2.dart';
import './services/loggeer.dart';
import 'package:flex_seed_scheme/flex_seed_scheme.dart';
// import 'package:flutter/scheduler.dart' show timeDilation;

/// mainName must be the same as the method name
// @pragma('vm:entry-point')
// void androidWindow() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   MediaKit.ensureInitialized();
//   await GStorage.init();
//   await setupServiceLocator();
//   Request();
//   await Request.setCookie();
//   runApp(
//     ClipRRect(
//       borderRadius: BorderRadius.circular(12),
//       child: MaterialApp(
//         debugShowCheckedModeBanner: false,
//         theme: ThemeData.light(),
//         darkTheme: ThemeData.dark(),
//         home: const AndroidWindowApp(),
//       ),
//     ),
//   );
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  await GStorage.init();
  // timeDilation = 10.0;
  if (GStorage.setting.get(SettingBoxKey.autoClearCache, defaultValue: false)) {
    await CacheManage.clearLibraryCache();
  }
  if (GStorage.setting
      .get(SettingBoxKey.horizontalScreen, defaultValue: false)) {
    await SystemChrome.setPreferredOrientations(
      //支持竖屏与横屏
      [
        DeviceOrientation.portraitUp,
        // DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ],
    );
  } else {
    await SystemChrome.setPreferredOrientations(
      //支持竖屏
      [
        DeviceOrientation.portraitUp,
      ],
    );
  }
  await setupServiceLocator();
  Request();
  await Request.setCookie();
  RecommendFilter();
  SmartDialog.config.toast =
      SmartConfigToast(displayType: SmartToastType.onlyRefresh);
  // 异常捕获 logo记录
  final Catcher2Options debugConfig = Catcher2Options(
    SilentReportMode(),
    [
      FileHandler(await getLogsPath()),
      ConsoleHandler(
        enableDeviceParameters: false,
        enableApplicationParameters: false,
      )
    ],
  );

  final Catcher2Options releaseConfig = Catcher2Options(
    SilentReportMode(),
    [FileHandler(await getLogsPath())],
  );

  // 根据设备内存动态调整图片缓存，避免低端机 OOM
  try {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.android;
    // totalPhysicalMemory 在 Android 上返回字节
    final totalMemMB = (androidInfo.data['totalPhysicalMemory'] ?? 0) as int;
    if (totalMemMB > 0 && totalMemMB < 4 * 1024) {
      // 低端机（<4GB RAM）：100 张 / 50MB
      PaintingBinding.instance.imageCache.maximumSize = 100;
      PaintingBinding.instance.imageCache.maximumSizeBytes = 50 << 20;
    } else {
      // 中高端机：500 张 / 200MB
      PaintingBinding.instance.imageCache.maximumSize = 500;
      PaintingBinding.instance.imageCache.maximumSizeBytes = 200 << 20;
    }
  } catch (_) {
    // 获取失败时用保守值
    PaintingBinding.instance.imageCache.maximumSize = 200;
    PaintingBinding.instance.imageCache.maximumSizeBytes = 80 << 20;
  }

  Catcher2(
    debugConfig: debugConfig,
    releaseConfig: releaseConfig,
    runAppFunction: () {
      // Release 模式下抑制 print() 输出，提升性能
      if (kReleaseMode) {
        runZoned(
          () => runApp(const MyApp()),
          zoneSpecification: ZoneSpecification(
            print: (self, parent, zone, message) {
              // 在 release 模式下忽略所有 print 调用
            },
          ),
        );
      } else {
        runApp(const MyApp());
      }
    },
  );

  // 小白条、导航栏沉浸
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
    statusBarColor: Colors.transparent,
    systemNavigationBarContrastEnforced: false,
  ));
  Data.init();
  PiliScheme.init();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Box setting = GStorage.setting;
    // 主题色
    Color defaultColor =
        colorThemeTypes[setting.get(SettingBoxKey.customColor, defaultValue: 0)]
            ['color'];
    Color brandColor = defaultColor;
    // 主题模式
    ThemeMode currentThemeValue = ThemeType
        .values[setting.get(SettingBoxKey.themeMode,
            defaultValue: ThemeType.system.code)]
        .toThemeMode;
    // 是否动态取色
    bool isDynamicColor =
        setting.get(SettingBoxKey.dynamicColor, defaultValue: true);
    // 字体缩放大小
    double textScale =
        setting.get(SettingBoxKey.defaultTextScale, defaultValue: 1.0);
    FlexSchemeVariant variant = FlexSchemeVariant
        .values[setting.get(SettingBoxKey.schemeVariant, defaultValue: 10)];

    // 强制设置高帧率
    if (Platform.isAndroid) {
      late List modes;
      FlutterDisplayMode.supported.then((value) {
        modes = value;
        var storageDisplay = setting.get(SettingBoxKey.displayMode);
        DisplayMode f = DisplayMode.auto;
        if (storageDisplay != null) {
          f = modes.firstWhere((e) => e.toString() == storageDisplay,
              orElse: () => f);
        }
        DisplayMode preferred = modes.toList().firstWhere((el) => el == f);
        FlutterDisplayMode.setPreferredMode(preferred);
      });
    }

    return DynamicColorBuilder(
      builder: ((ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        ColorScheme? lightColorScheme;
        ColorScheme? darkColorScheme;
        if (lightDynamic != null && darkDynamic != null && isDynamicColor) {
          // dynamic取色成功
          // lightColorScheme = lightDynamic.harmonized();
          // darkColorScheme = darkDynamic.harmonized();
          lightColorScheme = SeedColorScheme.fromSeeds(
            primaryKey: lightDynamic.primary,
            brightness: Brightness.light,
            variant: variant,
          );
          darkColorScheme = SeedColorScheme.fromSeeds(
            primaryKey: darkDynamic.primary,
            brightness: Brightness.dark,
            variant: variant,
          );
        } else {
          // dynamic取色失败，采用品牌色
          lightColorScheme = SeedColorScheme.fromSeeds(
            primaryKey: brandColor,
            brightness: Brightness.light,
            variant: variant,
          );
          darkColorScheme = SeedColorScheme.fromSeeds(
            primaryKey: brandColor,
            brightness: Brightness.dark,
            variant: variant,
          );
        }
        // 图片缓存
        // PaintingBinding.instance.imageCache.maximumSizeBytes = 1000 << 20;
        return GetMaterialApp(
          // showSemanticsDebugger: true,
          title: 'PiliPalaX',
          theme: _getThemeData(
            colorScheme: lightColorScheme,
            isDynamic: lightDynamic != null && isDynamicColor,
            variant: variant,
          ),
          darkTheme: _getThemeData(
            colorScheme: darkColorScheme,
            isDynamic: darkDynamic != null && isDynamicColor,
            isDark: true,
            variant: variant,
          ),
          themeMode: currentThemeValue,
          localizationsDelegates: const [
            GlobalCupertinoLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          locale: const Locale("zh", "CN"),
          supportedLocales: const [Locale("zh", "CN"), Locale("en", "US")],
          fallbackLocale: const Locale("zh", "CN"),
          getPages: Routes.getPages,
          home: const MainApp(),
          builder: (BuildContext context, Widget? child) {
            return FlutterSmartDialog(
              toastBuilder: (String msg) => CustomToast(msg: msg),
              child: MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: TextScaler.linear(textScale)),
                child: child!,
              ),
            );
          },
          navigatorObservers: [
            VideoDetailPage.routeObserver,
            SearchPage.routeObserver,
          ],
        );
      }),
    );
  }

  ThemeData _getThemeData({
    required ColorScheme colorScheme,
    required bool isDynamic,
    bool isDark = false,
    required FlexSchemeVariant variant,
  }) {
    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      appBarTheme: AppBarTheme(
        elevation: 0,
        titleSpacing: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        backgroundColor: isDynamic ? null : colorScheme.surface,
        titleTextStyle: TextStyle(fontSize: 16, color: colorScheme.onSurface),
      ),
      navigationBarTheme: NavigationBarThemeData(
        surfaceTintColor: isDynamic ? colorScheme.onSurfaceVariant : null,
      ),
      snackBarTheme: SnackBarThemeData(
        actionTextColor: colorScheme.primary,
        backgroundColor: colorScheme.secondaryContainer,
        closeIconColor: colorScheme.secondary,
        contentTextStyle: TextStyle(color: colorScheme.secondary),
        elevation: 20,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: ZoomPageTransitionsBuilder(
            allowEnterRouteSnapshotting: true,
          ),
          TargetPlatform.iOS: ZoomPageTransitionsBuilder(
            allowEnterRouteSnapshotting: true,
          ),
        },
      ),
      popupMenuTheme: PopupMenuThemeData(
        surfaceTintColor: isDynamic ? colorScheme.onSurfaceVariant : null,
      ),
      cardTheme: CardTheme(
        elevation: 1,
        surfaceTintColor: isDark ? colorScheme.onSurfaceVariant : null,
        shadowColor: colorScheme.shadow.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      // dialogTheme: DialogTheme(
      //   surfaceTintColor: isDark ? colorScheme.onSurfaceVariant : null,
      // ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        refreshBackgroundColor: colorScheme.onSecondary,
      ),
    );
  }

}
