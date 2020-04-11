import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_yyets/app/Api.dart';
import 'package:flutter_yyets/ui/load/LoadingStatus.dart';
import 'package:flutter_yyets/utils/toast.dart';
import 'package:flutter_yyets/utils/tools.dart';
import 'package:permission_handler/permission_handler.dart';

class ResInfoPage extends StatefulWidget {
  final Map info;

  ResInfoPage(this.info);

  @override
  State createState() => _ResInfoState();
}

class _ResInfoState extends State<ResInfoPage> {
  static const methodChannel = MethodChannel("cn.vove7.yy/download");

  Map _data;
  LoadingStatus _loadingStatus = LoadingStatus.LOADING;

  void _downloadAndPlay(String rrUri) async {
    print(rrUri);
    if (!Platform.isAndroid) {
      toast("边下边播仅支持安卓系统");
      return;
    }
    if (await Permission.storage.request().isGranted) {
      methodChannel.invokeMethod("download", rrUri).then((result) {
        print(result);
      });
    } else {
      toast("请授予存储权限");
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    Future apiCall;
    String channel = info['channel'];
    Future.delayed(Duration(milliseconds: 200), () {
      if (channel == 'tv') {
        apiCall = Api.getResInfo(
            id: info['id'], episode: info['episode'], season: info['season']);
      } else if (channel == 'movie') {
        apiCall = Api.getResInfo(id: info['id'], itemid: info['itemid']);
      }
      apiCall.then((data) {
        print(data);
        setState(() {
          _loadingStatus = LoadingStatus.NONE;
          _data = data;
        });
      }).catchError((e) {
        setState(() {
          _loadingStatus = LoadingStatus.ERROR;
        });
        _errText = e.message;
        toast(e.message);
      });
    });
  }

  Map get info => widget.info;

  String title() {
    String t = info['cnname'];
    if (info.containsKey('number')) {
      t += '-' + info['number'];
    } else if (info.containsKey('season_cn')) {
      t += info['season_cn'] + "-" + info['episode'];
    }
    return t;
  }

  String _errText = "资源加载失败，请重试";

  @override
  Widget build(BuildContext context) {
    bool canDownPlay =
        _data['item_app'] != null && _data['item_app']['name'] != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(title()),
      ),
      body: _loadingStatus == LoadingStatus.NONE
          ? buildBody(canDownPlay)
          : getWidgetByLoadingStatus(_loadingStatus, _loadData,
              errText: _errText),
      floatingActionButton: canDownPlay
          ? FloatingActionButton(
              backgroundColor: Colors.lightBlue,
              onPressed: () {
                _downloadAndPlay(_data['item_app']['name']);
              },
              child: Icon(
                Icons.play_arrow,
                color: Colors.white,
              ),
            )
          : null,
    );
  }

  var itemExp = <bool>[];

  Widget buildBody(bool canDownPlay) {
    List resList = _data['item_list'] ?? [];
    if (itemExp.length != resList.length) {
      itemExp = resList.map((i) => false).toList();
    }
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          FlatButton(
            onPressed: () {
              if (canDownPlay) {
                _downloadAndPlay(_data['item_app']['name']);
              } else {
                toast("不支持边下边播");
              }
            },
            child: Text(canDownPlay ? "边下边播" : "暂无边下边播资源"),
          ),
          Container(
            margin: EdgeInsets.all(10),
            child: ExpansionPanelList(
                expansionCallback: (i, isExp) {
                  setState(() {
                    itemExp[i] = !itemExp[i];
                  });
                },
                children: resList.asMap().keys.map((i) {
                  var item = resList[i];
                  List fs = item['files'];
                  return ExpansionPanel(
                      canTapOnHeader: true,
                      isExpanded: itemExp[i],
                      body: GridView.extent(
                        shrinkWrap: true,
                        children: fs.map((file) {
                          var pwd = file['passwd'];
                          return Card(
                              color: Colors.black26,
                              child: InkWell(
                                onTap: () {
                                  String pwd = file['passwd'];
                                  if (pwd != null && pwd.isNotEmpty) {
                                    setClipboardData(pwd);
                                    toastLong("网盘密码已复制：$pwd");
                                  }

                                  launchUri(file['address']).then((val) {
                                    if (!val) {
                                      toast("请安装迅雷等下载软件");
                                    }
                                  }).catchError((e) {
                                    print(e);
                                    toast(e);
                                  });
                                },
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                        "way: " + file['way'].toString() ?? ""),
                                    Text(file['way_name'] ?? ""),
                                    (pwd == null || pwd.isEmpty)
                                        ? Container()
                                        : Text(file['passwd'] ?? ""),
                                  ],
                                ),
                              ));
                        }).toList(),
                        physics: NeverScrollableScrollPhysics(),
                        childAspectRatio: 1.3,
                        maxCrossAxisExtent: 90,
                      ),
                      headerBuilder: (BuildContext context, bool isExpanded) {
                        var size = item['size']?.toString();
                        return Container(
                          padding: EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                item['format_tip'] ?? "",
                                style: TextStyle(color: Colors.blueAccent),
                              ),
                              size == null || size.isEmpty
                                  ? Container()
                                  : Text(size.toString()),
                              Text(item['dateline'].toString() ?? "")
                            ],
                          ),
                        );
                      });
                }).toList()),
          ),
        ],
      ),
    );
  }
}
