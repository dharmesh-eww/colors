import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const SystemUiOverlayStyle _woodenSystemOverlayStyle = SystemUiOverlayStyle(
  statusBarColor: Colors.transparent,
  statusBarIconBrightness: Brightness.light,
  statusBarBrightness: Brightness.dark,
  systemNavigationBarColor: Colors.transparent,
  systemNavigationBarIconBrightness: Brightness.light,
);

// Light Theme
ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(),
  appBarTheme: const AppBarTheme(
    systemOverlayStyle: _woodenSystemOverlayStyle,
  ),
);

// Dark Theme
ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(),
  appBarTheme: const AppBarTheme(
    systemOverlayStyle: _woodenSystemOverlayStyle,
  ),
);