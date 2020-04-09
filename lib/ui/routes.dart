import 'package:flutter/cupertino.dart';
import 'package:flutter_yyets/ui/pages/DetailPage.dart';
import 'package:flutter_yyets/ui/pages/FavoritesPage.dart';
import 'package:flutter_yyets/ui/pages/LoginPage.dart';
import 'package:flutter_yyets/ui/pages/MainPage.dart';
import 'package:flutter_yyets/ui/pages/ResInfoPage.dart';

// ignore: non_constant_identifier_names
final Map<String, WidgetBuilder> ROUTES = {
  "/": (c) => MyHomePage(),
  "/detail": (c) => DetailPage(argsFromContext(c)),
  "/res": (c) => ResInfoPage(argsFromContext(c)),
  "/favorites": (c) => FavoritesPage(),
  "/login": (c) => LoginPage(),

};

dynamic argsFromContext(BuildContext context) {
  return ModalRoute.of(context).settings.arguments;
}
