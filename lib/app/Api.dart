import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

/// 网络请求Api
class Api {
  static String get rankUrl => linkUserUrl("m=index&a=HOT&limit=50&g=api/v3");

  static String detailUrl(String id) =>
      linkUserUrl("m=index&a=resource&rid=$id&g=api/v2");

  static String commentUrl(String id, String channel, int page) => linkUserUrl(
      "a=fetch&itemid=$id&channel=$channel&pagesize=16&page=$page&m=comment");

  static String resUrl(String id, String itemid, String channel, String season,
          String episode) =>
      linkUserUrl(
          "g=api/v2&m=index&a=resource_item&id=$id&season=$season&episode=$episode&itemid=$itemid");

  static Future<Map<String, dynamic>> loadRank() async {
    var res = await Dio().get(rankUrl);
    return res.data['data'];
  }

  static Future<Map<String, dynamic>> getDetail(String id) async {
    var res = await Dio().get(detailUrl(id));
    return res.data['data'];
  }

  static Future<List> loadComments(String id, String channel, int page) async {
    var res = await Dio().get(commentUrl(id, channel, page));
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
    var res = await Dio().get(resUrl(id, itemid, channel, season, episode));
    return res.data['data'];
  }

  static Future<List> myFavorites(int page) async {
    var res = await Dio().get(linkUserUrl(
        "g=api/v2&m=index&a=fav_list&ft=resource&page=$page&limit=20"));
    return res.data['data'] ?? [];
  }

  static Future<List> search(String query) async {
    var res = await Dio().get(linkUserUrl(""));
    return res.data['data'] ?? [];
  }

  static Future<Map> userInfo(String query) async {
    var res = await Dio().get(linkUserUrl("g=api/public&m=v2&a=userinfo"));
    return res.data['data'] ?? [];
  }

  static String linkUserUrl(String url) {
    return "http://a.zmzapi.com/index.php?accesskey=519f9cab85c8059d17544947k361a827&client=2&" +
        url;
    //uid & token
  }
}
