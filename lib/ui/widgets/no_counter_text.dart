import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

InputCounterWidgetBuilder get NoCounterText => (
      BuildContext context, {
      @required int currentLength,
      @required int maxLength,
      @required bool isFocused,
    }) =>
        Container();
