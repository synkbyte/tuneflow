import 'package:flutter/material.dart';

extension ContextExt on BuildContext {
  Color get bgColor => Theme.of(this).colorScheme.surface;
  Color get onBgColor => Theme.of(this).colorScheme.onSurface;
  Color get secondaryCon => Theme.of(this).colorScheme.secondaryContainer;
  Color get primary => Theme.of(this).colorScheme.primary;
  bool get isDark =>
      Theme.of(this).brightness == Brightness.dark ? true : false;
  Brightness get brightness => Theme.of(this).brightness == Brightness.dark
      ? Brightness.light
      : Brightness.dark;
  ColorScheme get scheme => Theme.of(this).colorScheme;

  double get bottomPadding => MediaQuery.paddingOf(this).bottom;
}
