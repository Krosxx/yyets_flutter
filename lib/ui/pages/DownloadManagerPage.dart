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

class DownloadManagerPage extends StatefulWidget {
  @override
  State createState() => DownloadPageState();
}

const int STATUS_COMPLETE = 1;
const int STATUS_WAITING = 2;
const int STATUS_DOWNLOADING = 3;
const int STATUS_PAUSED = 4;
const int STATUS_UNKNOWN = -1;

class DownloadPageState extends State<DownloadManagerPage> {
  List dataSet;

  //保存 Route 栈所有 [/download] 存活实例
  static List<Route> _routes = [];

  //移除路由栈中本页面实例
  static void removeAll(c) {
    var nav = Navigator.of(c);
    _routes.forEach((r) {
      nav.removeRoute(r);
    });
  }

  Map<String, List> groupSet;

  String totalSpeed = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("下载管理"),
        actions: [
          IconButton(
            icon: Icon(Icons.help),
            onPressed: _showTipsDialog,
          )
        ],
      ),
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
                expandedHeaderPadding: EdgeInsets.symmetric(vertical: 10),
                expansionCallback: (i, e) {
                  setState(() {
                    itemExp[gks[i]] = !e;
                  });
                },
                children: gks
                    .map((k) => buildGroup(k, groupSet[k], itemExp[k] ?? false))
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
                  refreshStatus(false);
                },
                child: Text("暂停全部"),
              ),
              FlatButton(
                onPressed: () async {
                  await RRResManager.resumeAll();
                  refreshStatus(false);
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
    refreshStatus(false);
  }

  void playOnLocal(keyTitle, filename, name) async {
    Navigator.pushNamed(context, "/play", arguments: {
      'uri': filename,
      'title': name,
      'adTime': (await MySp).get(keyTitle, 0)
    });
  }

  String buildPlayTitle(item) {
    String name = item['mFilmName'];
    String season = item['mSeason'];
    if (season != null && season != "") {
      name += " S${season}E${item['mEpisode']}";
    }
    return name;
  }

  void play(keyTitle, filename, name) async {
    if (!Platform.isAndroid) {
      playOnLocal(keyTitle, filename, name);
      return;
    }
    var sp = await MySp;
    bool drpm = sp.get('dont_request_play_mode', false);
    if (drpm) {
      playOnLocal(keyTitle, filename, name);
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
                playOnLocal(keyTitle, filename, name);
              },
            ),
            FlatButton(
              child: Text("本地"),
              onPressed: () {
                Navigator.pop(c);
                playOnLocal(keyTitle, filename, name);
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
      headerBuilder: (c, i) => Slidable(
        actions: [
          IconSlideAction(
            caption: "删除",
            icon: Icons.delete,
            color: Colors.redAccent,
            onTap: () => deleteAll(items),
          ),
          IconSlideAction(
            caption: "跳过开头",
            icon: Icons.access_alarms_outlined,
            color: Colors.blueAccent,
            onTap: () => setSkipBeginning(keyTitle),
          ),
        ],
        actionPane: SlidableScrollActionPane(),
        child: Row(
          children: [
            Container(
              width: 10,
            ),
            InkWell(
              child: Hero(
                  child: Image.network(
                    img,
                    width: 40,
                    height: 60,
                  ),
                  tag: "img_${items[0]["mFilmId"]}"),
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
                Navigator.pushNamed(
                  context,
                  "/detail",
                  arguments: data,
                );
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
      ),
      body: ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: items.length,
        itemBuilder: (c, i) => buildItem(keyTitle, items[i]),
      ),
    );
  }

  Widget buildItem(keyTitle, Map item) {
    String name = "";
    String episode = item['mEpisode'];
    if (episode != null && episode != "" && episode != "null") {
      name += "第${episode}集";
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
                play(keyTitle, item['mFileName'], buildPlayTitle(item));
                //play
                break;
              case STATUS_DOWNLOADING:
                RRResManager.pauseByFileId(item['mFileId']);
                totalSpeed = "";
                refreshStatus(false);
                break;
              case STATUS_PAUSED:
                RRResManager.resumeByFileId(item['mFileId']);
                totalSpeed = "";
                refreshStatus(false);
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
                      play(keyTitle, item['mFileName'], buildPlayTitle(item));
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
          onTap: () => _requestDelete([item['mFileId']]),
        )
      ],
      actionPane: SlidableScrollActionPane(),
    );
  }

  void refreshStatus(bool isInit) {
    Future.wait(dataSet.map((item) {
      return RRResManager.getStatus(item).then((value) {
        if (item['status'] != STATUS_COMPLETE) {
          item['status'] = value;
        }
      });
    })).whenComplete(() =>
        setState(() {
          if (isInit) {
            groupSet.forEach((key, items) {
              itemExp[key] = false;
              items.forEach((item) {
                if (item['status'] != STATUS_COMPLETE) {
                  itemExp[key] = true;
                }
              });
            });
          }
        }));
  }

  @override
  void didUpdateWidget(DownloadManagerPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    refreshStatus(false);
  }

  Route myRoute;

  @override
  void initState() {
    super.initState();
    RRResManager.addEventListener(onReceiverData);
    refreshList(true);
    Future.delayed(Duration(seconds: 1), _showTutorial);
    Future.delayed(Duration(milliseconds: 100), () {
      myRoute = ModalRoute.of(context);
      _routes.add(myRoute);
    });
  }

  _showTutorial() async {
    var sp = await MySp;
    if (!mounted || sp.has(Constants.KEY_TUTORIAL_OF_DL)) {
      return;
    }
    sp.set(Constants.KEY_TUTORIAL_OF_DL, true);
    _showTipsDialog();
  }

  void refreshList(bool isInit) {
    RRResManager.getAllItems().then((value) {
      print("list: ==> " + value.toString());
      dataSet = value ?? [];
      _buildGroup();
      refreshStatus(isInit);
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
      if (season != null && season != "" && season != "null") {
        if (season == "102") {
          key += "mini剧";
        } else {
          key += "第${season}季";
        }
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
    _routes.remove(myRoute);
    RRResManager.removeEventListener(onReceiverData);
    super.dispose();
  }

  void deleteAll(List ss) {
    _requestDelete(ss.map((e) => e["mFileId"]).toList());
  }

  void _requestDelete(List fileIds) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (c) =>
          WrappedMaterialDialog(
            context,
            title: Text("确认删除？"),
            actions: [
              FlatButton(
                child: Text("确认"),
                onPressed: () async {
                  Navigator.pop(c);
                  fileIds.forEach((id) {
                    RRResManager.deleteDownload(id);
                  });
                  refreshList(false);
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
        builder: (c) => WrappedMaterialDialog(
          context,
          title: Text("提示"),
          content: Text(
            "1. 请不要同时开启人人官方应用，否则无法使用下载功能。\n"
                "2. 下载5%即可播放。\n"
                "3. 剧集左滑删除；分类标题右滑删除\n"
                "4. 下载目录：/sdcard/Android/data/cn.vove7.flutter_yyets/files/download\n"
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

  void setSkipBeginning(String keyTitle) async {
    dynamic sp = (await MySp);
    double skipSec = sp.get(keyTitle, 0).toDouble();
    double v = await showDialog(
        context: context,
        builder: (c) =>
            WrappedMaterialDialog(context,
              content: DialogSliderWidget(
                min: 0,
                max: 120,
                step: 1,
                initValue: skipSec,
              ),
              title: Text("设置跳过开头(单位s)"),
            )
    );
    print(v);
    if (v != null) {
      sp.set(keyTitle, v.toInt());
    }
  }
}

class DialogSliderWidget extends StatefulWidget {
  final double initValue;
  final double min;
  final double max;
  final int step;


  const DialogSliderWidget(
      {Key key, this.min, this.max, this.step, this.initValue})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SliderState();
  }

}

class SliderState extends State<DialogSliderWidget> {
  double v;
  int div;

  @override
  void initState() {
    super.initState();
    v = widget.initValue;
    div = (widget.max - widget.min) ~/ widget.step;
  }

  @override
  Widget build(BuildContext context) {
    return
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Slider(
            max: widget.max,
            min: widget.min,
            divisions: div,
            label: "${v.toInt()}s",
            value: v,
            onChanged: (double value) {
              print(value);
              setState(() {
                v = value;
              });
            },
          ),
          FlatButton(onPressed: () {
            Navigator.pop(context, v);
          }, child: Text("确定"))
        ],);
  }

}