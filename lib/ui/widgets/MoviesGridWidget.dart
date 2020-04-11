import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MoviesGridWidget extends StatelessWidget {
  final List list;

  MoviesGridWidget(this.list);

  @override
  Widget build(BuildContext context) {
    return GridView.extent(
      padding: EdgeInsets.all(10),
      maxCrossAxisExtent: 180,
      mainAxisSpacing: 6,
      crossAxisSpacing: 6,
      childAspectRatio: 0.7,
      children: list.map((it) {
        return InkWell(
            onTap: () {
              Navigator.of(context).pushNamed("/detail", arguments: it);
            },
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: <Widget>[
                Hero(
                  child: Image.network(
                    it["poster"] ?? "https://flutter.cn/favicon.ico",
                    fit: BoxFit.cover,
                    width: 180,
                    height: 255,
                  ),
                  tag: "img_${it["id"]}",
                ),
                Container(
                  constraints: BoxConstraints.expand(height: 25),
                  child: Center(
                      child: Hero(
                    child: Text(
                      it["cnname"],
//                      it["id"] + it["id"] + it["id"] + it["id"],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.white),
                    ),
                    tag: "title_${it["id"]}",
                  )),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                  ),
                ),
              ],
            ));
      }).toList(),
    );
  }
}
