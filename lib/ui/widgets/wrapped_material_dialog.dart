import 'package:flutter/material.dart';
import 'package:material_dialog/material_dialog.dart';

Widget WrappedMaterialDialog(
  BuildContext context, {
  Key key,
  title,
  subTitle,
  content,
  actions,
  children,
  enableFullWidth = false,
  enableFullHeight = false,
  headerColor,
  borderRadius = 10.0,
  onBackButtonClicked,
  onCloseButtonClicked,
  enableBackButton = false,
  enableCloseButton = false,
}) {
  var theme = Theme.of(context);
  var closeButtonColor = theme.iconTheme.color;
  var backButtonColor = theme.iconTheme.color;

  var backgroundColor = theme.dialogBackgroundColor;
  return MaterialDialog(
    key: key,
    title: title,
    subTitle: subTitle,
    content: content,
    actions: actions,
    children: children,
    headerColor: headerColor,
    backButtonColor: backButtonColor,
    closeButtonColor: closeButtonColor,
    backgroundColor: backgroundColor,
    enableFullWidth: enableFullWidth,
    enableFullHeight: enableFullHeight,
    enableBackButton: enableBackButton,
    enableCloseButton: enableCloseButton,
    borderRadius: borderRadius,
    onBackButtonClicked: onBackButtonClicked,
    onCloseButtonClicked: onCloseButtonClicked,
  );
}
