import 'dart:convert';

import 'package:flutter_yyets/utils/mysp.dart';

class RRUser {
  String uid;
  String name;
  String avatar;
  String token;

  RRUser({this.uid, this.name, this.avatar, this.token});

  static RRUser _ins;

  static Future<RRUser> get instance async {
    if (_ins == null) {
      var config = (await MySp).get("user_ins", defaultValue: null);
      if(config==null) {
        var map = json.decode(config);
        save(map);
      }
    }
    return _ins;
  }

  static void save(Map data) {
    _ins = RRUser(
        uid: data['uid'],
        name: data['name'],
        avatar: data['avatar'],
        token: data['token']);
  }

  static Future<bool> get isLogin async => (await instance) != null;
}
