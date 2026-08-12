enum PlayRepeat {
  pause,
  listOrder,
  singleCycle,
  listCycle,
  autoPlayRelated,
}

extension PlayRepeatExtension on PlayRepeat {
  static final List<String> _descList = <String>[
    '播完暂停',
    '顺序播放',
    '单个循环',
    '列表循环',
    '自动连播',
  ];
  String get description => _descList[index];

  int get value => index + 1; //兼容历史配置
}
