// 全屏模式
enum FullScreenMode {
  // 根据内容自适应
  auto,
  // 不改变当前方向
  none,
  // 始终竖屏
  vertical,
  // 始终横屏
  horizontal,
  // 屏幕长宽比<1.25时强制竖屏，否则按视频方向
  ratio,
  // 强制重力转屏（仅安卓）
  gravity,
}

extension FullScreenModeDesc on FullScreenMode {
  String get description => [
        '按视频方向（默认）',
        '不改变当前方向（平板推荐）',
        '强制竖屏',
        '强制横屏',
        '屏幕长宽比<1.25时均竖屏，否则按视频方向',
        '忽略系统方向锁定，按重力转屏（仅安卓）'
      ][index];
}

extension FullScreenModeCode on FullScreenMode {
  int get code => index;

  static FullScreenMode? fromCode(int code) {
    if (code >= 0 && code < FullScreenMode.values.length) {
      return FullScreenMode.values[code];
    }
    return null;
  }
}
