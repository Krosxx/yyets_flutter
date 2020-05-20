import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_yyets/app/Api.dart';
import 'package:flutter_yyets/ui/pages/LoadingPageState.dart';
import 'package:flutter_yyets/ui/widgets/visibility.dart';
import 'package:flutter_yyets/utils/times.dart';

import 'BottomWebViewDialog.dart';

class NewsPage extends StatefulWidget {
  @override
  State createState() => NewState();
}

class NewState extends LoadingPageState<NewsPage> {
  @override
  Future<List> fetchData(int page) => Api.news(page);

  @override
  Widget build(BuildContext context) {
    var body = super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("资讯"),
      ),
      body: body,
    );
  }

  @override
  Widget buildItem(BuildContext context, int index, dynamic item) {
    var imgUrl = item['poster'] ?? item["cover"];
    var isVideo = item["cover"] != null && item["cover"] != "";
    var title = item["title"];
    var content = item['content'] ?? item['intro'];
    var username = item['username'] ?? item['author_name'];
    var type = item['type'];

    if (imgUrl == "") {
      imgUrl = null;
    }
    var roundBorder =
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(10));
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      shape: roundBorder,
      child: InkWell(
        customBorder: roundBorder,
        onTap: () {
          print(item.toString());
          if (type == "weibo") {
            var url = item['url'];
            if (url != null) {
              BottomWebViewDialog.show(context, url, title ?? username);
            }
          } else {
            var url = "http://m1.rryslink.com/article/${item['id']}";
            BottomWebViewDialog.show(context, url, title ?? username);
          }
        },
        child: Container(
          padding: EdgeInsets.fromLTRB(15, 15, 15, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(item),
              Container(
                height: 5,
              ),
              Visible(
                visible: title != null,
                childBuilder: () => Text(
                  title,
                  style: TextStyle(fontSize: 16),
                ),
              ),
              Visible(
                visible: content != null,
                childBuilder: () => Html(
                  data: content,
                  onLinkTap: (link) => BottomWebViewDialog.show(
                      context, link, title ?? username),
                ),
              ),
              Container(height: 5),
              Visible(
                visible: imgUrl != null,
                childBuilder: () => isVideo
                    ? InkWell(
                        onTap: () {
                          var videoUrl = item['video_720'];
                          if (videoUrl == null || videoUrl == "") {
                            videoUrl = item['video_480'];
                          }
                          Navigator.pushNamed(context, "/play", arguments: {
                            "uri": videoUrl,
                            "title": item['title'] ?? "",
                            "type": 1
                          });
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.network(imgUrl),
                            Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                              size: 50,
                            ),
                          ],
                        ),
                      )
                    : Image.network(imgUrl),
              ),
              _footer(item)
            ],
          ),
        ),
      ),
    );
  }

  _header(item) {
    return Row(
      children: [
        ClipOval(
          child: Image.network(
            item['userpic'] ?? item['user_logo'],
            width: 40,
            height: 40,
          ),
        ),
        VerticalDivider(
          width: 10,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item['username'] ?? item['author_name']),
            Text(
              friendlyFormat(int.parse(item['dateline'] ?? item['time'])),
              style: TextStyle(fontSize: 12),
            )
          ],
        )
      ],
    );
  }

  _footer(item) {
    // weibo t_review news
    var type = item['type'];
    print(type);

    return Container(
      height: 40,
      child: Center(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(
                  Icons.comment,
                  size: 20,
                ),
                Container(width: 10),
                Text(item['count_comments']),
              ]),
            ),
            Flexible(
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(type == "weibo" ? Icons.thumb_up : Icons.looks, size: 20),
                Container(width: 10),
                Text(item['good_status']?.toString() ??
                    item['views'].toString()),
              ]),
            )
          ],
        ),
      ),
    );
  }
}
