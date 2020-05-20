import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

Future<T> showAdjustableBottomSheet<T>({
  @required BuildContext context,
  @required WidgetBuilder builder,
  Color backgroundColor,
  double elevation,
  ShapeBorder shape,
  Clip clipBehavior,
  Color barrierColor,
  bool isScrollControlled = false,
  bool useRootNavigator = false,
  bool isDismissible = true,
  bool enableDrag = true,
  double heightP = 10.0 / 16,
}) async {
  assert(context != null);
  assert(builder != null);
  assert(isScrollControlled != null);
  assert(useRootNavigator != null);
  assert(isDismissible != null);
  assert(enableDrag != null);
  assert(debugCheckHasMediaQuery(context));
  assert(debugCheckHasMaterialLocalizations(context));

  return Navigator.of(context, rootNavigator: useRootNavigator)
      .push(_ModalBottomSheetRoute<T>(
    builder: builder,
    theme: Theme.of(context, shadowThemeOnly: true),
    isScrollControlled: isScrollControlled,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    backgroundColor: backgroundColor,
    elevation: elevation,
    shape: shape,
    clipBehavior: clipBehavior,
    isDismissible: isDismissible,
    modalBarrierColor: barrierColor,
    enableDrag: enableDrag,
    heightP: heightP,
  ));
}

const Duration _bottomSheetEnterDuration = Duration(milliseconds: 250);
const Duration _bottomSheetExitDuration = Duration(milliseconds: 200);
const Curve decelerateEasing = Cubic(0.0, 0.0, 0.2, 1.0);
const Curve _modalBottomSheetCurve = decelerateEasing;

class _ModalBottomSheetRoute<T> extends PopupRoute<T> {
  _ModalBottomSheetRoute({
    this.builder,
    this.theme,
    this.barrierLabel,
    this.backgroundColor,
    this.elevation,
    this.shape,
    this.clipBehavior,
    this.modalBarrierColor,
    this.isDismissible = true,
    this.enableDrag = true,
    this.heightP,
    @required this.isScrollControlled,
    RouteSettings settings,
  })  : assert(isScrollControlled != null),
        assert(isDismissible != null),
        assert(enableDrag != null),
        super(settings: settings);

  final WidgetBuilder builder;
  final ThemeData theme;
  final bool isScrollControlled;
  final Color backgroundColor;
  final double elevation;
  final ShapeBorder shape;
  final Clip clipBehavior;
  final Color modalBarrierColor;
  final bool isDismissible;
  final bool enableDrag;
  final double heightP;

  @override
  Duration get transitionDuration => _bottomSheetEnterDuration;

  @override
  Duration get reverseTransitionDuration => _bottomSheetExitDuration;

  @override
  bool get barrierDismissible => isDismissible;

  @override
  final String barrierLabel;

  @override
  Color get barrierColor => modalBarrierColor ?? Colors.black54;

  AnimationController _animationController;

  @override
  AnimationController createAnimationController() {
    assert(_animationController == null);
    _animationController =
        BottomSheet.createAnimationController(navigator.overlay);
    return _animationController;
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    final BottomSheetThemeData sheetTheme =
        theme?.bottomSheetTheme ?? Theme.of(context).bottomSheetTheme;
    // By definition, the bottom sheet is aligned to the bottom of the page
    // and isn't exposed to the top padding of the MediaQuery.
    Widget bottomSheet = MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: _ModalBottomSheet<T>(
        route: this,
        backgroundColor: backgroundColor ??
            sheetTheme?.modalBackgroundColor ??
            sheetTheme?.backgroundColor,
        elevation:
            elevation ?? sheetTheme?.modalElevation ?? sheetTheme?.elevation,
        shape: shape,
        clipBehavior: clipBehavior,
        isScrollControlled: isScrollControlled,
        enableDrag: enableDrag,
        heightP: heightP,
      ),
    );
    if (theme != null) bottomSheet = Theme(data: theme, child: bottomSheet);
    return bottomSheet;
  }
}

class _ModalBottomSheet<T> extends StatefulWidget {
  const _ModalBottomSheet({
    Key key,
    this.route,
    this.backgroundColor,
    this.elevation,
    this.shape,
    this.clipBehavior,
    this.isScrollControlled = false,
    this.enableDrag = true,
    this.heightP = 10.0 / 16,
  })  : assert(isScrollControlled != null),
        assert(enableDrag != null),
        super(key: key);

