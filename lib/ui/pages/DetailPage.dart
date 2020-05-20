import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_yyets/app/Api.dart';
import 'package:flutter_yyets/model/RRUser.dart';
import 'package:flutter_yyets/ui/pages/CommentsPage.dart';
import 'package:flutter_yyets/ui/utils.dart';
import 'package:flutter_yyets/ui/widgets/EpisodeWidget.dart';
import 'package:flutter_yyets/ui/widgets/MovieResWidget.dart';
import 'package:flutter_yyets/ui/widgets/MoviesGridWidget.dart';
import 'package:flutter_yyets/utils/mysp.dart';
import 'package:flutter_yyets/utils/toast.dart';
import 'package:flutter_yyets/utils/tools.dart';
import 'package:tutorial_coach_mark/content_target.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class DetailPage extends StatefulWidget {
  final dynamic data;

  DetailPage(this.data);

  @override
  State createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  get data => widget.data;
  Map<String, dynamic> detail;

  Map<String, dynamic> get resource => detail != null ? detail["resource"] : {};

  var headerHeight = 282.0;

  bool _hasErr = false;

  bool _isFollow = false;
  String _myScore = null;

  String get title => () {
        var enname = data['enname'];
        return data["cnname"] + (enname == null ? "" : "($enname)");
      }();

  void toggleFollow() {
    bool status = !_isFollow;
    Future fun;
    if (_isFollow) {
      fun = Api.unFollow(data['id']);
    } else {
      fun = Api.follow(data['id']);
    }
    fun.then((res) {
      String action = status ? "收藏" : "取消收藏";
      if (res) {
        toastLong("${action}成功");
        if (mounted) {
          setState(() {
            _isFollow = status;
          });
        }
      } else {
        toastLong("${action}失败");
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 4);
    loadData();
  }

  var _likeKey = GlobalKey();

  _showTutorial() async {
    var sp = await MySp;
    if (!mounted || sp.has("like_key")) {
      return;
    }
    sp.set("like_key", 1);

    TutorialCoachMark(
      context,
      targets: [
        TargetFocus(
          identify: "like_key_1",
          keyTarget: _likeKey,
          contents: [
            ContentTarget(
              align: AlignContent.bottom,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "点击收藏，长按评分",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 15.0),
                ),
              ),
            )
          ],
        )
      ],
      colorShadow: Colors.blueAccent,
      // DEFAULT Colors.black
      alignSkip: Alignment.topLeft,
      textSkip: "我知道了",
    )..show();
  }

  void loadData() async {
    bool isLogin = await RRUser.isLogin;
    var lf = Future.value(isLogin ? Api.isFollow(data['id']) : false);

    if (isLogin) {
      Api.myRatingScore(data['id']).then((value) {
        setState(() {
          _myScore = value;
          print("myScore: $_myScore");
        });
      });
    }

    lf.then((value) {
      print("isStar: $value");
      if (mounted) {
        setState(() {
          _isFollow = value;
        });
      }
    });
    Api.getDetail(data["id"]).then((d) {
      if (mounted) {
        Future.delayed(Duration(seconds: 1), _showTutorial);
        setState(() {
          detail = d;
        });
      }
    }).catchError((e) {
      if (mounted) {
        setState(() {
          _hasErr = true;
        });
      }
      print(e);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: InkWell(
          child: Text(title),
          onTap: () => toast(title),
          onLongPress: () {
            setClipboardData(title);
            toast("标题已复制");
          },
        ),
        actions: detail == null
            ? null
            : [
                Semantics(
                  key: _likeKey,
                  button: true,
                  enabled: true,
                  child: InkResponse(
                    child: Icon(
                      Icons.star,
                      color: _isFollow ? Colors.yellow : null,
                    ),
                    onLongPress: () async {
                      if (!await RRUser.isLogin) {
                        toastLong("请登录后操作");
                      } else {
                        score();
                      }
                    },
                    onTap: () async {
                      if (!await RRUser.isLogin) {
                        toastLong("请登录后操作");
                      } else {
                        toggleFollow();
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.share),
                  onPressed: () => share(
                      title +
                          "\n" +
                          detail["share_url"] +
                          "\n\n来自 人人影视_Flutter",
                      subject: "人人影视分享"),
                )
              ],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
                pinned: true,
                floating: true,
                automaticallyImplyLeading: false,
                expandedHeight: headerHeight,
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  background: Container(
                    //头部整个背景颜色
                    height: double.infinity,
                    child: _buildDetail(),
                  ),
                ),
                bottom: TabBar(
                  controller: _tabController,
                  labelColor: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                  isScrollable: true,
                  tabs: [
                    Tab(text: "剧集"),
                    Tab(text: "介绍"),
                    Tab(
                        text: "评论" +
                            (detail == null
                                ? ""
                                : "(${detail['comments_count']})")),
                    Tab(text: "推荐"),
                  ],
                )),
          ];
        },
        body: _hasErr
            ? Center(
                child: FlatButton(
                  child: Text("获取失败，点击重试"),
                  onPressed: () {
                    loadData();
                  },
                ),
              )
            : detail == null
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : TabBarView(
                    controller: _tabController,
                    children: <Widget>[
                      detail["season_list"] == null ||
                              detail["season_list"].length == 0
                          ? MovieResWidget(detail['movie_items'], resource)
                          : EpisodeWidget(detail["season_list"], resource),
                      SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Text(resource['content'] ?? ""),
                        ),
                      ),
                      CommentsPage(data['id'], detail["comments_hot"],
                          resource['channel']),
                      MoviesGridWidget(detail['similar']),
                    ],
                  ),
      ),
    );
  }

  Widget _buildDetail() {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
      Hero(
          child: Image.network(
            data["poster_b"] ?? resource["poster_b"] ?? data["poster"],
            fit: BoxFit.cover,
            width: 150,
            height: headerHeight - kToolbarHeight,
          ),
          tag: "img_${data["id"]}"),
      Expanded(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                height: 10,
              ),
              Wrap(
                children: [
                  Text(data["play_status"] ?? resource["play_status"] ?? ""),
                  Container(
                    width: 10,
                  ),
                  Text(
                    resource['level']?.toUpperCase() ?? "",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.lightBlue),
                  ),
                ],
              ),
              resource.isEmpty
                  ? Container()
                  : Wrap(
                      children: [
                        tagText(resource['score'] ?? ""),
                        tagText(resource['channel_cn'] ?? ""),
                        (resource['zimuzu'] == null || resource['zimuzu'] == "")
                            ? Container()
                            : tagText(resource['zimuzu']),
                      ],
                    ),
              resource.isEmpty
                  ? Container()
                  : tagText((resource['category'] ?? []).join('/')),
              _myScore == null ? Container() : tagText("我的评分：$_myScore")
            ],
          ),
        ),
      ),
    ]);
  }

  void score() {
    var ratingValue = _myScore ?? "";
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text("评分"),
        content: Builder(
          builder: (c) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(ratingValue),
              RatingBar(
                initialRating:
                    _myScore == null ? 0 : double.parse(_myScore) / 2,
                allowHalfRating: true,
                onRatingUpdate: (double value) {
                  ratingValue = (value * 2).toInt().toString();
                  (c as Element).markNeedsBuild();
                },
                itemBuilder: (c, _) => Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                minRating: 0.5,
              ),
              Container(
                width: 200,
                child: FlatButton(
                  child: Text(
                    "评分",
                    style: TextStyle(color: Colors.white),
                  ),
                  color: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100)),
                  onPressed: () async {
                    if (ratingValue == "") {
                      return;
                    }
                    await Api.rating(resource["id"], ratingValue).then((value) {
                      toast("评分成功");
                      Navigator.pop(c);
                      setState(() {
                        _myScore = ratingValue;
                      });
                    }).catchError((e) {
                      toast(e.message);
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
