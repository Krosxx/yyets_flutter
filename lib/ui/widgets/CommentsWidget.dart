import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_yyets/app/Api.dart';
import 'package:flutter_yyets/main.dart';
import 'package:flutter_yyets/model/RRUser.dart';
import 'package:flutter_yyets/ui/utils.dart';
import 'package:flutter_yyets/utils/times.dart';
import 'package:flutter_yyets/utils/toast.dart';

class CommentsWidgetBuilder {
  static Widget build(BuildContext context, Map item, String channel,
      String itemId, Function refresh) {
    print(item);
    var rep = item['reply'];
    List replies;
    if (rep is Map) {
      //热评 评论为非数组
      replies = [rep];
    } else {
      replies = rep ?? [];
    }
    return Card(
      margin: EdgeInsets.all(10),
      child: InkWell(
        onTap: () async {
          if (!RRUser.isLogin) {
            toast("登录后才可评论");
            return;
          }
          String text = await showInputDialog(
              context, "回复", Text("回复: ${item['nickname']}"));

          print(text);
          if (text != null) {
            Api.commentUser(item['id'], itemId, text, channel)
                .then((commentData) {
              replies.add(commentData);
              commentData['nickname'] = AppState.rrUser.name;
              item['reply'] = replies;
              refresh();
            }).catchError((e) {
              toast(e.message ?? "回复失败");
            });
          }
        },
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    height: 30,
                    width: 30,
                    child: ClipOval(
                      child: Image.network(
                        item['avatar_s'],
                        fit: BoxFit.fitWidth,
                        height: 15,
                        width: 15,
                      ),
                    ),
                  ),
                  Container(
                    width: 10,
                  ),
                  Text(
                    item["nickname"],
                    style: TextStyle(fontSize: 15),
                  ),
                ],
              ),
              Container(
                height: 10,
              ),
              Text(item['content']),
              Container(
                margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                padding: EdgeInsets.all(replies.length == 0 ? 0 : 5),
                decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.all(Radius.circular(5))),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: replies.length,
                  itemBuilder: (c, i) {
                    var rep = replies[i];
                    return Text.rich(
                      TextSpan(
                        style: TextStyle(fontSize: 12),
                        children: [
                          TextSpan(
                            style: TextStyle(color: Colors.blue),
                            text: rep['nickname'] + ': ',
                          ),
                          TextSpan(text: rep['content'])
                        ],
                      ),
                    );
                  },
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      friendlyFormat(int.parse(item['dateline'])),
                      style: Theme.of(context).textTheme.caption,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.thumb_up),
                    onPressed: () {
                      Api.commentBad(item['id'].toString()).then((v) {
                        if (v) {
                          int good = int.parse(item["good"]);
                          item["good"] = (++good).toString();
                          refresh();
                        } else {
                          throw Exception('');
                        }
                      }).catchError((e) {
                        toast("操作失败");
                      });
                    },
                  ),
                  Text(item['good']),
                  Container(
                    width: 10,
                  ),
                  IconButton(
                    icon: Icon(Icons.thumb_down),
                    onPressed: () {
                      Api.commentBad(item['id']).then((v) {
                        if (v) {
                          int bad = int.parse(item["bad"]);
                          item["bad"] = (++bad).toString();
                          refresh();
                        } else {
                          throw Exception('');
                        }
                      }).catchError((e) {
                        toast("操作失败");
                      });
                    },
                  ),
                  Text(item['bad'])
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
