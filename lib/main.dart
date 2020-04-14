import 'package:flutter/foundation.dart'
    show debugDefaultTargetPlatformOverride;
import 'package:flutter/material.dart';
import 'package:flutter_yyets/ui/routes.dart';
import 'package:oktoast/oktoast.dart';

void main() {
  debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State createState() => AppState();
}

class AppState extends State<MyApp> {
  static AppState _ins;

  static bool get darkMode =>
      Theme.of(_ins.context).brightness == Brightness.dark;

  @override
  void initState() {
    super.initState();
    _ins = this;
  }

  @override
  void dispose() {
    super.dispose();
    _ins = null;
  }

  static final ThemeData light = ThemeData(
      primarySwatch: Colors.blue,
      buttonColor: Colors.blueAccent,
      brightness: Brightness.light,
      primaryColor: Colors.white,
      cardColor: Colors.white,
      platform: TargetPlatform.fuchsia);

  static final ThemeData dark = ThemeData(
    primarySwatch: Colors.blue,
    buttonColor: Colors.blueAccent,
    brightness: Brightness.dark,
    cardColor: Colors.black12,
    platform: TargetPlatform.fuchsia,
  );

  @override
  Widget build(BuildContext context) {
    return OKToast(
      child: MaterialApp(
        title: 'yyeTs',
        debugShowCheckedModeBanner: false,
        theme: light,
        darkTheme: dark,
        routes: ROUTES,
      ),
    );
  }
}
