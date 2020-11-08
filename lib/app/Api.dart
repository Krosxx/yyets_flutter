import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_yyets/main.dart';
import 'package:flutter_yyets/utils/tools.dart';

/// 网络请求Api
class Api {
  static Dio _dioClient;

  static Dio get dioClient {
    if (_dioClient == null) {
      _dioClient = Dio();
      _dioClient.interceptors.add(
        InterceptorsWrapper(
          onError: (e) {
            print("dio err: " + e.toString());
          },
          onResponse: (res) {
            try {
              var status = res.data["status"];
              if (status != null) {
                if (status != 1) {
                  print("status err: " + res.data.toString());
                } else {
//                print("dio data: ${res.data['data']}");
                }
              }
            } catch (e) {
              print("error" + e.toString());
            }
          },
          onRequest: (RequestOptions options) {
            if (MyApp.rrUser.uid != null) {
              options.queryParameters.addAll(
                {"uid": MyApp.rrUser.uid, "token": MyApp.rrUser.token},
              );
            }
            print(options.uri);
          },
        ),
      );
    }
    return _dioClient;
  }

  static String get rankUrl => linkUrl("m=index&a=HOT&limit=100&g=api/v3");

  static String detailUrl(String id) =>
      linkUrl("m=index&a=resource&rid=$id&g=api/v2");

  static String commentUrl(String id, String channel, int page) => linkUrl(
      "a=fetch&itemid=$id&channel=$channel&pagesize=20&page=$page&m=comment");

  static String resUrl(String id, String itemid, String channel, String season,
          String episode) =>
      linkUrl(
          "g=api/v2&m=index&a=resource_item&id=$id&season=$season&episode=$episode&itemid=$itemid");

  static Future<Map<String, dynamic>> loadRank() async {
    var res = await dioClient.get(rankUrl);
    return res.data['data'];
  }

  static Future<Map<String, dynamic>> getDetail(String id) async {
    var url = detailUrl(id);
    var res = await dioClient.get(url);
    return res.data['data'];
  }

  static Future<List> loadComments(String id, String channel, int page) async {
    var res = await dioClient.get(commentUrl(id, channel, page));
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
    var res = await dioClient.get(resUrl(id, itemid, channel, season, episode));
    if (res.data["status"] != 1) {
      throw Exception(res.data["info"]);
    }
    return res.data['data'];
  }

  static Future<List> myFavorites(int page, {int limit = 20}) async {
    var res = await dioClient.get(linkUrl(
        "g=api/v2&m=index&a=fav_list&ft=resource&page=$page&limit=$limit"));
    return res.data['data'] ?? [];
  }

  static Future<List> search(String query, int page) async {
    var res = await dioClient.get(linkUrl(
        "st=resource&a=search&g=api%2Fv2&limit=10&k=$query&page=$page&m=index"));
    return res.data['data']["list"] ?? [];
  }

  static Future<Map> userInfo() async {
    var res = await dioClient.get(linkUrl("g=api/public&m=v2&a=userinfo"));
    return res.data['data'] ?? [];
  }

  static Future<Map> login(String text, String pass) {
    if (text.length == 11 && RegExp(r"1[0-9]\d{9}$").hasMatch(text)) {
      return _loginWithPhone(text, pass);
    } else {
      return _loginWithAccount(text, pass);
    }
  }

  static Future<Map> register(
      String email, String nickname, String pass) async {
    //http://a.zmzapi.com/index.php?g=api/public&m=v2&
    // accesskey=519f9cab85c8059d17544947k361a827&client=2&
    // a=register&email=$email&nickname=$nickname&password=$pass&repassword=$pass

    var res = await dioClient
        .get(linkUrl("g=api/public&m=v2&a=register&email=$email&nickname="
            "$nickname&password=$pass&repassword=$pass"));

    var data = res.data['data'];
    if (data == null || data == '') {
      throw Exception(res.data["info"]);
    }
    data['uid'] = data['uid'].toString();
    return data;
  }

