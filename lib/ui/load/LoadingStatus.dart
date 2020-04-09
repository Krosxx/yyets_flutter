import 'package:flutter/material.dart';

enum LoadingStatus { NONE, LOADING, NO_MORE, ERROR }

Widget getWidgetByLoadingStatus(LoadingStatus status, VoidCallback onRefresh) {
  switch (status) {
    case LoadingStatus.LOADING:
      return Center(child: CircularProgressIndicator());
    case LoadingStatus.ERROR:
      return Center(
        child: FlatButton(onPressed: onRefresh, child: Text("数据加载失败，点击重试")),
      );
    case LoadingStatus.NO_MORE:
      return Center(child: Text("到底了"));
    case LoadingStatus.NONE:
      return Container();
  }
  return null;
}
