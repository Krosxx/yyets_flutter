import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MovieResWidget extends StatelessWidget {
  final List<dynamic> movRes;
  final Map resInfo;

  MovieResWidget(this.movRes, this.resInfo);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: movRes.length,
        itemBuilder: (c, i) {
          var item = movRes[i];
          return Card(
            color: Theme.of(context).cardColor,
            margin: EdgeInsets.fromLTRB(10, 10, 10, 5),
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(context, "/res",
                    arguments: item..addAll(resInfo));
              },
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      item['number'],
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(item['name']),
                    item['play'] == 1
                        ? Text(
                            "边下边播",
                            style: TextStyle(
                              color: Colors.blue,
                            ),
                          )
                        : Container(),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
