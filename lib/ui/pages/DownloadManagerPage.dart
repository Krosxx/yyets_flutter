import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart' hide Intent, Action;
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_yyets/utils/RRResManager.dart';
import 'package:flutter_yyets/utils/mysp.dart';
import 'package:flutter_yyets/utils/toast.dart';

class DownloadManagerPage extends StatefulWidget {
  @override
  State createState() => _State();
}

const int STATUS_COMPLETE = 1;
const int STATUS_WAITING = 2;
const int STATUS_DOWNLOADING = 3;
const int STATUS_PAUSED = 4;
const int STATUS_UNKNOWN = -1;

class _State extends State<DownloadManagerPage> {
  List dataSet;

  String totalSpeed = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("下载管理"), actions: [
        IconButton(
          icon: Icon(Icons.help),
          onPressed: _showTipsDialog,
        ),
        Center(
          child: Text(totalSpeed),
        )
      ]),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (dataSet == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: dataSet.length,
              itemBuilder: (c, i) => buildItem(dataSet[i]),
            ),
          ),
          Row(
            children: [
              FlatButton(
                onPressed: () async {
                  await RRResManager.pauseAll();
                  totalSpeed = "";
                  refreshStatus();
                },
                child: Text("暂停全部"),
              ),
              FlatButton(
                onPressed: () async {
                  await RRResManager.resumeAll();
                  refreshStatus();
                },
                child: Text("开始全部"),
              ),
            ],
          ),
        ],
      );
    }
  }

  // {"downSpeed":1223802,"stats":[
  // {"downSpeed":1129287,"errCode":0,"fileSize":891567585,"finishedSize":131858432,
  // "id":"9c4ca974d5dd4dcbea2c394a8355d7ff4f7d71ca","state":1,"upSpeed":0}],
  // "upSpeed":0}
  void onReceiverData(dynamic event) {
    print(event.toString());
    Map data = jsonDecode(event);
    totalSpeed = formatSpeed(data['downSpeed']) ?? "";
    List statList = (data['stats'] ?? []);
    statList.forEach((stat) {
      if (stat['state'] == 2 || stat['finishedSize'] >= stat['fileSize']) {
        print("complete $stat");
        totalSpeed = "";
        setState(() {
          updateStatus(stat['id'], stat, STATUS_COMPLETE);
        });
      } else {
        print("updateStatus $stat");
        updateStatus(stat['id'], stat, 0);
      }
    });
    refreshStatus();
  }

  void playOnLocal(filename, name) {
    Navigator.pop(context);
    Navigator.pushNamed(context, "/play", arguments: {
      'uri': filename,
      'title': name,
    });
  }

  void play(filename, name) async {
    if (!Platform.isAndroid) {
      playOnLocal(filename, name);
      return;
    }
    var sp = await MySp;
    bool drpm = sp.get('dont_request_play_mode', false);
    if (drpm) {
      playOnLocal(filename, name);
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (c) {
        return AlertDialog(
          title: Text("播放方式"),
          actions: [
            FlatButton(
              child: Text("本地[不再询问]"),
              onPressed: () {
                sp.set("dont_request_play_mode", true);
                playOnLocal(filename, name);
              },
            ),
            FlatButton(
              child: Text("本地"),
              onPressed: () {
                playOnLocal(filename, name);
              },
            ),
            FlatButton(
              child: Text("外部App"),
              onPressed: () {
                Navigator.pop(context);
                RRResManager.playByExternal(filename);
              },
            ),
          ],
        );
      },
    );
  }

  void updateStatus(String id, Map stat, int status) {
    dataSet.forEach((data) {
      if (data['mFileId'] == id) {
        data['speed'] = formatSpeed(stat['downSpeed']);
        data['mLoadPosition'] = stat['finishedSize'];
        data['status'] = status;
      }
    });
  }

  String formatSpeed(int speed) {
    double ks = speed.toDouble() / 1024;
    if (ks > 1024) {
      double ms = ks / 1024;
      return ms.toStringAsFixed(2) + "M/s";
    } else {
      return ks.toStringAsFixed(2) + "K/s";
    }
  }

  Widget buildItem(Map item) {
    String name = item['mFilmName'];
    String season = item['mSeason'];
    if (season != null && season != "") {
      name += " S${season}E${item['mEpisode']}";
    }
    int status = item['status'];

    String statusText = "...";
    IconData statusIcon = Icons.refresh;
    double progress = item['mLoadPosition'] / item['mLength'];
    switch (status) {
      case STATUS_COMPLETE:
        statusIcon = Icons.play_arrow;
        statusText = "下载完成";
        break;
      case STATUS_DOWNLOADING:
        statusIcon = Icons.pause;
        statusText = item['speed'] ?? "等待...";
        break;
      case STATUS_PAUSED:
        statusText = "未开始下载";
        statusIcon = Icons.file_download;
        break;
      case STATUS_UNKNOWN:
        statusText = "未开始下载";
        statusIcon = Icons.adb;
        break;
    }
    return Slidable(
      child: ListTile(
        leading: InkWell(
          child: Image.network(item['mFilmImg']),
          onTap: () {
            var data = {
              "id": item['mFilmId'],
              "cnname": item['mFilmName'],
              "poster_b": item['mFilmImg'],
            };
            Navigator.pushNamed(context, "/detail", arguments: data);
          },
        ),
        trailing: IconButton(
          icon: Icon(statusIcon),
          onPressed: () {
            switch (status) {
              case STATUS_COMPLETE:
                play(item['mFileName'], name);
                //play
                break;
              case STATUS_DOWNLOADING:
                RRResManager.pauseByFileId(item['mFileId']);
                totalSpeed = "";
                refreshStatus();
                break;
              case STATUS_PAUSED:
                RRResManager.resumeByFileId(item['mFileId']);
                totalSpeed = "";
                refreshStatus();
                break;
              case STATUS_UNKNOWN:
                break;
            }
          },
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(statusText),
            Container(
              height: 5,
            ),
            Container(
              height: 3,
              child: LinearProgressIndicator(
                value: progress,
              ),
            ),
            (status == STATUS_DOWNLOADING && progress > 0.05)
                ? IconButton(
                    icon: Icon(Icons.play_arrow),
                    onPressed: () {
                      play(item['mFileName'], name);
                    })
                : Container(),
          ],
        ),
//                      subtitle: LinearProgressIndicator(semanticsValue: ,),
        title: Text(name),
      ),
      secondaryActions: [
        IconSlideAction(
          caption: "删除",
          icon: Icons.delete,
          color: Colors.redAccent,
          onTap: () => _requestDelete(item['mFileId']),
        )
      ],
      actionPane: SlidableScrollActionPane(),
    );
  }

  void refreshStatus() {
    Future.wait(dataSet.map((item) {
      return RRResManager.getStatus(item).then((value) {
        if (item['status'] != STATUS_COMPLETE) {
          item['status'] = value;
        }
      });
    })).whenComplete(() => setState(() {}));
  }

  @override
  void initState() {
    super.initState();
    RRResManager.addEventListener(onReceiverData);
    refreshList();
  }

  void refreshList() {
    RRResManager.getAllItems().then((value) {
      print(value.toString());
      dataSet = value ?? [];
      refreshStatus();
    }).catchError((e) {
      print(e);
      toast(e);
    });
  }

  @override
  void dispose() {
    RRResManager.removeEventListener(onReceiverData);
    super.dispose();
  }

  void _requestDelete(String fileId) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (c) => AlertDialog(
        title: Text("确认删除？"),
        actions: [
          FlatButton(
            child: Text("确认"),
            onPressed: () async {
              if (await RRResManager.deleteDownload(fileId)) {
                refreshList();
              } else {
                toast("删除失败");
              }
              Navigator.pop(c);
            },
          ),
          FlatButton(
              child: Text("取消"),
              onPressed: () {
                Navigator.pop(c);
              }),
        ],
      ),
    );
  }

  void _showTipsDialog() => showDialog(
        context: context,
        barrierDismissible: true,
        builder: (c) => AlertDialog(
          title: Text("提示"),
          content: Text(
            "1. 请不要同时开启人人官方应用，否则无法使用下载功能。\n"
            "2. 下载5%即可播放。\n"
            "3. 侧滑删除。\n"
            "4. 下载目录：/sdcard/Android/data/cn.vove7.flutter_yyets/download",
          ),
        ),
      );
}
