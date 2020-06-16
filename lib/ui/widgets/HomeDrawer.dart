import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_yyets/app/AppIcons.dart';
import 'package:flutter_yyets/model/provider/RRUser.dart';
import 'package:flutter_yyets/ui/widgets/visibility.dart';
import 'package:flutter_yyets/ui/widgets/wrapped_material_dialog.dart';
import 'package:flutter_yyets/utils/RRResManager.dart';
import 'package:flutter_yyets/utils/toast.dart';
import 'package:flutter_yyets/utils/tools.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import 'about.dart';

class HomeDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var user = Provider.of<RRUser>(context);
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DrawerHeader(
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
                      return WrappedMaterialDialog(
                        c,
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
              child: Column(
                children: [
                  Container(
                    height: 16,
                  ),
                  ClipOval(
                    child: Image.network(
                      user.avatar ?? "https://flutter.cn/favicon.ico",
                      width: 80,
                      height: 80,
                    ),
                  ),
                  Container(
                    height: 10,
                  ),
                  Text(user.name ?? "登录",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  RRUser.isLogin ? Text(MyApp.rrUser.email ?? "") : Container(),
                ],
              ),
            ),
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
                  onTap: () => Navigator.pushNamed(context, "/latest"),
                  leading: Icon(Icons.autorenew),
                  title: Text("最新资源"),
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
                        onTap: () => MyApp.appTheme.toggleTheme(),
                      ),
                ListTile(
                  onTap: () => _showAbout(context),
                  leading: Icon(Icons.info),
                  title: Text("关于"),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  _showAbout(context) {
    showCustomAboutDialog(
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
        Container(
          width: double.maxFinite,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FlatButton(
                child: Chip(
                  shadowColor: Colors.transparent,
                  backgroundColor: Colors.transparent,
                  avatar: Icon(AppIcons.github),
                  label: Text("  Github  "),
                ),
                onPressed: () =>
                    launchUri("https://github.com/Vove7/yyets_flutter"),
              ),
              Container(width: 10),
              FlatButton(
                child: Chip(
                  shadowColor: Colors.transparent,
                  backgroundColor: Colors.transparent,
                  avatar: Icon(Icons.history),
                  label: Text("检查更新"),
                ),
                onPressed: () {
                  toast("正在检查更新...");
                  checkUpgrade(context).then(
                    (hasUpgrade) {
                      if (!hasUpgrade) {
                        toast("已是最新版本");
                      }
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ],
      actions: [
        FlatButton(
          child: Text(
            "支持一下",
            style: TextStyle(color: Theme.of(context).accentColor),
          ),
          onPressed: () {
            _showSupportDialog(context);
          },
        ),
      ],
    );
  }

  _showSupportDialog(context) {
    showDialog(
      context: context,
      builder: (c) => WrappedMaterialDialog(
        c,
        children: [
          Text(""),
          ListTile(
            onTap: () {
              Navigator.pop(context);
              if (PlatformExt.isMobilePhone) {
                launchUri(
                    "https://qr.alipay.com/fkx10497j8a6bjbqjhe3qd8?t=1590064517265");
              } else {
                _showQrCodeDialog(c, 0);
              }
            },
            title: Text("支付宝"),
          ),
          ListTile(
            title: Text("微信"),
            onTap: () {
              Navigator.pop(context);
              _showQrCodeDialog(c, 1);
            },
          )
        ],
      ),
    );
  }

  _showQrCodeDialog(context, int what) {
    var donateWay = what == 0 ? "支付宝" : "微信";
    showDialog(
      context: context,
      builder: (c) =>
          WrappedMaterialDialog(c, title: Text("请使用${donateWay}扫码"), children: [
        Visible(
          visible: PlatformExt.isMobilePhone,
          childBuilder: () => Text("可截图到本地后扫码"),
        ),
        Image.asset(
            what == 0 ? "images/donate_alipay.jpg" : "images/donate_wx.jpg"),
      ]),
    );
  }
}
