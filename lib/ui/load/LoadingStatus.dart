import 'package:flutter/material.dart';

enum LoadingStatus { NONE, LOADING, NO_MORE, ERROR }

Widget getWidgetByLoadingStatus(LoadingStatus status, VoidCallback onRefresh,
    {String errText = "数据加载失败，点击重试"}) {
  switch (status) {
    case LoadingStatus.LOADING:
      return Center(child: CircularProgressIndicator());
    case LoadingStatus.ERROR:
      return Center(
        child: FlatButton(onPressed: onRefresh, child: Text(errText)),
      );
    case LoadingStatus.NO_MORE:
      return Center(
          child: Padding(
        padding: EdgeInsets.all(10),
        child: Text("---   到底了   ---"),
      ));
    case LoadingStatus.NONE:
      return Container();
  }
  return null;
}
