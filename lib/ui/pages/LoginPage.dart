import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  State createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: Center(
        child: Card(
            elevation: 10,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: EdgeInsets.all(30),
              child: Container(
                  width: 250,
                  height: 300,
                  child: Column(
                    children: <Widget>[
                      TextField(),
                      TextField(),
                      RaisedButton(
                          elevation: 10,
                          child: Text("登录"),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          onPressed: _login)
                    ],
                  )),
            )),
      ),
    );
  }

  void _login() {}
}
