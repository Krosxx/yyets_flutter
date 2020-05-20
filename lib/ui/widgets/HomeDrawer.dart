import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_yyets/app/AppIcons.dart';
import 'package:flutter_yyets/model/RRUser.dart';
import 'package:flutter_yyets/utils/RRResManager.dart';
import 'package:flutter_yyets/utils/toast.dart';
import 'package:flutter_yyets/utils/tools.dart';
import 'package:provider/provider.dart';

import '../../main.dart';

class HomeDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print("build drawer");
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Consumer<RRUser>(
            builder: (c, user, _) {
              return DrawerHeader(
                padding: EdgeInsets.all(0),
                margin: EdgeInsets.all(0),
                child: InkWell(
                  onTap: () {
                    if (!RRUser.isLogin) {
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
                                  user.logout();
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
                    RRUser.isLogin ? Text(user.email ?? "") : Container(),
                  ]),
                ),
              );
            },
          ),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: Icon(Icons.favorite),
                  title: Text("我的收藏"),
                  onTap: () {
                    Scaffold.of(context).openEndDrawer();
                    if (RRUser.isLogin) {
                      Navigator.pushNamed(context, "/favorites");
                    } else {
                      toast("请先登录");
                      Navigator.pushNamed(context, "/login");
                    }
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
                PlatformExt.isMobilePhone
                    ? Container()
                    : ListTile(
                        leading: Icon(Icons.palette),
                        title: Text("切换主题"),
                        onTap: () => AppState.toggleTheme(),
                      ),
                ListTile(
                  onTap: () => _showAbout(context),
                  leading: Icon(Icons.info),
                  title: Text("关于"),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  _showAbout(context) {
    //todo hide action buttons
    showAboutDialog(
      context: context,
      applicationIcon: FlutterLogo(
        size: 80,
      ),
      useRootNavigator: true,
      applicationName: "YYeTs for Flutter",
      applicationVersion: MyApp.VERSION,
      applicationLegalese: "copyright Vove.\n仅供学习交流使用",
      children: [
        Container(height: 20),
        FlatButton(
          padding: EdgeInsets.all(0),
          child: Chip(
            shadowColor: Colors.transparent,
            backgroundColor: Colors.transparent,
            avatar: Icon(Icons.history),
            label: Text("检查更新"),
          ),
          onPressed: () {
            toast("正在检查更新...");
            checkUpgrade(context).then((hasUpgrade) {
              if (!hasUpgrade) {
                toast("已是最新版本");
              }
            });
          },
        ),
        FlatButton(
          padding: EdgeInsets.all(0),
          child: Chip(
            shadowColor: Colors.transparent,
            backgroundColor: Colors.transparent,
            avatar: Icon(AppIcons.github),
            label: Text("  Github  "),
          ),
          onPressed: () => launchUri("https://github.com/Vove7/yyets_flutter"),
        )
      ],
    );
  }
}
