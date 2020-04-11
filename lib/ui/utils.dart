import 'package:flutter/material.dart';
import 'package:flutter_yyets/ui/widgets/BottomInputDialog.dart';

Widget tagText(String s) {
  return Padding(
    padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
    child: Chip(
      label: Text(s),
    ),
  );
}

Future showInputDialog(BuildContext context,
    String actionText,Widget title) {
  return Navigator.push(context,
      PopRoute(child: BottomInputDialog(actionText, title)));
}