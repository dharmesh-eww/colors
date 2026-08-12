import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:colors/App/routes/app_routes.dart';
import 'package:colors/App/routes/route_navigator.dart';
import 'App/core/theme/theme.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: Routes.initial,
        routes: RouteNavigator.routes,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: ThemeMode.light,
        builder: (context, child) {
          final media = MediaQuery.of(context);
          return MediaQuery(
            data: media.copyWith(
              textScaler: media.textScaler.clamp(minScaleFactor: 1.0, maxScaleFactor: 1.1),
            ),
            child: child ?? const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}
