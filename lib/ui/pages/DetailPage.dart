import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_yyets/app/Api.dart';
import 'package:flutter_yyets/model/RRUser.dart';
import 'package:flutter_yyets/ui/pages/CommentsPage.dart';
import 'package:flutter_yyets/ui/utils.dart';
import 'package:flutter_yyets/ui/widgets/EpisodeWidget.dart';
import 'package:flutter_yyets/ui/widgets/MovieResWidget.dart';
import 'package:flutter_yyets/ui/widgets/MoviesGridWidget.dart';
import 'package:flutter_yyets/utils/toast.dart';
import 'package:flutter_yyets/utils/tools.dart';

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

  bool _hasErr = false;

  bool _isFollow = false;

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

  void loadData() {
    RRUser.isLogin.then((login) async {
      if (login) {
        return await Api.isFollow(data['id']);
      } else {
        return false;
      }
    }).then((value) {
      print("isStar: $value");
      if (mounted) {
        setState(() {
          _isFollow = value;
        });
      }
    });
    Api.getDetail(data["id"]).then((d) {
      if (mounted) {
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
        title: Text(title),
        actions: detail == null
            ? null
            : [
                IconButton(
                  icon: Icon(
                    Icons.star,
                    color: _isFollow ? Colors.yellowAccent : null,
                  ),
                  onPressed: () async {
                    if (!await RRUser.isLogin) {
                      toastLong("请登录后操作");
                    } else {
                      toggleFollow();
                    }
                  },
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
              backgroundColor: Colors.black,
              pinned: true,
              floating: true,
              automaticallyImplyLeading: false,
              expandedHeight: 282,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.parallax,
                background: Container(
                  //头部整个背景颜色
                  height: double.infinity,
                  child: _buildDetail(),
                ),
              ),
              bottom:
                  TabBar(controller: _tabController, isScrollable: true, tabs: [
                Tab(text: "剧集"),
                Tab(text: "介绍"),
                Tab(
                    text: "评论" +
                        (detail == null
                            ? ""
                            : "(${detail['comments_count']})")),
                Tab(text: "推荐"),
              ]),
            ),
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
                      detail["season_list"] == null
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
    print(detail);
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
      Hero(
          child: Image.network(
            data["poster_b"] ?? resource["poster_b"] ?? data["poster"],
            fit: BoxFit.cover,
            width: 150,
            height: 280.0 - 46,
          ),
          tag: "img_${data["id"]}"),
      Expanded(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                maxLines: 2,
                style: TextStyle(fontSize: 18),
                overflow: TextOverflow.fade,
              ),
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
            ],
          ),
        ),
      ),
    ]);
  }
}
