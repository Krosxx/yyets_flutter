import 'dart:io';

import 'package:flutter/foundation.dart'
    show debugDefaultTargetPlatformOverride;
import 'package:flutter/material.dart';
import 'package:flutter_yyets/ui/routes.dart';
import 'package:flutter_yyets/utils/mysp.dart';
import 'package:flutter_yyets/utils/tools.dart';
import 'package:oktoast/oktoast.dart';

void main() {
  try {
    if (Platform.isWindows) {
      debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
    }
  } catch (e) {}
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  static final String VERSION = "1.0.7";

  @override
  State createState() => AppState();
}

class AppState extends State<MyApp> {
  static AppState _ins;
  ThemeData _theme;

  static bool get isDarkMode => _ins?._theme?.brightness == Brightness.dark;

  static void toggleTheme() {
    int theme;
    if (isDarkMode) {
      _ins?._theme = light;
      theme = 0;
    } else {
      _ins?._theme = dark;
      theme = 1;
    }
    MySp.then((sp) {
      sp.set("theme", theme);
    });
    _ins?.setState(() {});
  }

  @override
  void initState() {
    _ins = this;
    super.initState();
    _theme = light;
    if (!PlatformExt.isMobilePhone) {
      MySp.then((sp) {
        if (sp.get("theme", 0) == 1) {
          setState(() {
            _theme = dark;
          });
        }
      });
    }
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
    iconTheme: IconThemeData(color: Colors.grey),
  );

  static final ThemeData dark = ThemeData(
    primarySwatch: Colors.blue,
    buttonColor: Colors.blueAccent,
    brightness: Brightness.dark,
    cardColor: Colors.black12,
  );

  @override
  Widget build(BuildContext context) {
    return OKToast(
      child: MaterialApp(
        title: 'yyeTs',
        debugShowCheckedModeBanner: false,
        theme: _theme,
        darkTheme: dark,
        routes: ROUTES,
      ),
    );
  }
}
