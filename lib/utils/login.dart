import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:PiliPalaX/pages/dynamics/index.dart';
import 'package:PiliPalaX/pages/home/index.dart';
import 'package:PiliPalaX/pages/media/index.dart';
import 'package:PiliPalaX/pages/mine/index.dart';
import 'package:uuid/uuid.dart';

class LoginUtils {
  static Future refreshLoginStatus(bool status) async {
    try {
      // 更改我的页面登录状态
      await Get.find<MineController>().resetUserInfo();

      // 更改主页登录状态
      HomeController homeCtr = Get.find<HomeController>();
      homeCtr.updateLoginStatus(status);

      MineController mineCtr = Get.find<MineController>();
      mineCtr.userLogin.value = status;

      DynamicsController dynamicsCtr = Get.find<DynamicsController>();
      dynamicsCtr.userLogin.value = status;

      MediaController mediaCtr = Get.find<MediaController>();
      mediaCtr.userLogin.value = status;
    } catch (err) {
      SmartDialog.showToast('refreshLoginStatus error: ${err.toString()}');
    }
  }

  static String buvid() {
    var mac = <String>[];
    var random = Random();

    for (var i = 0; i < 6; i++) {
      var min = 0;
      var max = 0xff;
      var num =
          (random.nextInt(max - min + 1) + min).toRadixString(16).toUpperCase();
      mac.add(num);
    }

    var md5Str =
        md5.convert(utf8.encode(mac.join(':'))).toString().toUpperCase();
    var md5Arr = md5Str.split('');
    return 'XY${md5Arr[2]}${md5Arr[12]}${md5Arr[22]}$md5Str';
  }

  static String getUUID() {
    return const Uuid().v4().replaceAll('-', '');
  }

  static String generateBuvid() {
    String uuid = getUUID() + getUUID();
    return 'XY${uuid.substring(0, 35).toUpperCase()}';
  }

  static String genDeviceId() {
    // https://github.com/bilive/bilive_client/blob/2873de0532c54832f5464a4c57325ad9af8b8698/bilive/lib/app_client.ts#L62
    final String yyyyMMddHHmmss = DateTime.now()
        .toIso8601String()
        .replaceAll(RegExp(r'[-:TZ]'), '')
        .substring(0, 14);

    final Random random = Random(); // Random.secure();
    final String randomHex32 =
        List.generate(32, (index) => random.nextInt(16).toRadixString(16))
            .join();
    final String randomHex16 =
        List.generate(16, (index) => random.nextInt(16).toRadixString(16))
            .join();

    final String deviceID = randomHex32 + yyyyMMddHHmmss + randomHex16;

    final List<int> bytes = RegExp(r'\w{2}')
        .allMatches(deviceID)
        .map((match) => int.parse(match.group(0)!, radix: 16))
        .toList();
    final int checksumValue = bytes.reduce((a, b) => a + b);
    final String check = checksumValue
        .toRadixString(16)
        .substring(checksumValue.toRadixString(16).length - 2);

    return deviceID + check;
  }

  static String generateRandomString(int length) {
    const chars =
        '123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
    final Random random = Random(); // Random.secure();
    return List.generate(length, (index) => chars[random.nextInt(chars.length)])
        .join();
  }
}
