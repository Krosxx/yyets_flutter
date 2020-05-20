import 'package:flutter/cupertino.dart';

///
/// How to 更好地控制显隐？
///
class Visible extends StatelessWidget {
  final bool visible;

  final Function childBuilder;

  const Visible({Key key, @required this.visible, @required this.childBuilder})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (visible) {
      return childBuilder();
    } else {
      return Container();
    }
  }
}
