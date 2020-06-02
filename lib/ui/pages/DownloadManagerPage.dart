import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide Intent, Action;
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_yyets/ui/widgets/ink_con_button.dart';
import 'package:flutter_yyets/ui/widgets/visibility.dart';
import 'package:flutter_yyets/ui/widgets/wrapped_material_dialog.dart';
import 'package:flutter_yyets/utils/RRResManager.dart';
import 'package:flutter_yyets/utils/constants.dart';
import 'package:flutter_yyets/utils/mysp.dart';
import 'package:flutter_yyets/utils/toast.dart';
import 'package:flutter_yyets/utils/tools.dart';
import 'package:material_dialog/material_dialog.dart';

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

  Map<String, List> groupSet;

  String totalSpeed = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("下载管理"), actions: [
        IconButton(
          icon: Icon(Icons.help),
          onPressed: _showTipsDialog,
        )
      ]),
      body: _buildBody(),
    );
  }

  Map<String, bool> itemExp = {};

  Widget _buildBody() {
    if (dataSet == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else {
      var gks = groupSet.keys.toList();
      return Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: ExpansionPanelList(
                expandedHeaderPadding: EdgeInsets.all(10),
                expansionCallback: (i, e) {
                  setState(() {
                    itemExp[gks[i]] = !e;
                  });
                },
                children: gks
                    .map((k) => buildGroup(k, groupSet[k], itemExp[k] ?? true))
                    .toList(),
              ),
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
              Center(
                child: Text(totalSpeed),
              )
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
    print("onReceiverData:==>>" + event.toString());
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
        return WrappedMaterialDialog(
          c,
          title: Text("播放方式"),
          actions: [
            FlatButton(
              child: Text("本地[不再询问]"),
              onPressed: () {
                sp.set("dont_request_play_mode", true);
                Navigator.pop(c);
                playOnLocal(filename, name);
              },
            ),
            FlatButton(
              child: Text("本地"),
              onPressed: () {
                Navigator.pop(c);
                playOnLocal(filename, name);
              },
            ),
            FlatButton(
              child: Text("外部App"),
              onPressed: () {
                Navigator.pop(c);
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
        print("updateStatus:=>>" + data.toString());
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

  ExpansionPanel buildGroup(String keyTitle, List items, bool exp) {
    var img = items[0]['mFilmImg'];
    if (img == null || img == "") img = "https://flutter.cn/favicon.ico";

    return ExpansionPanel(
      isExpanded: exp,
      canTapOnHeader: true,
      headerBuilder: (c, i) => Row(
        children: [
          InkWell(
            child: Image.network(
              img,
              width: 40,
              height: 60,
            ),
            onTap: () {
              var item = items[0];
              var id = int.parse(item['mFilmId']);
              if (id < 0) {
                return;
              }
              var data = {
                "id": item['mFilmId'],
                "cnname": item['mFilmName'],
                "poster_b": item['mFilmImg'],
              };
              Navigator.pushReplacementNamed(context, "/detail",
                  arguments: data);
            },
          ),
          Container(width: 10),
          Flexible(
            child: Text(
              keyTitle,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
      body: ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: items.length,
        itemBuilder: (c, i) => buildItem(items[i]),
      ),
    );
  }

  Widget buildItem(Map item) {
    String name = "";
    String season = item['mSeason'];
    if (season != null && season != "") {
      name += "第${item['mEpisode']}集";
    } else {
      name = item['mFilmName'];
    }
    int status = item['status'];

    String statusText = "初始化...";
    IconData statusIcon = Icons.refresh;
    Color color = null;
    double progress = item['mLoadPosition'] / item['mLength'];
    switch (status) {
      case STATUS_COMPLETE:
        statusIcon = Icons.play_arrow;
        statusText = "下载完成";
        color = Colors.greenAccent;

        break;
      case STATUS_DOWNLOADING:
        statusIcon = Icons.pause;
        color = Colors.redAccent;
        statusText = item['speed'] ?? "等待...";
        break;
      case STATUS_PAUSED:
        statusText = "未开始下载";
        statusIcon = Icons.file_download;
        color = Colors.blueAccent;
        break;
      case STATUS_UNKNOWN:
        statusText = "未开始下载";
        statusIcon = Icons.adb;
        break;
    }

    return Slidable(
      child: ListTile(
        onLongPress: () => _showDetail(item),
        trailing: InkIconButton(
          icon: Icon(
            statusIcon,
            size: 28,
            color: color,
          ),
          onLongPress: () {
            if (status == STATUS_COMPLETE) {
              RRResManager.playByExternal(item['mFileName']);
            }
          },
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
            Row(
              children: [
                Expanded(
                  child: Text(statusText),
                ),
                Visible(
                  visible: item['status'] != 1,
                  childBuilder: () =>
                      Text(renderSize(item['mLoadPosition']) + "/"),
                ),
                Text(renderSize(item['mSize']))
              ],
            ),
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
                ? InkIconButton(
                    icon: Icon(Icons.play_arrow),
                    onLongPress: () {
                      RRResManager.playByExternal(item['mFileName']);
                    },
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
    Future.delayed(Duration(seconds: 1), _showTutorial);
  }

  _showTutorial() async {
    var sp = await MySp;
    if (!mounted || sp.has(Constants.KEY_TUTORIAL_OF_DL)) {
      return;
    }
    sp.set(Constants.KEY_TUTORIAL_OF_DL, true);
    _showTipsDialog();
  }

  void refreshList() {
    RRResManager.getAllItems().then((value) {
      print("list: ==> " + value.toString());
      dataSet = value ?? [];
      _buildGroup();
      refreshStatus();
    }).catchError((e) {
      print(e);
      toast(e);
    });
  }

  _buildGroup() {
    groupSet = {};
    dataSet.forEach((item) {
      String key = item['mFilmName'];
      var season = item['mSeason'];
      if (season != null && season != "") {
        key += "第${season}季";
      }
      if (groupSet[key] == null) {
        groupSet[key] = [item];
      } else {
        groupSet[key].add(item);
      }
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
      builder: (c) => MaterialDialog(
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
        builder: (c) => MaterialDialog(
          title: Text("提示"),
          content: Text(
            "1. 请不要同时开启人人官方应用，否则无法使用下载功能。\n"
            "2. 下载5%即可播放。\n"
            "3. 侧滑删除。\n"
            "4. 下载目录：/sdcard/Android/data/cn.vove7.flutter_yyets/download\n"
            "5. 长按播放按钮直接使用外部播放器\n"
            "6. 卸载会清空下载及文件，需要请先备份",
          ),
          actions: [
            FlatButton(
              child: Text("我知道了"),
              onPressed: () => Navigator.pop(c),
            )
          ],
        ),
      );

  void _showDetail(Map item) {
    showDebugInfo(context, item);
  }
}