  static Future<Map> _loginWithAccount(String account, String pass) async {
    String id = "";
    var ran = Random();
    for (int i = 0; i < 19; i++) {
      id += ran.nextInt(9).toString();
    }
    var res = await dioClient.get(linkUrl(
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
    var res = await dioClient.get(linkUrl(
        "g=api/public&m=v2&a=mobile_login&area=$area&mobile=$phone&password=$pass"));
    var data = res.data['data'];
    if (data == null || data == '') {
      throw Exception(res.data["info"]);
    }
    return data;
  }

  static Future<bool> isFollow(String id) async {
    var res = await dioClient
        .get(linkUrl("g=api/v2&m=index&a=fav_check_follow&id=$id&ft=resource"));
    try {
      return res.data['data'] == "1";
    } catch (e) {
      return false;
    }
  }

  ///收藏
  static Future<bool> follow(String id) async {
    var res = await dioClient
        .get(linkUrl("g=api/v2&m=index&a=fav_follow&id=$id&ft=resource"));
    return res.data["status"] == 1;
  }

  ///收藏
  static Future<bool> unFollow(String id) async {
    var res = await dioClient
        .get(linkUrl("g=api/v2&m=index&a=fav_unfollow&id=$id&ft=resource"));
    return res.data["status"] == 1;
  }

  static Future<Map> commentUser(
      String replyId, String itemId, String content, String channel) async {
    var res = await dioClient.get(linkUrl(
        "m=comment&a=save&channel=$channel&itemid=$itemId&content=$content&replyid=$replyId"));

    if (res.data['status'] == 1) {
      return res.data['data'];
    } else {
      throw Exception(res.data['info']);
    }
  }

  static Future<bool> commentGood(String commentId) async {
    var res =
        await dioClient.get(linkUrl("m=comment&a=good&id=$commentId&thread=1"));
    return res.data['status'] == 1;
  }

  static Future<bool> commentBad(String commentId) async {
    var res =
        await dioClient.get(linkUrl("m=comment&a=bad&id=$commentId&thread=1"));
    return res.data['status'] == 1;
  }

  static String wrapUrl(String url) {
    if (PlatformExt.isWeb) {
      //转发api跨域问题
      return "https://bird.ioliu.cn/v1?url=$url";
    } else {
      return url;
    }
  }

  //统一 accKey  client
  static String linkUrl(String url) {
    String baseUrl = wrapUrl("http://a.zmzapi.com");
    String linkUrl =
        "${baseUrl}/index.php/?accesskey=519f9cab85c8059d17544947k361a827&client=2&" +
            url;
    return linkUrl;
  }

  static Future<Map> commentTvOrMovie(
      String id, String channel, String text) async {
    var res = await dioClient.get(linkUrl(
        "m=comment&a=save&channel=$channel&itemid=$id&content=$text&replyid=0&thread=1"));
    print(res.data);

    if (res.data['status'] == 1) {
      res.data['data']['dateline'] = res.data['data']['dateline'].toString();
      return res.data['data'];
    } else {
      throw Exception(res.data['info']);
    }
  }

  static Future<Map> checkUpgrade() async {
    var res = await dioClient.get(
        "https://gitee.com/api/v5/repos/vove/yyets_flutter/releases/latest");
    return res.data;
  }

  static Future<bool> rating(rid, String score) async {
    var res = await dioClient
        .get(linkUrl("g=api/v2&m=index&a=score_post&rid=$rid&score=$score"));
    if (res.data['status'] == 1) {
      return true;
    } else {
      throw Exception(res.data['info'] ?? "评分失败，稍后再试");
    }
  }

  static Future<String> myRatingScore(rid) async {
    var res =
        await dioClient.get(linkUrl("g=api/v2&m=index&a=my_score&rid=$rid"));
    if (res.data['status'] == 1) {
      return res.data['data']['score'];
    } else {
      return null;
    }
  }

  static Future<List> news(int page) async {
    var res = await dioClient
        .get(linkUrl("g=api/v2&m=index&a=new_article_list&page=$page"));
    return res.data['data'];
  }

  static Future<List> latestResource(int page) async {
    var res =
        await dioClient.get(wrapUrl("http://file.apicvn.com/file/list?page=$page"));
    return res.data ?? [];
  }

  static Future<List> queryRRResource(String query, int page) async {
    var res = await dioClient
        .get(wrapUrl("http://file.apicvn.com/file/search?keyword=$query&page=$page"));
    return res.data ?? [];
  }
}
