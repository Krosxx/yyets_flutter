import 'package:flutter/material.dart';
import 'package:flutter_yyets/utils/mysp.dart';
import 'package:flutter_yyets/utils/tools.dart';

///
/// 主题数据
///
class AppTheme extends ChangeNotifier {
  ThemeData theme;

  bool get isDarkMode => theme.brightness == Brightness.dark;

  AppTheme() {
    theme = light;
    if (!PlatformExt.isMobilePhone) {
      MySp.then((sp) {
        if (sp.get("theme", 0) == 1) {
          theme = dark;
        }
      });
    }
  }

  void toggleTheme() {
    int t;
    if (isDarkMode) {
      theme = light;
      t = 0;
    } else {
      theme = dark;
      t = 1;
    }
    print("theme $t");
    MySp.then((sp) {
      sp.set("theme", t);
    });
    notifyListeners();
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
}
