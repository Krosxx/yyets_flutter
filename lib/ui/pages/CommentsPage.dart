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

///
/// Flutter切换tab后默认不会保留tab状态 ，
/// Flutter中为了节约内存不会保存widget的状态,widget都是临时变量。
/// 当我们使用TabBar,TabBarView是我们就会发现,切换tab，initState又会被调用一次。
/// 为了让tab一直保存在内存中不被销毁。在需要保持页面状态的子页State中，
/// 继承AutomaticKeepAliveClientMixin并重写wantKeepAlive为true即可。
///
class _CommentsPageState extends State<CommentsPage>
    with AutomaticKeepAliveClientMixin {
  final List comments = [];

  LoadingStatus _loadStatus = LoadingStatus.NONE;

  int _page = 1;

  Function scrollListener;
  ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    scrollListener = () {
      // ignore: invalid_use_of_protected_member
      var ps = _scrollController.positions;
      print(ps.length);
      var pos = ps.elementAt(ps.length - 1);
      double p = pos.pixels;
      double mp = pos.maxScrollExtent;
      print("$p/$mp");
      if (_loadStatus != LoadingStatus.LOADING &&
          _loadStatus != LoadingStatus.ERROR &&
          p >= mp - 50) {
        loadMore();
      }
    };
    loadMore();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController?.removeListener(scrollListener);
  }

  void loadMore() {
    if (_loadStatus == LoadingStatus.NO_MORE ||
        _loadStatus == LoadingStatus.LOADING) {
      return;
    }
    print("load more comments $_page $mounted");
    if (mounted) {
      setState(() {
        _loadStatus = LoadingStatus.LOADING;
      });
    }
    Api.loadComments(widget.id, widget.chanel, _page).then((data) {
      print("load comments: ${data.length}");
      if (data.isEmpty) {
        if (mounted) {
          setState(() {
            _loadStatus = LoadingStatus.NO_MORE;
          });
        }
      } else {
        _page++;
        if (mounted) {
          setState(() {
            _loadStatus = LoadingStatus.NONE;
            comments.addAll(data);
            //去除热评
            var hotIds = widget.hotComments.map((e) => e['id']);
            comments.removeWhere((item) => hotIds.contains(item['id']));
          });
        }
      }
    }).catchError((e) {
      print(e.toString());
      if (mounted) {
        setState(() {
          _loadStatus = LoadingStatus.ERROR;
        });
        toast(e);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    //获取父级（NestedScrollView）ScrollController
    var pc = PrimaryScrollController.of(context);
    if (pc != null) {
      print("got PrimaryScrollController!!");
      _scrollController = pc;
      // ignore: invalid_use_of_protected_member
      if (!pc.hasListeners) {
        pc.addListener(scrollListener);
      }
    }

    int hotLen = widget.hotComments.length;
    int totalLen = comments.length + hotLen + 3;
    return ListView.builder(
        shrinkWrap: true,
        itemCount: totalLen,
        itemBuilder: (c, i) {
          if (i == 0) {
            return Padding(
              padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: Text("热评"),
            );
          } else if (i == totalLen - 1) {
            return getWidgetByLoadingStatus(_loadStatus, loadMore);
          } else if (i == hotLen + 1) {
            return Padding(
              padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: Text("全部评论"),
            );
          } else {
            var comment;
            if (i <= hotLen) {
              comment = widget.hotComments[i - 1];
            } else {
              comment = comments[i - 2 - hotLen];
            }
            return CommentsWidgetBuilder.build(comment);
          }
        });
  }

  @override
  bool get wantKeepAlive => true;
}
