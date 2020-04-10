import 'package:flutter_yyets/utils/mysp.dart';

Future<List<String>> getQueryHistory() async {
  String qhs = (await MySp).get("query_history") ?? "";
  if (qhs == "") {
    return [];
  } else {
    return qhs.split(_LIST_SEP);
  }
}

var _LIST_SEP = "|#|"; //分隔符

Future<List<String>> querySuggest(String qy) async {
  List<String> qh = await getQueryHistory();
  qh.retainWhere((element) => element.contains(qy));
  return qh;
}

addQueryHistory(String qy) async {
  Set qh = Set<String>();
  qh.addAll(await getQueryHistory());
  qh.add(qy);
  (await MySp).set("query_history", qh.join(_LIST_SEP));
}

deleteQueryHistory(String q) async {
  Set qh = Set<String>();
  qh.addAll(await getQueryHistory());
  qh.remove(q);
  (await MySp).set("query_history", qh.join(_LIST_SEP));
}
