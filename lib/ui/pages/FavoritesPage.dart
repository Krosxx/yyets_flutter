import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_yyets/app/Api.dart';
import 'package:flutter_yyets/ui/load/LoadingStatus.dart';
import 'package:flutter_yyets/utils/times.dart';

class FavoritesPage extends StatefulWidget {
  @override
  State createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritesPage> {
  List _items = [];
  int _page = 1;
  LoadingStatus _status = LoadingStatus.LOADING;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _loadMore() {
    Api.myFavorites(_page).then((data) {
      setState(() {
        if (data.isEmpty) {
          _status = LoadingStatus.NO_MORE;
        } else {
          _page++;
          _items.addAll(data);
          _status = LoadingStatus.NONE;
        }
      });
    }).catchError((e) {
      setState(() {
        _status = LoadingStatus.ERROR;
      });
    });
  }

  void _refresh() {
    _page = 1;
    _loadMore();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("我的收藏"),
        ),
        body: _items.isNotEmpty
            ? ListView.builder(
                itemCount: _items.length,
                itemBuilder: (BuildContext context, int index) {
                  var item = _items[index];
                  var detail = item['detail'];
                  return ListTile(
                    onTap: () {
                      Navigator.pushNamed(context, "/detail",
                          arguments: detail);
                    },
                    leading: Image.network(
                      detail['poster'],
                      width: 180,
                      height: 255,
                    ),
                    title: Text(detail['cnname']),
                    subtitle: Column(
                      children: <Widget>[
                        Text("更新时间：${formatSeconds(detail['dateline'])}"),
                        Text('收藏时间：${formatSeconds(item['dateline'])}'),
                      ],
                    ),
                  );
                },
              )
            : getWidgetByLoadingStatus(_status, _loadMore));
  }
}
