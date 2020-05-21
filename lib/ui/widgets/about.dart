// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart' hide Flow;
import 'package:flutter_yyets/main.dart';
import 'package:flutter_yyets/ui/widgets/wrapped_material_dialog.dart';

class AboutListTile extends StatelessWidget {
  /// Creates a list tile for showing an about box.
  ///
  /// The arguments are all optional. The application name, if omitted, will be
  /// derived from the nearest [Title] widget. The version, icon, and legalese
  /// values default to the empty string.
  const AboutListTile({
    Key key,
    this.icon,
    this.child,
    this.applicationName,
    this.applicationVersion,
    this.applicationIcon,
    this.applicationLegalese,
    this.aboutBoxChildren,
    this.dense,
  }) : super(key: key);

  /// The icon to show for this drawer item.
  ///
  /// By default no icon is shown.
  ///
  /// This is not necessarily the same as the image shown in the dialog box
  /// itself; which is controlled by the [applicationIcon] property.
  final Widget icon;

  /// The label to show on this drawer item.
  ///
  /// Defaults to a text widget that says "About Foo" where "Foo" is the
  /// application name specified by [applicationName].
  final Widget child;

  /// The name of the application.
  ///
  /// This string is used in the default label for this drawer item (see
  /// [child]) and as the caption of the [AboutDialog] that is shown.
  ///
  /// Defaults to the value of [Title.title], if a [Title] widget can be found.
  /// Otherwise, defaults to [Platform.resolvedExecutable].
  final String applicationName;

  /// The version of this build of the application.
  ///
  /// This string is shown under the application name in the [AboutDialog].
  ///
  /// Defaults to the empty string.
  final String applicationVersion;

  /// The icon to show next to the application name in the [AboutDialog].
  ///
  /// By default no icon is shown.
  ///
  /// Typically this will be an [ImageIcon] widget. It should honor the
  /// [IconTheme]'s [IconThemeData.size].
  ///
  /// This is not necessarily the same as the icon shown on the drawer item
  /// itself, which is controlled by the [icon] property.
  final Widget applicationIcon;

  /// A string to show in small print in the [AboutDialog].
  ///
  /// Typically this is a copyright notice.
  ///
  /// Defaults to the empty string.
  final String applicationLegalese;

  /// Widgets to add to the [AboutDialog] after the name, version, and legalese.
  ///
  /// This could include a link to a Web site, some descriptive text, credits,
  /// or other information to show in the about box.
  ///
  /// Defaults to nothing.
  final List<Widget> aboutBoxChildren;

  /// Whether this list tile is part of a vertically dense list.
  ///
  /// If this property is null, then its value is based on [ListTileTheme.dense].
  ///
  /// Dense list tiles default to a smaller height.
  final bool dense;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterial(context));
    assert(debugCheckHasMaterialLocalizations(context));
    return ListTile(
      leading: icon,
      title: child ??
          Text(MaterialLocalizations.of(context).aboutListTileTitle(
            applicationName ?? _defaultApplicationName(context),
          )),
      dense: dense,
      onTap: () {
        showAboutDialog(
          context: context,
          applicationName: applicationName,
          applicationVersion: applicationVersion,
          applicationIcon: applicationIcon,
          applicationLegalese: applicationLegalese,
          children: aboutBoxChildren,
        );
      },
    );
  }
}

void showCustomAboutDialog({
  @required BuildContext context,
  String applicationName,
  String applicationVersion,
  Widget applicationIcon,
  String applicationLegalese,
  List<Widget> children,
  bool useRootNavigator = true,
  RouteSettings routeSettings,
  List<Widget> actions,
}) {
  assert(context != null);
  assert(useRootNavigator != null);
  showDialog<void>(
    context: context,
    useRootNavigator: useRootNavigator,
    builder: (BuildContext context) {
      return AboutDialog(
        applicationName: applicationName,
        applicationVersion: applicationVersion,
        applicationIcon: applicationIcon,
        applicationLegalese: applicationLegalese,
        children: children,
        actions: actions,
      );
    },
    routeSettings: routeSettings,
  );
}

/// An about box. This is a dialog box with the application's icon, name,
/// version number, and copyright, plus a button to show licenses for software
/// used by the application.
///
/// To show an [AboutDialog], use [showAboutDialog].
///
/// If the application has a [Drawer], the [AboutListTile] widget can make the
/// process of showing an about dialog simpler.
///
/// The [AboutDialog] shown by [showAboutDialog] includes a button that calls
/// [showLicensePage].
///
/// The licenses shown on the [LicensePage] are those returned by the
/// [LicenseRegistry] API, which can be used to add more licenses to the list.
class AboutDialog extends StatelessWidget {
  /// Creates an about box.
  ///
  /// The arguments are all optional. The application name, if omitted, will be
  /// derived from the nearest [Title] widget. The version, icon, and legalese
  /// values default to the empty string.
  const AboutDialog({
    Key key,
    this.applicationName,
    this.applicationVersion,
    this.applicationIcon,
    this.applicationLegalese,
    this.children,
    this.actions,
  }) : super(key: key);

  /// The name of the application.
  ///
  /// Defaults to the value of [Title.title], if a [Title] widget can be found.
  /// Otherwise, defaults to [Platform.resolvedExecutable].
  final String applicationName;
  final List<Widget> actions;

  /// The version of this build of the application.
  ///
  /// This string is shown under the application name.
  ///
  /// Defaults to the empty string.
  final String applicationVersion;

  /// The icon to show next to the application name.
  ///
  /// By default no icon is shown.
  ///
  /// Typically this will be an [ImageIcon] widget. It should honor the
  /// [IconTheme]'s [IconThemeData.size].
  final Widget applicationIcon;

  /// A string to show in small print.
  ///
  /// Typically this is a copyright notice.
  ///
  /// Defaults to the empty string.
  final String applicationLegalese;

  /// Widgets to add to the dialog box after the name, version, and legalese.
  ///
  /// This could include a link to a Web site, some descriptive text, credits,
  /// or other information to show in the about box.
  ///
  /// Defaults to nothing.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));
    final String name = applicationName ?? _defaultApplicationName(context);
    final String version =
        applicationVersion ?? _defaultApplicationVersion(context);
    final Widget icon = applicationIcon ?? _defaultApplicationIcon(context);
    return WrappedMaterialDialog(
      context,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (icon != null)
                IconTheme(data: Theme.of(context).iconTheme, child: icon),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: ListBody(
                    children: <Widget>[
                      Text(name, style: Theme.of(context).textTheme.headline5),
                      Text(version,
                          style: Theme.of(context).textTheme.bodyText2),
                      Container(height: 18.0),
                      Text(applicationLegalese ?? '',
                          style: Theme.of(context).textTheme.caption),
                    ],
                  ),
                ),
              ),
            ],
          ),
          ...?children,
        ],
      ),
      actions: actions,
    );
  }
}

String _defaultApplicationName(BuildContext context) {
  // This doesn't handle the case of the application's title dynamically
  // changing. In theory, we should make Title expose the current application
  // title using an InheritedWidget, and so forth. However, in practice, if
  // someone really wants their application title to change dynamically, they
  // can provide an explicit applicationName to the widgets defined in this
  // file, instead of relying on the default.
  final Title ancestorTitle = context.findAncestorWidgetOfExactType<Title>();
  return ancestorTitle?.title ??
      Platform.resolvedExecutable.split(Platform.pathSeparator).last;
}

String _defaultApplicationVersion(BuildContext context) {
  return MyApp.VERSION;
}

Widget _defaultApplicationIcon(BuildContext context) {
  return null;
}
