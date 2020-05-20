import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_yyets/app/Api.dart';
import 'package:flutter_yyets/model/RRUser.dart';
import 'package:flutter_yyets/utils/mysp.dart';
import 'package:flutter_yyets/utils/toast.dart';
import 'package:flutter_yyets/utils/tools.dart';
import 'package:provider/provider.dart';

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
    webUserHint();
  }

  void webUserHint() {
    if (PlatformExt.isWeb) {
      Future.delayed(
        Duration(seconds: 1),
        () {
          if (!mounted) return;
          showDialog(
            context: context,
            builder: (c) => AlertDialog(
              title: Text("提示"),
              content: Text("由于浏览器存在跨域问题，此web app使用bird.ioliu.cn作为代理。\n"
                  "您需要了解的是：yyets原生登录接口采用明文传输，若您使用此方式登录造成损失，此App将不负任何责任。感谢理解！"),
              actions: [
                FlatButton(
                  onPressed: () => Navigator.pop(c),
                  child: Text("我知道了"),
                ),
                FlatButton(
                  onPressed: () {
                    Navigator.pop(c);
                    Navigator.pop(context);
                  },
                  child: Text("不登录了"),
                ),
              ],
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: Center(
        child: Card(
            color: context.isDarkMode ? Colors.black87 : Colors.white,
            elevation: 10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Form(
                key: _formKey,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Container(
                    width: 250,
                    height: 350,
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
                                onPressed: () => toast("TODO")
//                                  Navigator.pushNamed(context, "/register"),
                                ),
                            FlatButton(
                              child: Text("忘记密码"),
                              onPressed: () => launchUri(
                                  "http://www.rrys2019.com/user/password/forgot"),
                            ),
                          ],
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Center(
                            child: RaisedButton(
                                elevation: 10,
                                child: Text(
                                  "登录",
                                  style: TextStyle(color: Colors.white),
                                ),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                onPressed: _login),
                          ),
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
      Provider.of<RRUser>(context, listen: false)
          .setUidAndToken(data['uid'], data['token']);
      return Api.userInfo();
    }).then((data) {
      return Provider.of<RRUser>(context, listen: false).save(data);
    }).then((value) {
      toast("登录成功");
      Navigator.pop(context);
    }).catchError((e) {
      print(e);
      toast(e.message);
    });
  }
}
