import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class BottomInputDialog extends StatelessWidget {
  final String actionText;
  final Widget title;
  final TextEditingController _textEditingController = TextEditingController();

  BottomInputDialog(this.actionText, this.title);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: <Widget>[
          Expanded(
              child: new GestureDetector(
            child: new Container(
              color: Colors.transparent,
            ),
            onTap: () {
              Navigator.pop(context);
            },
          )),
          Container(
            decoration: BoxDecoration(
                color: Theme.of(context).bottomAppBarColor,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10))),
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: title,
                    ),
                    Container(
                      padding: EdgeInsets.all(5),
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(Icons.close),
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 10,
                ),
                TextField(
                  controller: _textEditingController,
                  decoration: null,
                  autofocus: true,
                  maxLines: 3,
                  maxLength: 200,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    RaisedButton(
                      child: Text(actionText,style: TextStyle(color: Colors.white),),
                      onPressed: () {
                        String text = _textEditingController.text;
                        if (!text.isEmpty) {
                          Navigator.pop(context, text);
                        }
                      },
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PopRoute extends PopupRoute {
  final Duration _duration = Duration(milliseconds: 100);
  Widget child;

  PopRoute({@required this.child});

  @override
  Color get barrierColor => Colors.black26;

  @override
  bool get barrierDismissible => true;

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }

  @override
  String get barrierLabel => null;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return child;
  }

  @override
  Duration get transitionDuration => _duration;
}
