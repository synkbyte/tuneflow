import 'package:flutter/material.dart';

extension ThemeModeExt on ThemeMode {
  String get name {
    return switch (this) {
      ThemeMode.dark => 'light',
      ThemeMode.light => 'dark',
      _ => 'system',
    };
  }
}
