import 'dart:async';

import 'package:auto_orientation/auto_orientation.dart';
import 'package:fijkplayer/fijkplayer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_yyets/ui/widgets/visibility.dart';
import 'package:flutter_yyets/ui/widgets/wrapped_material_dialog.dart';
import 'package:flutter_yyets/utils/RRResManager.dart';
import 'package:flutter_yyets/utils/mysp.dart';
import 'package:flutter_yyets/utils/times.dart';
import 'package:screen/screen.dart';
import 'package:volume_watcher/volume_watcher.dart';

class VideoPlayerPage extends StatefulWidget {
  final String resUri;
  final String title;
  final int type;

  // 播放起始位置 [跳过广告]
  final int startPos;

  static const int TYPE_FILE = 0;
  static const int TYPE_NETWORK = 1;

  VideoPlayerPage(Map data)
      : this.resUri = data['uri'],
        this.title = data['title'],
        this.type = data['type'] ?? 0,
        this.startPos = (data['adTime'] ?? 0) * 1000;

  @override
  State createState() => _PageState();
}

class _PageState extends State<VideoPlayerPage> {
  FijkPlayer _controller = FijkPlayer();

  //滑动调节进度结束后是否继续播放状态
  bool _cacheStatus;

  //视频总长度 ms
  int _totalLength = 0;

  double get playProgress => _totalLength == 0 ? 0.0 : _playPos / _totalLength;

  //视频当前进度 ms
  int _playPos = 0;

  //高度
  double panelHeight = 60;

  //进度调节块显隐标志
  bool _centerProgressbarVisibility = false;

  //亮度指示条显隐标志
  bool _screenBrightnessPanelVisibility = false;

  //音量指示条显隐标志
  bool _volumePanelVisibility = false;

  //格式化当前进度时间
  String get _playTime => formatLength(_playPos);

  //监听进度 上次保存进度时间
  int _lastSavePos = 0;

  //屏幕亮度
  double _screenBrightness = 0;

  //音量百分比
  double _volumePercentage = 0;

  //最大音量
  double _maxVolume = 0;

  //倍速
  double _speed = null;

  bool get isPlaying => _controller.state == FijkState.started;

  Future<void> initPlatformState() async {
    num initVolume = await VolumeWatcher.getCurrentVolume;
    num maxVolume = await VolumeWatcher.getMaxVolume;

    if (!mounted) return;
    this._volumePercentage = initVolume / maxVolume;
    this._maxVolume = maxVolume;
    print("音量：${initVolume}/${maxVolume}");
  }

  void onStop() {
    print("onStop");
    _controller.pause();
  }

  @override
  void initState() {
    print("startPos: ${widget.startPos}");
    super.initState();
    RRResManager.addOnStopListener(onStop);

    initPlatformState();
    //横屏
    Screen.brightness.then((value) {
      _screenBrightness = value;
      print("screenBrightness: $value");
    });
    AutoOrientation.landscapeAutoMode();
    //隐藏状态栏 导航栏
    SystemChrome.setEnabledSystemUIOverlays([]);
    _controller.setDataSource(widget.resUri, autoPlay: true);
    _controller.onCurrentPosUpdate.listen(onCurrentPosUpdate);
  }

  prepareOnce() async {
    if (_totalLength != 0) return;
    if (_controller.state == FijkState.error) {
      showUnSupportDialog("");
    }
    var info = _controller.value;
    _totalLength = info.duration.inMilliseconds;
    if (_totalLength == 0) {
      print("获取时长失败");
      return;
    }
    //上次播放进度
    var sp = await MySp;
    int pos = sp.get("pos_${widget.resUri.hashCode}", 0);

    print("VideoInfo $info");

    print("start pos: $pos");
    //结尾
    if (_totalLength - pos < 3000 || pos < widget.startPos) {
      //跳过片头/广告
      pos = widget.startPos;
    } else if (pos > 10000) {
      //后退2s
      pos -= 2000;
    }
    print("seek to $pos");
    _controller.seekTo(pos).whenComplete(() {
      _playPos = pos;
    });
    startDelayHidePanel();
    Screen.keepOn(true);
  }

