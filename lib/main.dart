import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_yyets/model/provider/app_theme.dart';
import 'package:flutter_yyets/ui/routes.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';

import 'model/provider/RRUser.dart';

void main() {
  GestureBinding.instance?.resamplingEnabled = true;
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  //todo read from pubspec.yaml
  static final String VERSION = "1.1.0";

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
                onUnknownRoute: (settings) =>
                    MaterialPageRoute(
                      builder: (BuildContext context) {
                        return RouterNotFoundPage(page: settings.name);
                      },
                    ),
              ),
        ),
      ),
    );
  }
}

class RouterNotFoundPage extends StatelessWidget {
  final String page;

  const RouterNotFoundPage({Key key, this.page}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("404: $page"),
      ),
    );
  }
}
