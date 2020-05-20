import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_yyets/app/Api.dart';
import 'package:flutter_yyets/app/Stroage.dart';
import 'package:flutter_yyets/model/provider/favor_sort_type.dart';
import 'package:flutter_yyets/ui/pages/LoadingPageState.dart';
import 'package:flutter_yyets/ui/widgets/movie_tile.dart';
import 'package:flutter_yyets/utils/times.dart';
import 'package:provider/provider.dart';

class FavoritesPage extends StatelessWidget {
  final FavSortType sortTypeModel = FavSortType();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (c) => sortTypeModel)],
      child: Scaffold(
        appBar: AppBar(
          title: Text("我的收藏"),
          actions: [
            Consumer<FavSortType>(
              builder: (BuildContext context, FavSortType stm, Widget child) {
                return PopupMenuButton(
                  icon: Icon(Icons.sort),
                  onSelected: (value) {
                    if (stm.sortType != value) {
                      setFavoritesSortType(value);
                      Provider.of<FavSortType>(context, listen: false)
                          .setType(value);
                    }
                  },
                  itemBuilder: (c) {
                    return [
                      PopupMenuItem(
                        value: 0,
                        child: Text(
                          "更新时间",
                          style: _sortTextStyle(context, stm.sortType == 0),
                        ),
                      ),
                      PopupMenuItem(
                        value: 1,
                        child: Text(
                          "收藏时间 ↑",
                          style: _sortTextStyle(context, stm.sortType == 1),
                        ),
                      ),
                      PopupMenuItem(
                        value: 2,
                        child: Text(
                          "收藏时间 ↓",
                          style: _sortTextStyle(context, stm.sortType == 2),
                        ),
                      )
                    ];
                  },
                );
              },
            )
          ],
        ),
        body: Consumer<FavSortType>(
          builder: (BuildContext context, FavSortType value, Widget child) {
            print("build body");
            return _Body(value.sortType);
          },
        ),
      ),
    );
  }

  TextStyle _sortTextStyle(context, bool checked) {
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
    if (oldWidget?.sortType != widget.sortType) {
      refresh();
    }
  }

  @override
  Widget buildItem(BuildContext context, int index, dynamic item) {
    var detail = item['detail'];
    return MovieTile(
        detail,
        detail['cnname'],
        Column(
          children: [
            Text("更新时间：${formatSeconds(int.parse(item['updatetime']))}"),
            Text('收藏时间：${formatSeconds(int.parse(item['dateline']))}'),
          ],
        ),
        [
          detail['score'],
          detail['type_name'],
          detail['category'],
          detail['play_status'],
        ]);
  }
}
