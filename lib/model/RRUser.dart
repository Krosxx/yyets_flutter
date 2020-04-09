import 'package:hive/hive.dart';

@HiveType()
class RRUser {
  @HiveField(0)
  String uid;
  @HiveField(1)
  String name;
  @HiveField(2)
  String avatar;
  @HiveField(3)
  String token;

  RRUser(this.uid, this.name, this.avatar, this.token);

  static RRUser _ins;

  static Future<RRUser> get instance async {
    if (_ins == null) {
      var box = await Hive.openBox('box');
      _ins = box.get("user_ins");
    }
    return _ins;
  }

  static void save(Map data) {
    _ins = RRUser(data['uid'], data['name'], data['avatar'], data['token']);
    Hive.openBox("box").then((box) {
      box.put('user_ins', _ins);
    });
  }

  static bool get isLogin => instance != null;
}
