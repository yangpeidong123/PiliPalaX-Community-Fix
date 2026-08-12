import 'package:PiliPalaX/common/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class MyDialog {
  static Future<void> show(BuildContext context, Widget child) {
    return showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) => Dialog(
          insetPadding: const EdgeInsets.all(0),
          child: Material(
            clipBehavior: Clip.hardEdge,
            borderRadius: StyleString.mdRadius,
            child: child,
          )),
    );
  }

  static Future<void> showCorner(BuildContext context, Widget child) {
    return showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) => Align(
        alignment: MediaQuery.of(context).orientation == Orientation.portrait
            ? Alignment.bottomRight
            : Alignment.topRight,
        child: Padding(
            padding: const EdgeInsets.all(8.0), // 设置外边距
            child: Material(
              clipBehavior: Clip.hardEdge,
              borderRadius: StyleString.mdRadius,
              child: child,
            )),
      ),
    );
  }
}
