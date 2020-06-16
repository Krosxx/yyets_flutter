import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_yyets/utils/RRResManager.dart';
import 'package:flutter_yyets/utils/toast.dart';
import 'package:flutter_yyets/utils/tools.dart';

///
/// 季集
///
///

class EpisodeWidget extends StatefulWidget {
  final List<dynamic> episodes;
  final Map resInfo;

  EpisodeWidget(this.episodes, this.resInfo);

  @override
  State createState() => EpisodeWidgetState();
}

class EpisodeWidgetState extends State<EpisodeWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List<dynamic> get episodes => widget.episodes;

  Map get resInfo => widget.resInfo;

  Map<dynamic, dynamic> downloaded = {};

  @override
  void initState() {
    super.initState();
    initDownloadStatus();
  }

  void initDownloadStatus() async {
    if (!RRResManager.isSupportThisPlatForm || !mounted) {
      return;
    }
    var kl = <Map>[];
    episodes.forEach((item) {
      String season = item['season'].toString();
      item['episode_list'].forEach((epi) {
        kl.add({
          "filmid": resInfo['id'],
          "season": season,
          "episode": epi['episode'],
          "key": resInfo['id'] +
              "-" +
              (season ?? "") +
              "-" +
              (epi['episode'] ?? ""),
        });
      });
    });
    downloaded = await RRResManager.isDownloadComplete(kl);
    if(mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView.builder(
      itemCount: episodes.length,
      itemBuilder: (c, i) {
        var item = episodes[i];
        List epiList = item['episode_list'];
        String season = item['season'].toString();
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
              children: epiList.map(
                (epiItem) {
                  String k = resInfo['id'] +
                      "-" +
                      (season ?? "") +
                      "-" +
                      (epiItem['episode'] ?? "");
                  bool isDownload = downloaded[k] ?? false;
                  bool unPlay = epiItem['play_status_cn'] == "未播";
                  return Card(
                    color: isDownload ? Colors.lightGreen : null,
                    child: InkWell(
                      onTap: () {
                        if (unPlay) {
                          toastLong("未播");
                          return;
                        }
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
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  epiItem['episode'],
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueAccent),
                                ),
                                Container(
                                  width: 10,
                                ),
                                Text(
                                  "${epiItem['play_status_cn']}",
                                  style: TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              nullEmptyElse(epiItem['play_time'], "无时间"),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ).toList(),
            )
          ],
        );
      },
    );
  }
}
