import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:colors/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock device orientation to portrait mode only
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Hide system status bar (Immersive Sticky mode for game)
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // Light status bar icons/text when displayed to match wooden theme
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const MyApp());
}
