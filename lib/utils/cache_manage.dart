import 'dart:async';
import 'dart:io';
import 'package:PiliPalaX/utils/storage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

class CacheManage {
  CacheManage._internal();

  static final CacheManage cacheManage = CacheManage._internal();

  factory CacheManage() => cacheManage;

  // 获取缓存目录
  Future<String> loadApplicationCache() async {
    /// clear all of image in memory
    // clearMemoryImageCache();
    /// get ImageCache
    // var res = getMemoryImageCache();

    // 缓存大小
    double cacheSize = 0;
    // cached_network_image directory
    Directory tempDirectory = await getTemporaryDirectory();
    // get_storage directory
    Directory docDirectory = await getApplicationDocumentsDirectory();

    // 获取缓存大小
    if (tempDirectory.existsSync()) {
      double value = await getTotalSizeOfFilesInDir(tempDirectory);
      cacheSize += value;
    }

    /// 获取缓存大小 dioCache
    if (docDirectory.existsSync()) {
      double value = 0;
      String dioCacheFileName =
          '${docDirectory.path}${Platform.pathSeparator}DioCache.db';
      var dioCacheFile = File(dioCacheFileName);
      if (dioCacheFile.existsSync()) {
        value = await getTotalSizeOfFilesInDir(dioCacheFile);
      }
      cacheSize += value;
    }

    return formatSize(cacheSize);
  }

  // 循环计算文件的大小（递归）
  Future<double> getTotalSizeOfFilesInDir(final FileSystemEntity file) async {
    double total = 0;
    try {
      if (file is File) {
        total = (await file.length()).toDouble();
      }
      if (file is Directory) {
        final List<FileSystemEntity> children = file.listSync();
        for (final FileSystemEntity child in children) {
          total += await getTotalSizeOfFilesInDir(child);
        }
      }
    } catch (e) {
      // 忽略找不到文件的错误
      if (e is! PathNotFoundException) {
        print('Error retrieving size for ${file.path}: $e');
      }
    }
    return total;
  }

  // 缓存大小格式转换
  String formatSize(double value) {
    List<String> unitArr = ['B', 'K', 'M', 'G'];
    int index = 0;
    while (value > 1024) {
      index++;
      value = value / 1024;
    }
    String size = value.toStringAsFixed(2);
    return size + unitArr[index];
  }

  // 清除缓存
  Future<bool> clearCacheAll(BuildContext context) async {
    // 是否启动时清除
    RxBool autoClearCache = RxBool(GStorage.setting
        .get(SettingBoxKey.autoClearCache, defaultValue: false));
    bool cleanStatus = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('提示'),
          content: const Text('该操作将清除图片及网络请求缓存数据'),
          actions: [
            Obx(
              () => TextButton.icon(
                onPressed: () {
                  autoClearCache.value = !autoClearCache.value;
                  GStorage.setting
                      .put(SettingBoxKey.autoClearCache, autoClearCache.value);
                  SmartDialog.showToast(
                      autoClearCache.value ? '启动时自动清除缓存' : '已关闭');
                },
                icon: Icon(autoClearCache.value
                    ? Icons.check_box
                    : Icons.check_box_outline_blank),
                label: const Text(
                  '自动',
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: Text(
                '取消',
                style: TextStyle(color: Theme.of(context).colorScheme.outline),
              ),
            ),
            TextButton(
              autofocus: true,
              onPressed: () async {
                Get.back();
                SmartDialog.showLoading(msg: '正在清除...');
                try {
                  await clearLibraryCache();
                  SmartDialog.dismiss().then((res) {
                    SmartDialog.showToast('清除成功');
                  });
                } catch (err) {
                  SmartDialog.dismiss();
                  SmartDialog.showToast(err.toString());
                }
              },
              child: const Text('清除'),
            )
          ],
        );
      },
    ).then((res) {
      return true;
    });
    return cleanStatus;
  }

  /// 清除 Documents 目录下的 DioCache.db
  Future clearApplicationCache() async {
    Directory directory = await getApplicationDocumentsDirectory();
    if (directory.existsSync()) {
      String dioCacheFileName =
          '${directory.path}${Platform.pathSeparator}DioCache.db';
      var dioCacheFile = File(dioCacheFileName);
      if (dioCacheFile.existsSync()) {
        dioCacheFile.delete();
      }
    }
  }

  // 清除 Library/Caches 目录及文件缓存
  static Future clearLibraryCache() async {
    var appDocDir = await getTemporaryDirectory();
    if (appDocDir.existsSync()) {
      // await appDocDir.delete(recursive: true);
      final List<FileSystemEntity> children =
          appDocDir.listSync(recursive: false);
      for (final FileSystemEntity file in children) {
        await file.delete(recursive: true);
      }
    }
  }

  /// 递归方式删除目录及文件
  Future deleteDirectory(FileSystemEntity file) async {
    if (file is Directory) {
      final List<FileSystemEntity> children = file.listSync();
      for (final FileSystemEntity child in children) {
        await deleteDirectory(child);
      }
    }
    await file.delete();
  }
}
