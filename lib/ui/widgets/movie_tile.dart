import 'package:flutter/material.dart';

import '../utils.dart';

class MovieTile extends StatelessWidget {
  final Map detail;
  final String title;
  final Widget infoWidget;
  final List<String> tags;

  MovieTile(this.detail, this.title, this.infoWidget, this.tags);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, "/detail", arguments: detail);
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Hero(
              tag: "img_${detail["id"]}",
              child: Image.network(
                detail['poster_b'],
                width: 100,
                fit: BoxFit.cover,
                height: 150,
              ),
            ),
            Container(
              width: 10,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 16),
                  ),
                  Container(
                    height: 5,
                  ),
                  infoWidget,
                  Wrap(children: tags.map((e) => tagText(e)).toList())
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
