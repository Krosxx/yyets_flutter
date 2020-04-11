import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';

const Duration LENGTH_SHORT = Duration(milliseconds: 1500);
const Duration LENGTH_LONG = Duration(seconds: 2);

void toastLong(dynamic msg) {
  toast(msg, LENGTH_LONG);
}

void toast(dynamic msg, [Duration duration = LENGTH_SHORT]) {
  showToast(
    msg.toString(),
    duration: duration,
    position: ToastPosition.bottom,
    textPadding: EdgeInsets.fromLTRB(20, 10, 20, 10),
    radius: 20,
    textStyle: (msg is Exception) ? TextStyle(color: Colors.red) : null,
  );
}
