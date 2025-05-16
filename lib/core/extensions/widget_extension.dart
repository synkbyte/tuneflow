import 'package:flutter/material.dart';

extension WidgetKeyExtension on Widget {
  Widget applyKey(Key key) {
    return Container(key: key, child: this);
  }
}
