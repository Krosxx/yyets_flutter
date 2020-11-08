import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_yyets/utils/RRResManager.dart';
import 'package:flutter_yyets/utils/mysp.dart';
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

  Map<dynamic, dynamic> downloadStatus = {};

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
    downloadStatus = await RRResManager.getFilmStatus(kl);
    print(downloadStatus);
    if (mounted) {
      setState(() {});
    }
  }

  //STATUS_COMPLETE = 1;
  // STATUS_WAITING = 2;
  // STATUS_DOWNLOADING = 3;
  // STATUS_PAUSED = 4;
  // STATUS_UNKNOWN = -1;
  // STATUS_UN_DOWNLOAD = -2;
  Map statusColors = {
    1: Colors.lightGreen,
    2: Colors.amberAccent,
    3: Colors.greenAccent,
    4: Colors.orange,
  };

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
                  dynamic ss = downloadStatus[k] ?? [-1, 0.0];
                  int status = ss[0];
                  double progress = ss[1];
                  bool unPlay = epiItem['play_status_cn'] == "未播";
                  return Card(
                    color: statusColors[status],
                    //isDownload ? Colors.lightGreen : null,
                    child: InkWell(
                      onLongPress: () {
                        _toResPage(unPlay, epiItem, item);
                      },
                      onTap: () async {
                        if (status >= 1 && status <= 4) {
                          Navigator.pushNamed(context, "/download");
                          dynamic sp = (await MySp);
                          int guideCount = sp.get("res_guide", 0);
                          print(guideCount);
                          if (guideCount < 3) {
                            sp.set("res_guide", guideCount + 1);
                            toast("长按可进入资源页");
                          }
                          return;
                        }
                        _toResPage(unPlay, epiItem, item);
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
                            progress > 0
                                ? LinearProgressIndicator(
                                    value: progress,
                                  )
                                : Container(),
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

  void _toResPage(unPlay, epiItem, item) {
    if (unPlay) {
      toastLong("未播");
      return;
    }
    Navigator.pushNamed(context, "/res",
        arguments: epiItem
          ..addAll(resInfo)
          ..["season_cn"] = item['season_cn']
          ..["season"] = item['season']
          ..['episode'] = epiItem['episode'])
        .whenComplete(initDownloadStatus);
  }
}
