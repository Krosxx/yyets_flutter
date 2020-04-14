import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_yyets/app/Api.dart';
import 'package:flutter_yyets/app/Stroage.dart';
import 'package:flutter_yyets/ui/pages/LoadingPageState.dart';
import 'package:flutter_yyets/ui/utils.dart';
import 'package:flutter_yyets/utils/times.dart';

class FavoritesPage extends StatefulWidget {
  @override
  State createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  int sortType = 0;

  _Body _body;

  @override
  void initState() {
    super.initState();
    favoritesSortType.then((value) {
      setState(() {
        sortType = value;
        _body = _Body(0);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("我的收藏"),
        actions: [
          PopupMenuButton(
            icon: Icon(Icons.sort),
            onSelected: (value) {
              if (sortType != value) {
                setFavoritesSortType(value);
                setState(() {
                  _body = _Body(value);
                  sortType = value;
                });
              }
            },
            itemBuilder: (c) {
              return [
                PopupMenuItem(
                  value: 0,
                  child: Text(
                    "更新时间",
                    style: _sortTextStyle(sortType == 0),
                  ),
                ),
                PopupMenuItem(
                  value: 1,
                  child: Text(
                    "收藏时间 ↑",
                    style: _sortTextStyle(sortType == 1),
                  ),
                ),
                PopupMenuItem(
                  value: 2,
                  child: Text(
                    "收藏时间 ↓",
                    style: _sortTextStyle(sortType == 2),
                  ),
                )
              ];
            },
          )
        ],
      ),
      body: _body,
    );
  }

  TextStyle _sortTextStyle(bool checked) {
    return checked
        ? TextStyle(
            fontWeight: FontWeight.bold, color: Theme.of(context).accentColor)
        : null;
  }
}

class _Body extends StatefulWidget {
  final int sortType;

  _Body(this.sortType);

  @override
  State createState() => _FavoriteListState();
}

class _FavoriteListState extends LoadingPageState<_Body> {
  @override
  Future<List> fetchData(int page) =>
      Api.myFavorites(page, limit: widget.sortType == 0 ? 20 : 10000);

  @override
  void onLoadComplete() {
    if (widget.sortType >= 1) {
      items.sort((a, b) {
        int at = int.parse(a['dateline']);
        int bt = int.parse(b['dateline']);
        if (widget.sortType == 1) {
          return bt - at;
        } else {
          return at - bt;
        }
      });
    }
  }

  @override
  void didUpdateWidget(_Body oldWidget) {
    super.didUpdateWidget(oldWidget);
    refresh();
  }

  @override
  Widget buildItem(BuildContext context, int index, dynamic item) {
    var detail = item['detail'];
    return Container(
      padding: EdgeInsets.all(5),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, "/detail", arguments: detail);
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Hero(
              tag: "img_${detail["id"]}",
              child: Image.network(
                detail['poster_b'],
                width: 100,
                fit: BoxFit.cover,
                height: 125,
              ),
            ),
            Container(
              width: 5,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    detail['cnname'],
                    style: TextStyle(fontSize: 16),
                  ),
                  Container(
                    height: 5,
                  ),
                  Text("更新时间：${formatSeconds(int.parse(item['updatetime']))}"),
                  Text('收藏时间：${formatSeconds(int.parse(item['dateline']))}'),
                  Wrap(
                    children: [
                      tagText(detail['score']),
                      tagText(detail['type_name']),
                      tagText(detail['category']),
                      tagText(detail['play_status']),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
