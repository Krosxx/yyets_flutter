import 'package:flutter/foundation.dart'
    show debugDefaultTargetPlatformOverride;
import 'package:flutter/material.dart';
import 'package:flutter_yyets/ui/routes.dart';
import 'package:oktoast/oktoast.dart';

void main() {
  debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  final ThemeData light = ThemeData(
      primarySwatch: Colors.blue,
      buttonColor: Colors.blueAccent,
      brightness: Brightness.light,
      primaryColor: Colors.white,
      cardColor: Colors.white,
      platform: TargetPlatform.fuchsia);

  final ThemeData dark = ThemeData(
      primarySwatch: Colors.blue,
      buttonColor: Colors.blueAccent,
      brightness: Brightness.dark,
      cardColor: Colors.black12,
      platform: TargetPlatform.fuchsia);


  @override
  Widget build(BuildContext context) {
    return OKToast(
      child: MaterialApp(
        title: 'yyeTs',
        debugShowCheckedModeBanner: false,
        theme: light,
        routes: ROUTES,
      ),
    );
  }
}
