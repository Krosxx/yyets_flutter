import 'package:flutter/material.dart';
import 'package:flutter_yyets/ui/routes.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart' show debugDefaultTargetPlatformOverride;

void main() {
  debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(milliseconds: 0),(){
      Hive.initFlutter();
    });

    return MaterialApp(
      title: 'yyeTs',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primarySwatch: Colors.green,
          brightness: Brightness.dark,
          platform: TargetPlatform.fuchsia),
      routes: ROUTES,
    );
  }
}
