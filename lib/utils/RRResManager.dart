import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_yyets/utils/toast.dart';

class RRResManager {
  static var methodChannel = MethodChannel("cn.vove7.flutter_yyets/channel");

  static Future getAllItems() async {
    return jsonDecode(await methodChannel.invokeMethod("getAllItems"));
  }

  static bool get supportDownload => Platform.isAndroid;

  static Future<bool> addTask(
    String id,
    String filmName,
    String rrUri,
    String season,
    String episode,
    String filmImg,
  ) async {
    Map data = parseRRUri(rrUri);
    data['filmId'] = id;
    data['p4pUrl'] = rrUri;
    data['filmImg'] = filmImg;
    print(data);
    if (!Platform.isAndroid) {
      toast("边下边播仅支持安卓系统");
      return false;
    }
    methodChannel.invokeMethod("startDownload", data).then((result) {
      print(result);
    });
    return true;
  }

  static Future resumeByFileId(String fileId) {
    return methodChannel.invokeMethod("resumeByFileId", fileId);
  }

  static Future pauseByFileId(String fileId) {
    return methodChannel.invokeMethod("pauseByFileId", fileId);
  }

  static Future pauseAll() {
    return methodChannel.invokeMethod("pauseAll");
  }

  static Future resumeAll() {
    return methodChannel.invokeMethod("resumeAll");
  }

  static Future getStatus(Map bean) {
    return methodChannel.invokeMethod("getStatus", bean);
  }

  //yyets://N=....mp4|S=....|H=.....|
  static Map parseRRUri(String rrUri) {
    String s = rrUri.substring(8, rrUri.length - 1);
    var ks = {"H": "fileId", "S": "size", "N": "fileName"};
    var data = {};
    s.split('|').forEach((item) {
      List ss = item.split('=');
      data[ks[ss[0]]] = ss[1];
    });
    return data;
  }
}
