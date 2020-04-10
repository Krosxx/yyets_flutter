import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_yyets/ui/pages/SearchPage.dart';
import 'package:flutter_yyets/ui/widgets/HomeDrawer.dart';

import 'RankPage.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("排名"),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              showSearch(context: context, delegate: SearchPageDelegate());
            },
            icon: Icon(Icons.search),
          )
        ],
      ),
      body: RankPage(),
      drawer: HomeDrawer(),
    );
  }
}
