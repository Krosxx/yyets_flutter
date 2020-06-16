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

//  static final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();


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
//                navigatorKey: navigatorKey,
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
