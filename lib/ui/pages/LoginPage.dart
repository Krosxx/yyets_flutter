import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_yyets/app/Api.dart';
import 'package:flutter_yyets/model/RRUser.dart';
import 'package:flutter_yyets/utils/mysp.dart';
import 'package:flutter_yyets/utils/toast.dart';
import 'package:flutter_yyets/utils/url_utils.dart';

class LoginPage extends StatefulWidget {
  @override
  State createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController _nameController;
  TextEditingController _passController;
  bool _isShowClear = false;
  bool _isShowPwd = false;

  //焦点
  FocusNode _focusNodeName = new FocusNode();
  FocusNode _focusNodePassWord = new FocusNode();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _nameController.addListener(() {
      bool old = _isShowClear;
      _isShowClear = _nameController.text.isNotEmpty;
      print(_isShowClear);
      if (old != _isShowClear) {
        setState(() {});
      }
    });
    _passController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: Center(
        child: Card(
            elevation: 10,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Form(
                key: _formKey,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Container(
                    width: 250,
                    height: 300,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        TextFormField(
                          focusNode: _focusNodeName,
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: "用户名/邮箱/手机号(中国)",
                            prefixIcon: Icon(Icons.person),
                            //尾部添加清除按钮
                            suffixIcon: (_isShowClear)
                                ? IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: () {
                                // 清空输入框内容
                                _nameController.clear();
                              },
                            )
                                : null,
                          ),
                          validator: (s) {
                            if (s.isEmpty) {
                              return "不可空";
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          focusNode: _focusNodePassWord,
                          controller: _passController,
                          obscureText: !_isShowPwd,
                          validator: (s) {
                            if (s.isEmpty) {
                              return "不可空";
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: "密码",
                            prefixIcon: Icon(Icons.lock),
                            // 是否显示密码
                            suffixIcon: IconButton(
                              icon: Icon((_isShowPwd)
                                  ? Icons.visibility
                                  : Icons.visibility_off),
                              // 点击改变显示或隐藏密码
                              onPressed: () {
                                setState(() {
                                  _isShowPwd = !_isShowPwd;
                                });
                              },
                            ),
                          ),
                        ),
                        Container(
                          height: 20,
                        ),
                        Row(
                          children: [
                            FlatButton(
                              child: Text("注册"),
                              onPressed: () =>
                                  Navigator.pushNamed(context, "/regidter"),
                            ),
                            FlatButton(
                              child: Text("忘记密码"),
                              onPressed: () =>
                                  launchUri(
                                      "http://www.rrys2019.com/user/password/forgot"),
                            ),
                          ],
                        ),
                        Center(
                          child: RaisedButton(
                              elevation: 10,
                              child: Text("登录"),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              onPressed: _login),
                        ),
                        Container(
                          height: 5,
                        ),
                        Center(
                          child: IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ))),
      ),
    );
  }

  void _login() {
    _focusNodeName.unfocus();
    _focusNodePassWord.unfocus();
    if (!_formKey.currentState.validate()) {
      return;
    }
    Api.login(_nameController.text, _passController.text).then((data) async {
      //uid token
      var sp = await MySp;
      sp.set("uid", data['uid']);
      sp.set("token", data['token']);
      return Api.userInfo();
    }).then((data) {
      return RRUser.save(data);
    }).then((value) {
      toast("登录成功");
      Navigator.pop(context);
    }).catchError((e) {
      print(e);
      toast(e.message);
    });
  }
}
