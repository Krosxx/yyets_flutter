import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_yyets/model/RRUser.dart';
import 'package:flutter_yyets/utils/mysp.dart';

/// 网络请求Api
class Api {
  static Dio _dioClient;

  static Dio get dioClient {
    if (_dioClient == null) {
      _dioClient = Dio();
      _dioClient.interceptors.add(
        InterceptorsWrapper(onError: (e) {
          print("dio err: " + e.toString());
        }, onResponse: (res) {
          try {
            var status = res.data["status"];
            if (status != null) {
              if (status != 1) {
                print("status err: " + res.data);
              } else {
//                print("dio data: ${res.data['data']}");
              }
            }
          } catch (e) {
            print("234" + e.toString());
          }
        }, onRequest: (RequestOptions options) {
          _dioClient.lock();
          String uid;
          String token;
          RRUser.instance.then((value) async {
            if (value != null) {
              uid = value.uid;
              token = value.token;
            } else {
              var sp = await MySp;
              if (sp.has("uid")) {
                uid = sp.get("uid");
                token = sp.get("token");
              }
            }
            if (uid != null) {
              options.queryParameters.addAll({"uid": uid, "token": token});
            }
            print(options.uri);
          }).whenComplete(() => _dioClient.unlock());
        }),
      );
    }
    return _dioClient;
  }

  static Future<String> get rankUrl =>
      linkUserUrl("m=index&a=HOT&limit=50&g=api/v3");

  static Future<String> detailUrl(String id) =>
      linkUserUrl("m=index&a=resource&rid=$id&g=api/v2");

  static Future<String> commentUrl(String id, String channel, int page) =>
      linkUserUrl(
          "a=fetch&itemid=$id&channel=$channel&pagesize=16&page=$page&m=comment");

  static Future<String> resUrl(String id, String itemid, String channel,
          String season, String episode) =>
      linkUserUrl(
          "g=api/v2&m=index&a=resource_item&id=$id&season=$season&episode=$episode&itemid=$itemid");

  static Future<Map<String, dynamic>> loadRank() async {
    var res = await dioClient.get(await rankUrl);
    return res.data['data'];
  }

  static Future<Map<String, dynamic>> getDetail(String id) async {
    var url = detailUrl(id);
    var res = await dioClient.get(await url);
    return res.data['data'];
  }

  static Future<List> loadComments(String id, String channel, int page) async {
    var res = await dioClient.get(await commentUrl(id, channel, page));
    return (res.data['data'] ?? {})['list'] ?? [];
  }

  ///
  /// movie  id itemid
  /// tv epi  season id
  ///
  static Future<Map> getResInfo(
      {@required String id,
      String uid = "",
      String itemid = "",
      String channel = "",
      String season = "",
      String episode = ""}) async {
    var res =
        await dioClient.get(await resUrl(id, itemid, channel, season, episode));
    return res.data['data'];
  }

  static Future<List> myFavorites(int page, {int limit = 20}) async {
    var res = await dioClient.get(await linkUserUrl(
        "g=api/v2&m=index&a=fav_list&ft=resource&page=$page&limit=$limit"));
    return res.data['data'] ?? [];
  }

  static Future<List> search(String query, int page) async {
    var res = await dioClient.get(await linkUserUrl(
        "st=resource&a=search&g=api%2Fv2&limit=10&k=$query&page=$page&m=index"));
    return res.data['data']["list"] ?? [];
  }

  static Future<Map> userInfo() async {
    var res =
        await dioClient.get(await linkUserUrl("g=api/public&m=v2&a=userinfo"));
    return res.data['data'] ?? [];
  }

  static Future<Map> login(String text, String pass) {
    if (text.length == 11 && RegExp(r"1[0-9]\d{9}$").hasMatch(text)) {
      return _loginWithPhone(text, pass);
    } else {
      return _loginWithAccount(text, pass);
    }
  }

  static Future<Map> _loginWithAccount(String account, String pass) async {
    String id = "";
    var ran = Random();
    for (int i = 0; i < 19; i++) {
      id += ran.nextInt(9).toString();
    }
    var res = await dioClient.get(await linkUserUrl(
        "g=api/public&m=v2&a=login&account=$account&password=$pass&registration_id=$id"));
    var data = res.data['data'];
    if (data == null || data == '') {
      throw Exception(res.data["info"]);
    }
    return data;
  }

  ///
  /// 手机号登录
  /// area 暂时只支持中国
  static Future<Map> _loginWithPhone(String phone, String pass,
      {String area = "86"}) async {
    var res = await dioClient.get(await linkUserUrl(
        "g=api/public&m=v2&a=mobile_login&area=$area&mobile=$phone&password=$pass"));
    var data = res.data['data'];
    if (data == null || data == '') {
      throw Exception(res.data["info"]);
    }
    return data;
  }

  /// @return token uid
  static Future<Map> register(
      String username, String email, String pass) async {
    FormData formData = new FormData.fromMap({
      "email": email,
      "nickname": username,
      "password": pass,
      "repassword": pass,
    });
    var res = await dioClient.post(
        await linkUserUrl("g=api/public&m=v2/a=register"),
        data: formData);
    var data = res.data['data'];
    if (data == null) {
      throw Exception(res.data["info"]);
    }
    return data;
  }

  //统一 accKey  client
  static Future<String> linkUserUrl(String url) async {
    return "http://a.zmzapi.com/index.php?accesskey=519f9cab85c8059d17544947k361a827&client=2&" +
        url;
    //uid & token
  }
}
