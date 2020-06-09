import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_yyets/app/Api.dart';
import 'package:flutter_yyets/main.dart';
import 'package:flutter_yyets/model/provider/RRUser.dart';
import 'package:flutter_yyets/ui/load/LoadingStatus.dart';
import 'package:flutter_yyets/ui/widgets/CommentsWidget.dart';
import 'package:flutter_yyets/utils/toast.dart';

import '../utils.dart';

class CommentsPage extends StatefulWidget {
  final List hotComments;
  final String id;
  final String channel;

  CommentsPage(this.id, this.hotComments, this.channel);

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
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  final List comments = [];

  LoadingStatus _loadStatus = LoadingStatus.NONE;

  int _page = 1;

  CurvedAnimation curve;
  Animation<Offset> animation;
  bool _floatVisible = true;
  double lastPos = 0;

  AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    curve = CurvedAnimation(
      parent: controller,
      curve: Curves.fastOutSlowIn,
    );
    animation = Tween(
      begin: Offset.zero,
      end: Offset(0, 2),
    ).animate(controller);
    loadMore();
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
    Api.loadComments(widget.id, widget.channel, _page).then((data) {
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

    int hotLen = widget.hotComments.length;
    int totalLen = comments.length + hotLen + 3;
    return Stack(
      children: [
        NotificationListener(
          onNotification: (n) {
            if (n.runtimeType == ScrollUpdateNotification) {
              var un = n as ScrollUpdateNotification;
              if (_loadStatus != LoadingStatus.LOADING &&
                  _loadStatus != LoadingStatus.ERROR &&
                  un.metrics.extentAfter < 50) {
                loadMore();
              }
              var dd = un.dragDetails;
              if (dd != null) {
                if (dd.delta.dy > 0) {
                  //显示
                  if (!_floatVisible) {
                    _floatVisible = true;
                    controller.reverse();
                  }
                } else {
                  if (_floatVisible) {
                    _floatVisible = false;
                    controller.forward();
                  }
                }
              }
            }
            return false;
          },
          child: ListView.builder(
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
                return CommentsWidgetBuilder.build(
                  context,
                  comment,
                  widget.channel,
                  widget.id,
                      () => setState(() {}),
                );
              }
            },
          ),
        ),
        Positioned(
          bottom: 40,
          right: 30,
          child: SlideTransition(
            position: animation,
            child: FloatingActionButton(
              onPressed: () async {
                if (!RRUser.isLogin) {
                  toast("登录后才可评论");
                  return;
                }
                String text = await showInputDialog(context, "评论", Text("评论"));
                if (text != null) {
                  Api.commentTvOrMovie(widget.id, widget.channel, text)
                      .then((data) {
                    data['nickname'] = MyApp.rrUser.name;
                    data['avatar_s'] = MyApp.rrUser.avatar;
                    data['good'] = "0";
                    data['bad'] = "0";
                    setState(() {
                      comments.insert(0, data);
                    });
                  }).catchError((e) {
                    toastLong("评论失败: ${e.message}");
                  });
                }
              },
              backgroundColor: Colors.lightBlue,
              child: Icon(
                Icons.comment,
                color: Colors.white,
              ),
            ),
          ),
        )
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
