import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_yyets/ui/widgets/BottomInputDialog.dart';

Widget tagText(String s) {
  return Container(
    padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
    child: Chip(
      label: Text(s),
      padding: EdgeInsets.all(0),
      labelPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 0),
    ),
  );
}

Future showInputDialog(BuildContext context, String actionText, Widget title) {
  return Navigator.push(
      context, PopRoute(child: BottomInputDialog(actionText, title)));
}