  void onCurrentPosUpdate(Duration event) {
    //此处初始化_totalLength prepareAsync 方法无法获取 duration
    prepareOnce();
    int pos = event.inMilliseconds;
    if (pos >= _totalLength || _controller.state == FijkState.completed) {
      onPlayFinished();
    }
    //未在调节进度时
    if (!mounted || _centerProgressbarVisibility || !isPlaying) {
      return;
    }
    var vi = _controller.value;
    int now = DateTime.now().millisecondsSinceEpoch;
    _totalLength = vi.duration.inMilliseconds;


    if (now - _lastSavePos > 800 && pos > 0) {
      _lastSavePos = now;
      MySp.then((sp) {
        sp.set("pos_${widget.resUri.hashCode}", pos);
      });
    }
    _playPos = pos;
    //更新进度条
    if (_playControlVisibility && mounted) {
      setState(() {});
    }
  }

  void onPlayFinished() {
    print("结束");
    _controller.pause();
    Screen.keepOn(false);
    showDialog(
      context: context,
      builder: (c) => WrappedMaterialDialog(
        c,
        title: Text("播放结束"),
        actions: [
          FlatButton(
            child: Text("重播"),
            onPressed: () {
              _controller.seekTo(0);
              _controller.start();
              Screen.keepOn(true);
              Navigator.pop(c);
            },
          ),
          FlatButton(
            child: Text("退出"),
            onPressed: () {
              Navigator.pop(c);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void togglePlayStatus() async {
    startDelayHidePanel();
    if (isPlaying) {
      await _controller.pause();
      Screen.keepOn(false);
    } else {
      _controller.start();
      await Screen.keepOn(true);
    }
    setState(() {});
  }

  bool _playControlVisibility = true;

  void toggleControllerPanel() {
    setState(() {
      _playControlVisibility = !_playControlVisibility;
      startDelayHidePanel();
    });
  }

  Timer delayHideTimer;

  void startDelayHidePanel() {
    delayHideTimer?.cancel();
    delayHideTimer?.cancel();
    delayHideTimer = Timer(Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _playControlVisibility = false;
        });
      }
    });
  }

  int _startDragPos = 0;
  int verticalDragAction = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: GestureDetector(
              onVerticalDragStart: (DragStartDetails d) async {
                var size = MediaQuery.of(context).size;
                print("screen size: ${size.width}");
                double boundary = size.height * 0.2;
                var dy = d.globalPosition.dy;
                //上下边缘不处理
                if (dy < boundary || dy > size.height - boundary) {
                  verticalDragAction = -1;
                  return;
                }
                //确定 左右
                if (d.localPosition.dx < size.width / 2) {
                  print("左侧");
                  setState(() {
                    _screenBrightnessPanelVisibility = true;
                  });
                  verticalDragAction = 0;
                } else {
                  print("右侧");
                  //防止 手动按键调节；重新获取音量
                  num initVolume = await VolumeWatcher.getCurrentVolume;
                  num maxVolume = await VolumeWatcher.getMaxVolume;
                  this._volumePercentage = initVolume / maxVolume;
                  setState(() {
                    _volumePanelVisibility = true;
                  });
                  verticalDragAction = 1;
                }
              },
              onVerticalDragUpdate: (DragUpdateDetails d) {
                if (verticalDragAction == -1) {
                  return;
                }
                var size = MediaQuery.of(context).size;
                double dy = d.delta.dy;
                double dyPercent = (dy / size.height * 1.5);
                if (dy == 0) {
                  return;
                }
                print(dy);
                if (verticalDragAction == 0) {
                  _screenBrightness -= dyPercent;
                  if (_screenBrightness < 0) {
                    _screenBrightness = 0;
                  } else if (_screenBrightness > 1) {
                    _screenBrightness = 1;
                  }
                  print("_screenBrightness $_screenBrightness");
                  setState(() {
                    Screen.setBrightness(_screenBrightness);
                  });
                } else {
                  _volumePercentage -= dyPercent;

                  if (_volumePercentage < 0) {
                    _volumePercentage = 0;
                  } else if (_volumePercentage > 1) {
                    _volumePercentage = 1;
                  }
                  setState(() {
                    VolumeWatcher.setVolume(_maxVolume * _volumePercentage);
                  });
                  print("_volumePercentage: $_volumePercentage");
                }
              },
              onVerticalDragEnd: (DragEndDetails d) {
                if (verticalDragAction == -1) {
                  return;
                }
                if (verticalDragAction == 0) {
                  setState(() {
                    _screenBrightnessPanelVisibility = false;
                  });
                } else {
                  setState(() {
                    _volumePanelVisibility = false;
                  });
                }
                print("onVerticalDragEnd");
              },
              onHorizontalDragStart: (DragStartDetails d) {
                //todo 利用onHorizontalDragDown拦截?
                var size = MediaQuery.of(context).size;
                double boundary = size.width * 0.1;
                var x = d.globalPosition.dx;
                //左右边缘不处理
                if (x < boundary || x > size.width - boundary) {
                  return;
                }
                _startDragPos = _playPos;
                print("onHorizontalDragStart  ${_playPos}");
                _cacheStatus = isPlaying;
                setState(() {
                  _centerProgressbarVisibility = true;
                  _controller.pause();
                });
              },
              onHorizontalDragEnd: (DragEndDetails d) {
                if (!_centerProgressbarVisibility) {
                  return;
                }
                startDelayHidePanel();
                print("DragEndDetails  ${_playPos}");
                setState(() {
                  _centerProgressbarVisibility = false;
                  _controller.seekTo(_playPos).whenComplete(() {
                    if (_cacheStatus) {
                      setState(() {
                        _controller.start();
                      });
                    }
                  });
                });
              },
              onHorizontalDragUpdate: (DragUpdateDetails d) {
                if (!_centerProgressbarVisibility) {
                  return;
                }
                double dx = d.delta.dx;
                if (dx == 0.0) return;
                _playPos += (d.delta.dx * 500).toInt();
                print("$dx,  ${_playPos}");

                if (_playPos > _totalLength) {
                  print("_playPos > _totalLength");
                  _playPos = _totalLength;
                } else if (_playPos < 0) {
                  _playPos = 0;
                }
                setState(() {});
              },
              onDoubleTap: togglePlayStatus,
              onTap: toggleControllerPanel,
              child: FijkView(
                player: _controller,
                color: Colors.black,
                panelBuilder: (p, d, c, v, t) => Container(),
              ),
            ),
          ),
          _StatusPanel(
            _screenBrightnessPanelVisibility,
            _screenBrightness,
            Icon(
              _screenBrightness == 0
                  ? Icons.brightness_low
                  : Icons.brightness_high,
              color: Colors.white,
            ),
            Alignment.centerRight,
            60,
          ),
          _StatusPanel(
            _volumePanelVisibility,
            _volumePercentage,
            Icon(
              _volumePercentage == 0 ? Icons.volume_mute : Icons.volume_up,
              color: Colors.white,
            ),
            Alignment.centerLeft,
            -60,
          ),
          Offstage(
            offstage: !_centerProgressbarVisibility,
            child: Center(
              child: Container(
                padding: EdgeInsets.all(10),
                height: 70,
                width: 200,
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 5,
                      width: 200,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2.5),
                        child: LinearProgressIndicator(
                          backgroundColor: Colors.white,
                          value: playProgress,
                        ),
                      ),
                    ),
                    Container(height: 12),
                    Text(
                      () {
                        int offSecs = (_playPos - _startDragPos) ~/ 1000;
                        return _playTime +
                            "\t ${offSecs > 0 ? "+" : ""}${offSecs}s";
                      }(),
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                )),
              ),
            ),
          ),
          Visible(
            visible: _playControlVisibility,
            childBuilder: () => Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                  colors: [Colors.black54, Colors.transparent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )),
                height: panelHeight,
                alignment: Alignment.centerLeft,
                child: AppBar(
                  title: Text(
                    widget.title,
                    style: TextStyle(color: Colors.white),
                  ),
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  leading: BackButton(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          Visible(
            visible: _playControlVisibility,
            childBuilder: () => Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                  colors: [Colors.black54, Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                )),
                width: double.infinity,
                height: panelHeight,
                child: Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: togglePlayStatus,
                        icon: Icon(
                          isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        _playTime,
                        style: TextStyle(color: Colors.white),
                      ),
                      Expanded(
                        child: Slider(
                          activeColor: Colors.white,
                          inactiveColor: Colors.white24,
                          min: 0.0,
                          label: _playTime,
                          max: _totalLength.toDouble(),
                          value: _playPos > _totalLength
                              ? _totalLength.toDouble()
                              : _playPos.toDouble(),
                          onChangeStart: (d) {
                            _startDragPos = _playPos;
                            _cacheStatus = isPlaying;
                            print("onChangeStart:  $_cacheStatus");
                            delayHideTimer?.cancel();
                            setState(() {
                              _centerProgressbarVisibility = true;
                              _controller.pause();
                            });
                          },
                          onChangeEnd: (p) {
                            print("onChangeEnd:  $_cacheStatus");
                            startDelayHidePanel();
                            _playPos = p.toInt();
                            setState(() {
                              _centerProgressbarVisibility = false;
                              _controller.seekTo(_playPos).whenComplete(() {
                                if (_cacheStatus) {
                                  _controller.start();
                                }
                              });
                            });
                          },
                          onChanged: (p) =>
                              setState(() => _playPos = p.toInt()),
                        ),
                      ),
                      InkResponse(
                        child: PopupMenuButton(
                          onSelected: (v) {
                            setState(() {
                              _speed = v;
                              _controller.setSpeed(v);
                            });
                          },
                          itemBuilder: (BuildContext context) => _speeds
                              .map((e) => PopupMenuItem(
                                  child: Text(
                                    "${e}X",
                                    style: e == (_speed ?? 1.0)
                                        ? TextStyle(
                                            color:
                                                Theme.of(context).accentColor)
                                        : null,
                                  ),
                                  value: e))
                              .toList(),
                          child: Text(
                            _speed == null ? "倍速" : "${_speed}X",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      Container(width: 10),
                      Text(
                        formatLength(_totalLength),
                        style: TextStyle(color: Colors.white),
                      ),
                      Container(width: 10)
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  var _speeds = [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];

  @override
  void dispose() {
    _controller.pause();
    _controller.release();
    RRResManager.removeOnStopListener(onStop);
    AutoOrientation.fullAutoMode();
    SystemChrome.setEnabledSystemUIOverlays(
        [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    Screen.keepOn(false);
    Screen.setBrightness(-1);

    super.dispose();
  }

  void showUnSupportDialog(e) {
    showDialog(
      context: context,
      builder: (c) => WrappedMaterialDialog(
        c,
        title: Text("不支持该视频，$e"),
        content: Text("请使用外部播放器播放"),
        actions: [
          FlatButton(
            child: Text("使用外部播放器"),
            onPressed: () {
              RRResManager.playByExternal(widget.resUri);
              Navigator.pop(c);
              Navigator.pop(context);
            },
          ),
          FlatButton(
            child: Text("退出"),
            onPressed: () {
              Navigator.pop(c);
              Navigator.pop(context);
            },
          )
        ],
      ),
    );
  }
}

class _StatusPanel extends StatelessWidget {
  final bool visibility;
  final double progress;
  final Icon icon;

  final AlignmentGeometry alignment;
  final double offsetY;

  _StatusPanel(
      this.visibility, this.progress, this.icon, this.alignment, this.offsetY);

  @override
  Widget build(BuildContext context) {
    return Offstage(
      offstage: !visibility,
      child: Align(
        alignment: alignment,
        child: Transform.translate(
          offset: Offset(offsetY, 0),
          child: Container(
            height: 20,
            width: 200,
            child: Transform.rotate(
              angle: -3.1415926 / 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //TODO 优化 垂直进度条
                  Transform.rotate(
                    child: icon,
                    angle: 3.1415926 / 2,
                  ),
                  Container(
                    width: 10,
                  ),
                  Container(
                    height: 5,
                    width: 150,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2.5),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
