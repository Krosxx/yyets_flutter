import 'package:flutter/material.dart';
import 'package:flutter_yyets/model/provider/app_theme.dart';
import 'package:flutter_yyets/ui/routes.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';

import 'model/provider/RRUser.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static final String VERSION = "1.0.9";

  static AppTheme appTheme = AppTheme();
  static RRUser rrUser = RRUser();

  @override
  Widget build(BuildContext context) {
    return OKToast(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => appTheme),
          ChangeNotifierProvider(create: (_) => rrUser),
        ],
        child: Consumer<AppTheme>(
          builder: (BuildContext context, AppTheme theme, Widget child) =>
              MaterialApp(
            title: 'yyeTs',
            debugShowCheckedModeBanner: false,
            theme: theme.theme,
            darkTheme: AppTheme.dark,
            routes: ROUTES,
          ),
        ),
      ),
    );
  }
}
