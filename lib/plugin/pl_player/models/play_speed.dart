enum PlaySpeed {
  one,
  two,
}

extension PlaySpeedExtension on PlaySpeed {
  static final List<String> _descList = [
    '1.0',
    '2.0',
  ];
  String get description => _descList[index];

  static final List<double> _valueList = [
    1.0,
    2.0,
  ];
  double get value => _valueList[index];
  double get defaultValue => _valueList[0];
}
