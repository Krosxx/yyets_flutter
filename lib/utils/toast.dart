import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void showToast(dynamic msg, {Toast duration = Toast.LENGTH_SHORT}) {
  if (msg is Error) {
    Fluttertoast.showToast(
        msg: msg.toString(),
        toastLength: duration,
        backgroundColor: Colors.red);
  } else {
    Fluttertoast.showToast(msg: msg.toString(), toastLength: duration);
  }
}
