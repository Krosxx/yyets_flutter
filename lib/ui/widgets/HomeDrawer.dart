import 'package:flutter/material.dart';
import 'package:flutter_yyets/model/RRUser.dart';
import 'package:flutter_yyets/utils/toast.dart';

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
    print("build drawer");
    return Drawer(
        child: MediaQuery.removePadding(
      removeTop: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 10,
          ),
          ListTile(
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
            leading: ClipOval(
              child: Image.network(
                  user?.avatar ?? "https://flutter.cn/favicon.ico"),
            ),
            title: Text(
              user?.name ?? "登录",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: user == null ? null : Text(user.email),
          ),
          Container(
            height: 10,
          ),
          Expanded(
            child: ListView(children: [
              ListTile(
                leading: Icon(Icons.favorite),
                title: Text("我的收藏"),
                onTap: () {
                  RRUser.isLogin.then((value) {
                    if (value) {
                      Scaffold.of(context).openEndDrawer();
                      Navigator.pushNamed(context, "/favorites");
                    } else {
                      toast("请先登录");
                      Navigator.pushNamed(context, "/login");
                    }
                  });
                },
              ),
              ListTile(
                leading: Icon(Icons.adb),
                title: Text("边下边播"),
                onTap: () {
                  toast("TODO");
                },
              )
            ]),
          )
        ],
      ),
      context: context,
    ));
  }
}
