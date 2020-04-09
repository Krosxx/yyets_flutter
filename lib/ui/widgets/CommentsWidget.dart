import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CommentsWidgetBuilder {
  static Widget build(Map item) {
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
                    child: CircleAvatar(
                        radius: 2,
                        child: Image.network(
                          item['avatar_s'],
                          fit: BoxFit.fitWidth,
                          height: 15,
                          width: 15,
                        ))),
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
                    color: Colors.black26,
                    borderRadius: BorderRadius.all(Radius.circular(5))),
                child: ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: replies.length,
                    itemBuilder: (c, i) {
                      var rep = replies[i];
                      return Text.rich(
                        TextSpan(style: TextStyle(fontSize: 12), children: [
                          TextSpan(
                            style: TextStyle(color: Colors.blue),
                            text: rep['nickname'] + ': ',
                          ),
                          TextSpan(text: rep['content'])
                        ]),
                      );
                    }))
          ],
        ),
      ),
    );
  }
}
