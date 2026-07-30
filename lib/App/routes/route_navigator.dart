import 'package:flutter/material.dart';
import 'package:statekit/statekit.dart';

import './app_routes.dart';
import '../screens/home_screen/controller/home_screen_controller.dart';
import '../screens/home_screen/view/home_screen.dart';
import '../screens/splash_screen/view/splash_screen.dart';
import '../screens/play_screen/view/play_screen.dart';
import '../screens/play_screen/controller/play_screen_controller.dart';
import '../screens/level_selection_screen/view/level_selection_screen.dart';
import '../screens/level_selection_screen/controller/level_selection_controller.dart';

abstract class RouteNavigator {
  static final Map<String, Widget Function(BuildContext)> routes = {
    Routes.splash: (BuildContext context) => const SplashScreen(),
    Routes.homeScreen: (BuildContext context) => StateProvider(
      stateProvider: StatekitProvider(create: () => HomeScreenController()),
      child: HomeScreen(),
    ),
    Routes.playScreen: (BuildContext context) => StateProvider(
      stateProvider: StatekitProvider(create: () => PlayScreenController()),
      child: PlayScreen(),
    ),
    Routes.levelSelectionScreen: (BuildContext context) => StateProvider(
      stateProvider: StatekitProvider(
        create: () => LevelSelectionController(),
      ),
      child: LevelSelectionScreen(),
    ),
  };
}
