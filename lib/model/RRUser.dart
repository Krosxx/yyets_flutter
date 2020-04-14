import 'dart:convert';

import 'package:flutter_yyets/utils/mysp.dart';

class RRUser {
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
      this.group});

  static RRUser _ins;

  static Future<RRUser> get instance async {
    if (_ins == null) {
      var config = (await MySp).get("user_ins");
      if (config != null) {
        var map = json.decode(config);
        save(map, save: false);
      }
    }
    return _ins;
  }

  static void save(Map data, {bool save = true}) async {
    print(data);
    _ins = RRUser(
      uid: data['uid'],
      name: data['nickname'],
      email: data["email"],
      group: data["group_name"],
      avatar: data['userpic'],
      token: data['token'],
    );
    if (save) {
      (await MySp).set("user_ins", data);
    }
  }

  static Future<bool> get isLogin async => (await instance) != null;

  static Future logout() {
    _ins = null;
    return MySp.then((sp) {
      sp.remove("user_ins");
      sp.remove("uid");
      sp.remove("token");
    });
  }
}
