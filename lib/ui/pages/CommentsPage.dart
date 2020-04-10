import 'package:flutter/cupertino.dart';
import 'package:flutter_yyets/app/Api.dart';
import 'package:flutter_yyets/ui/load/LoadingStatus.dart';
import 'package:flutter_yyets/ui/widgets/CommentsWidget.dart';
import 'package:flutter_yyets/utils/toast.dart';

class CommentsPage extends StatefulWidget {
  final List hotComments;
  final String id;
  final String chanel;

  CommentsPage(this.id, this.hotComments, this.chanel);

  @override
  State createState() {
    return _CommentsPageState();
  }
}

class _CommentsPageState extends State<CommentsPage> {
  final List comments = [];

  ScrollController _scrollController;

  LoadingStatus _loadStatus = LoadingStatus.NONE;

  int _page = 1;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_loadStatus != LoadingStatus.LOADING && _loadStatus != LoadingStatus.ERROR &&
          _scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 50) {
        loadMore();
      }
    });
    loadMore();
  }

  void loadMore() {
    if (_loadStatus == LoadingStatus.NO_MORE ||
        _loadStatus == LoadingStatus.LOADING) {
      return;
    }
    print("load more comments $_page");
    setState(() {
      _loadStatus = LoadingStatus.LOADING;
    });
    Api.loadComments(widget.id, widget.chanel, _page).then((data) {
      print("load comments: ${data.length}");
      if (data.isEmpty) {
        setState(() {
          _loadStatus = LoadingStatus.NO_MORE;
        });
      } else {
        _page++;
        setState(() {
          _loadStatus = LoadingStatus.NONE;
          comments.addAll(data);
          //去除热评
          var hotIds = widget.hotComments.map((e) => e['id']);
          comments.removeWhere((item) => hotIds.contains(item['id']));
        });
      }
    }).catchError((e) {
      print(e.toString());
      setState(() {
        _loadStatus = LoadingStatus.ERROR;
      });
      showToast(e);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      shrinkWrap: true,
      controller: _scrollController,
      slivers: <Widget>[
        SliverList(
          delegate: SliverChildBuilderDelegate((c, i) {
            if (i == 0)
              return Padding(
                padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: Text("热评"),
              );
            else
              return CommentsWidgetBuilder.build(widget.hotComments[i - 1]);
          }, childCount: widget.hotComments.length + 1),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate((c, i) {
            if (i == 0)
              return Padding(
                padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: Text("评论"),
              );
            else if (i == comments.length + 1)
              return getWidgetByLoadingStatus(_loadStatus, loadMore);
            else
              return CommentsWidgetBuilder.build(comments[i - 1]);
          }, childCount: comments.length + 2),
        ),
      ],
    );
  }
}
