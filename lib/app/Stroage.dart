import 'dart:io';

import 'package:hive/hive.dart';

var _box;

Future<Box> waitBox() async {
  if (_box == null) {
    if(Platform.isWindows){
      await Hive.init("hive");
    }
    _box = await Hive.openBox("box");
  }
  return _box;
}

Future<List<String>> getQueryHistory() async {
  String qhs = (await waitBox()).get("query_history") ?? "";
  return qhs.split("|#|");
}

Future<List<String>> querySuggest(String qy) async {
  List<String> qh = await getQueryHistory();
  qh.retainWhere((element) => element.contains(qy));
  return qh;
}

addQueryHistory(String qy) async {
  List<String> qh = await getQueryHistory();
  qh.add(qy);
  (await waitBox()).put("query_history", qh.join('|#|'));
}
