import 'package:flutter/material.dart';
import 'package:flutter_yyets/model/RRUser.dart';
import 'package:flutter_yyets/utils/toast.dart';

class HomeDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: MediaQuery.removePadding(
      removeTop: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: Color.fromARGB(0, 0, 0, 0),
            child: Image.network("https://flutter.cn/favicon.ico"),
          ),
          Expanded(
            child: ListView(children: [
              ListTile(
                leading: Icon(Icons.adb),
                title: Text("我的收藏"),
                onTap: () {
                  RRUser.isLogin.then((value) {
                    if (value) {
                      Navigator.pushNamed(context, "/favorites");
                    } else {
                      showToast("请先登录");
                      Navigator.pushNamed(context, "/login");
                    }
                  });
                },
              ),
              ListTile(
                leading: Icon(Icons.adb),
                title: Text("边下边播"),
                onTap: () {
                  showToast("TODO");
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