  final _ModalBottomSheetRoute<T> route;
  final bool isScrollControlled;
  final Color backgroundColor;
  final double elevation;
  final ShapeBorder shape;
  final Clip clipBehavior;
  final bool enableDrag;
  final double heightP;

  @override
  _ModalBottomSheetState<T> createState() => _ModalBottomSheetState<T>();
}

class _ModalBottomSheetState<T> extends State<_ModalBottomSheet<T>> {
  ParametricCurve<double> animationCurve = _modalBottomSheetCurve;

  String _getRouteLabel(MaterialLocalizations localizations) {
    switch (Theme.of(context).platform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return '';
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return localizations.dialogLabel;
    }
    return null;
  }

  void handleDragStart(DragStartDetails details) {
    // Allow the bottom sheet to track the user's finger accurately.
    animationCurve = Curves.linear;
  }

  void handleDragEnd(DragEndDetails details, {bool isClosing}) {
    // Allow the bottom sheet to animate smoothly from its current position.
    animationCurve = _BottomSheetSuspendedCurve(
      widget.route.animation.value,
      curve: _modalBottomSheetCurve,
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));
    assert(debugCheckHasMaterialLocalizations(context));
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);
    final String routeLabel = _getRouteLabel(localizations);

    return AnimatedBuilder(
      animation: widget.route.animation,
      builder: (BuildContext context, Widget child) {
        // Disable the initial animation when accessible navigation is on so
        // that the semantics are added to the tree at the correct time.
        final double animationValue = animationCurve.transform(
            mediaQuery.accessibleNavigation
                ? 1.0
                : widget.route.animation.value);
        return Semantics(
          scopesRoute: true,
          namesRoute: true,
          label: routeLabel,
          explicitChildNodes: true,
          child: ClipRect(
            child: CustomSingleChildLayout(
              delegate: _ModalBottomSheetLayout(
                  animationValue, widget.heightP, widget.isScrollControlled),
              child: BottomSheet(
                animationController: widget.route._animationController,
                onClosing: () {
                  if (widget.route.isCurrent) {
                    Navigator.pop(context);
                  }
                },
                builder: widget.route.builder,
                backgroundColor: widget.backgroundColor,
                elevation: widget.elevation,
                shape: widget.shape,
                clipBehavior: widget.clipBehavior,
                enableDrag: widget.enableDrag,
                onDragStart: handleDragStart,
                onDragEnd: handleDragEnd,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BottomSheetSuspendedCurve extends ParametricCurve<double> {
  /// Creates a suspended curve.
  const _BottomSheetSuspendedCurve(
    this.startingPoint, {
    this.curve = Curves.easeOutCubic,
  })  : assert(startingPoint != null),
        assert(curve != null);

  /// The progress value at which [curve] should begin.
  ///
  /// This defaults to [Curves.easeOutCubic].
  final double startingPoint;

  /// The curve to use when [startingPoint] is reached.
  final Curve curve;

  @override
  double transform(double t) {
    assert(t >= 0.0 && t <= 1.0);
    assert(startingPoint >= 0.0 && startingPoint <= 1.0);

    if (t < startingPoint) {
      return t;
    }

    if (t == 1.0) {
      return t;
    }

    final double curveProgress = (t - startingPoint) / (1 - startingPoint);
    final double transformed = curve.transform(curveProgress);
    return lerpDouble(startingPoint, 1, transformed);
  }

  @override
  String toString() {
    return '${describeIdentity(this)}($startingPoint, $curve)';
  }
}

class _ModalBottomSheetLayout extends SingleChildLayoutDelegate {
  double heightP = 9.0 / 16;

  _ModalBottomSheetLayout(this.progress, this.heightP, this.isScrollControlled);

  final double progress;
  final bool isScrollControlled;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints(
      minWidth: constraints.maxWidth,
      maxWidth: constraints.maxWidth,
      minHeight: 0.0,
      maxHeight: isScrollControlled
          ? constraints.maxHeight
          : constraints.maxHeight * heightP,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    return Offset(0.0, size.height - childSize.height * progress);
  }

  @override
  bool shouldRelayout(_ModalBottomSheetLayout oldDelegate) {
    return progress != oldDelegate.progress;
  }
}
