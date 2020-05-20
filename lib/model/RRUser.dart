import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_yyets/utils/mysp.dart';

class RRUser extends ChangeNotifier {
  String uid;
  String name;
  String email;
  String avatar;
  String token;
  String phone;
  String group;

  RRUser(
      {this.uid,
      this.name,
      this.avatar,
      this.email,
      this.token,
      this.phone,
      this.group}) {
    _init();
  }

  static bool isLogin = false;

  _init() async {
    var config = (await MySp).get("user_ins");
    if (config != null) {
      var map = json.decode(config);
      save(map, save: false);
    }
  }

  /// 不通知
  setUidAndToken(ui, tk) {
    uid = ui;
    token = tk;
  }

  void save(Map data, {bool save = true}) async {
    print(data);
    uid = data['uid'];
    name = data['nickname'];
    email = data["email"];
    group = data["group_name"];
    avatar = data['userpic'];
    token = data['token'];

    if (save) {
      (await MySp).set("user_ins", data);
    }
    isLogin = true;
    notifyListeners();
  }

  Future logout() {
    isLogin = false;
    uid = null;
    name = null;
    email = null;
    group = null;
    avatar = null;
    token = null;

    notifyListeners();
    return MySp.then((sp) {
      sp.remove("user_ins");
      sp.remove("uid");
      sp.remove("token");
    });
  }
}
