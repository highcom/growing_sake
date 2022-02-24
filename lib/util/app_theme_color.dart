import 'package:flutter/material.dart';

///
/// アプリのテーマカラー設定
///
class AppThemeColor {
  static const MaterialColor baseColor = MaterialColor(
    _baseColorValue,
    <int, Color>{
      50: Color(0xFFa9c6fd),
      100: Color(0xFF99b7ed),
      200: Color(0xFF7795c9),
      300: Color(0xFF6280b3),
      400: Color(0xFF446394),
      500: Color(_baseColorValue),
      600: Color(0xFF1b408d),
      700: Color(0xFF133b68),
      800: Color(0xFF0a3662),
      900: Color(0xFF05345f),
    },
  );
  static const int _baseColorValue = 0xFF274a78;
}