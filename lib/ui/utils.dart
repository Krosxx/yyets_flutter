import 'package:flutter/material.dart';

Widget tagText(String s) {
  return Padding(
    padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
    child: Chip(
      label: Text(s),
    ),
  );
}
