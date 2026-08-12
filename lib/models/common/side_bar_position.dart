enum SideBarPosition {
  none,
  leftFixed,
  rightFixed,
  leftHorizontal,
  rightHorizontal
}

extension SideBarPositionDesc on SideBarPosition {
  String get values => [
        'none',
        'left_fixed',
        'right_fixed',
        'left_horizontal',
        'right_horizontal'
      ][index];
  String get labels => ['不使用侧栏', '左侧常驻', '右侧常驻', '左侧（仅横屏）', '右侧（仅横屏）'][index];
}

extension SideBarPositionCode on SideBarPosition {
  int get code => index;
  static SideBarPosition? fromCode(int code) {
    if (code >= 0 && code < SideBarPosition.values.length) {
      return SideBarPosition.values[code];
    }
    return null;
  }
}
