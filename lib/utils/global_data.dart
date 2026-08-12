import 'package:connectivity_plus/connectivity_plus.dart';

class GlobalData {
  int imgQuality = 10;

  // 缓存上次检测的网络类型，避免频繁查询
  ConnectivityResult? _lastNetType;
  int _lastNetCheckTime = 0;

  // 私有构造函数
  GlobalData._();

  // 单例实例
  static final GlobalData _instance = GlobalData._();

  // 获取全局实例
  factory GlobalData() => _instance;

  /// 获取自适应的图片质量
  /// 在移动数据下自动降低画质以节省流量
  int get adaptiveImgQuality {
    // 每 30 秒重新检测一次网络类型
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastNetCheckTime > 30000) {
      _lastNetCheckTime = now;
      Connectivity().checkConnectivity().then((results) {
        _lastNetType = results.isNotEmpty ? results.first : null;
      });
    }
    // 如果是在移动数据下，降低 50% 画质
    if (_lastNetType == ConnectivityResult.mobile) {
      return (imgQuality * 0.5).round().clamp(1, 100);
    }
    return imgQuality;
  }
}
