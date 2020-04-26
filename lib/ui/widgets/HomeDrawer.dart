import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_yyets/app/AppIcons.dart';
import 'package:flutter_yyets/model/RRUser.dart';
import 'package:flutter_yyets/utils/RRResManager.dart';
import 'package:flutter_yyets/utils/toast.dart';
import 'package:flutter_yyets/utils/tools.dart';

import '../../main.dart';

class HomeDrawer extends StatefulWidget {
  @override
  State createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
  RRUser user;

  @override
  void initState() {
    super.initState();
    RRUser.instance.then((value) {
      setState(() {
        user = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DrawerHeader(
              padding: EdgeInsets.all(0),
              margin: EdgeInsets.all(0),
              child: InkWell(
                onTap: () {
                  if (user == null) {
                    Scaffold.of(context).openEndDrawer();
                    Navigator.pushNamed(context, "/login");
                  } else {
                    showDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (c) {
                        return AlertDialog(
                          title: Text("退出登录?"),
                          actions: [
                            FlatButton(
                              child: Text("确定"),
                              onPressed: () {
                                setState(() {
                                  user = null;
                                });
                                RRUser.logout();
                                Navigator.pop(context);
                              },
                            ),
                            FlatButton(
                              child: Text("取消"),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                child: Column(children: [
                  Container(
                    height: 16,
                  ),
                  ClipOval(
                    child: Image.network(
                      user?.avatar ?? "https://flutter.cn/favicon.ico",
                      width: 80,
                      height: 80,
                    ),
                  ),
                  Container(
                    height: 10,
                  ),
                  Text(user?.name ?? "登录",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  user == null ? Container() : Text(user.email),
                ]),
              )),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: Icon(Icons.favorite),
                  title: Text("我的收藏"),
                  onTap: () {
                    Scaffold.of(context).openEndDrawer();
                    RRUser.isLogin.then(
                      (value) {
                        if (value) {
                          Navigator.pushNamed(context, "/favorites");
                        } else {
                          toast("请先登录");
                          Navigator.pushNamed(context, "/login");
                        }
                      },
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.file_download),
                  title: Text("下载管理"),
                  onTap: () {
                    if (RRResManager.checkPlatform()) {
                      Scaffold.of(context).openEndDrawer();
                      Navigator.pushNamed(context, "/download");
                    }
                  },
                ),
                isMobilePhone
                    ? Container()
                    : ListTile(
                        leading: Icon(Icons.palette),
                        title: Text("切换主题"),
                        onTap: () => AppState.toggleTheme(),
                      ),
                ListTile(
                  onTap: () =>
                      launchUri("https://github.com/Vove7/yyets_flutter"),
                  leading: Icon(AppIcons.github),
                  title: Text("Github"),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
