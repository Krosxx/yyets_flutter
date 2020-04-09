import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

///
/// 季集
///
class EpisodeWidget extends StatelessWidget {
  final List<dynamic> episodes;
  final Map resInfo;

  EpisodeWidget(this.episodes, this.resInfo);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: episodes.length,
        itemBuilder: (c, i) {
          var item = episodes[i];
          List epiList = item['episode_list'];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(4),
                child: Text("${item['season_cn']}"),
              ),
              GridView.extent(
                physics: new NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                maxCrossAxisExtent: 120,
                childAspectRatio: 1.5,
                children: epiList.map((epiItem) {
                  return Card(
                      child: InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, "/res",
                          arguments: epiItem
                            ..addAll(resInfo)
                            ..["season_cn"] = item['season_cn']
                            ..["season"] = item['season']
                            ..['episode'] = epiItem['episode']);
                    },
                    child: Padding(
                      padding: EdgeInsets.all(5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            epiItem['episode'],
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                          Text(epiItem['play_time']),
                        ],
                      ),
                    ),
                  ));
                }).toList(),
              )
            ],
          );
        });
  }
}
