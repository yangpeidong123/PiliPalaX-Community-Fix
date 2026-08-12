// 播放器中部手势
enum PlayerMiddleGesture {
  nonFullScreenUp,
  nonFullScreenDown,
  fullScreenUp,
  fullScreenDown,
}

extension PlayerMiddleGestureDesc on PlayerMiddleGesture {
  String get description => ['非全屏时上滑', '非全屏时下滑', '全屏时上滑', '全屏时下滑'][index];
}

extension PlayerMiddleGestureCode on PlayerMiddleGesture {
  int get code => index;

  static PlayerMiddleGesture? fromCode(int code) {
    if (code >= 0 && code < PlayerMiddleGesture.values.length) {
      return PlayerMiddleGesture.values[code];
    }
    return null;
  }
}
