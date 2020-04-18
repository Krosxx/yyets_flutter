import 'dart:async';
import 'dart:io';

import 'package:auto_orientation/auto_orientation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_yyets/utils/mysp.dart';
import 'package:flutter_yyets/utils/times.dart';
import 'package:flutter_yyets/utils/toast.dart';
import 'package:screen/screen.dart';
import 'package:video_player/video_player.dart';
import 'package:volume_watcher/volume_watcher.dart';

class LocalVideoPlayerPage extends StatefulWidget {
  final String resRri;
  final String title;

  LocalVideoPlayerPage(Map data)
      : this.resRri = data['uri'],
        this.title = data['title'];

  @override
  State createState() => _PageState();
}

const DISPLAY_MODE_KEEP_ASPECT = 0;
const DISPLAY_MODE_COVERED = 1;

class _PageState extends State<LocalVideoPlayerPage> {
  VideoPlayerController _controller;

  //滑动调节进度结束后是否继续播放状态
  bool _cacheStatus;

  //视频总长度
  int _totalLength = 100;

  //视频当前进度
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
  int _maxVolume = 0;

  //退出时恢复亮度
  double _disposeScreenBrightness = 0;

  //显示模式 [DISPLAY_MODE_KEEP_PROPORTION] [DISPLAY_MODE_COVERED]
  int _displayMode;

  Future<void> initPlatformState() async {
    num initVolume = await VolumeWatcher.getCurrentVolume;
    num maxVolume = await VolumeWatcher.getMaxVolume;

    if (!mounted) return;
    this._volumePercentage = initVolume / maxVolume;
    this._maxVolume = maxVolume;
    print("音量：${initVolume}/${maxVolume}");
  }

  @override
  void initState() {
    super.initState();

    initPlatformState();
    //横屏
    Screen.brightness.then((value) {
      _screenBrightness = value;
      _disposeScreenBrightness = value;
      print("screenBrightness: $value");
    });
    AutoOrientation.landscapeAutoMode();
    //隐藏状态栏 导航栏
    SystemChrome.setEnabledSystemUIOverlays([]);
    _controller = VideoPlayerController.file(File(widget.resRri))
      ..initialize().then((_) {
        //上次播放进度
        MySp.then((sp) {
          _displayMode = sp.get("display_mode", DISPLAY_MODE_KEEP_ASPECT);
          setState(() {
            int pos = sp.get("pos_${widget.resRri.hashCode}", 0);
            _totalLength = _controller.value.duration.inMilliseconds;
            //结尾
            if (_totalLength - pos < 3000) {
              pos = 0;
            }
            _controller.seekTo(Duration(milliseconds: pos)).whenComplete(() {
              setState(() {
                _playPos = pos;
                _controller.play();
              });
            });
            startDelayHidePanel();
            Screen.keepOn(true);
          });
        });
      }).catchError((e) {
        print(e);
        toast(e);
      });
    _controller.addListener(() {
      int now = DateTime.now().millisecondsSinceEpoch;
      _controller.position.then((p) {
        int pos = p.inMilliseconds;
        if (pos >= _totalLength) {
          onPlayFinished();
        }
        if (now - _lastSavePos > 1000) {
          _lastSavePos = now;
          MySp.then((sp) {
            sp.set("pos_${widget.resRri.hashCode}", pos);
          });
        }
        //未在调节进度时
        if (!_centerProgressbarVisibility) {
          _playPos = pos;
        }
      });
    });
  }

  void onPlayFinished() {
    Navigator.pop(context);
  }

  void togglePlayStatus() {
    startDelayHidePanel();
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        Screen.keepOn(false);
      } else {
        _controller.play();
        Screen.keepOn(true);
      }
    });
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
  double verticalDragStartY = 0;

//  double tmpScreenBrightness = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: _controller.value.initialized
                ? GestureDetector(
                    onVerticalDragStart: (DragStartDetails d) async {
                      //确定 左右
                      var size = MediaQuery.of(context).size;
                      print("screen size: ${size.width}");
                      verticalDragStartY = d.localPosition.dy;
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
                      var size = MediaQuery.of(context).size;
//                double dy = verticalDragStartY - d.localPosition.dy;
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
                          VolumeWatcher.setVolume(
                              _maxVolume * _volumePercentage);
                        });
                        print("_volumePercentage: $_volumePercentage");
                      }
                    },
                    onVerticalDragEnd: (DragEndDetails d) {
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
                      _startDragPos = _playPos;
                      print("onHorizontalDragStart  ${_playPos}");
                      _cacheStatus = _controller.value.isPlaying;
                      setState(() {
                        _centerProgressbarVisibility = true;
                        _controller.pause();
                      });
                    },
                    onHorizontalDragEnd: (DragEndDetails d) {
                      startDelayHidePanel();
                      print("DragEndDetails  ${_playPos}");
                      setState(() {
                        _centerProgressbarVisibility = false;
                        _controller
                            .seekTo(Duration(milliseconds: _playPos))
                            .whenComplete(() {
                          if (_cacheStatus) {
                            setState(() {
                              _controller.play();
                            });
                          }
                        });
                      });
                    },
                    onHorizontalDragUpdate: (DragUpdateDetails d) {
                      double dx = d.delta.dx;
                      if (dx == 0.0) return;
                      _playPos += (d.delta.dx * 100).toInt();
                      print("$dx,  ${_playPos}");

                      if (_playPos > _totalLength) {
                        print("_playPos > _totalLength");
                        _playPos = _totalLength;
                      }
                      setState(() {});
                    },
                    onDoubleTap: togglePlayStatus,
                    onTap: toggleControllerPanel,
                    child: _displayMode == 0
                        ? AspectRatio(
                            aspectRatio: _controller.value.aspectRatio,
                            child: VideoPlayer(_controller),
                          )
                        : VideoPlayer(_controller),
                  )
                : Container(
                    color: Colors.black,
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
                          value: _playPos.toDouble() / _totalLength,
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
          Transform.translate(
            offset: Offset(0, _playControlVisibility ? 0 : -panelHeight),
            child: Align(
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
                  actions: [
                    IconButton(
                      icon: Icon(
                        Icons.aspect_ratio,
                        color: _displayMode == DISPLAY_MODE_KEEP_ASPECT
                            ? Colors.blueAccent
                            : Colors.white,
                      ),
                      onPressed: () =>
                          changeDisplayMode(DISPLAY_MODE_KEEP_ASPECT),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.settings_overscan,
                        color: _displayMode == DISPLAY_MODE_COVERED
                            ? Colors.blueAccent
                            : Colors.white,
                      ),
                      onPressed: () => changeDisplayMode(DISPLAY_MODE_COVERED),
                    ),
                  ],
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  leading: BackButton(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(0, _playControlVisibility ? 0 : panelHeight),
            child: Align(
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
                          _controller.value.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
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
                            _cacheStatus = _controller.value.isPlaying;
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
                              _controller
                                  .seekTo(Duration(milliseconds: (p).toInt()))
                                  .whenComplete(() {
                                if (_cacheStatus) {
                                  setState(() => _controller.play());
                                }
                              });
                            });
                          },
                          onChanged: (p) =>
                              setState(() => _playPos = p.toInt()),
                        ),
                      ),
                      Text(
                        formatLength(_totalLength),
                        style: TextStyle(color: Colors.white),
                      ),
                      Container(
                        width: 10,
                      )
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

  @override
  void dispose() {
    _controller.dispose();
    AutoOrientation.fullAutoMode();
    SystemChrome.setEnabledSystemUIOverlays(
        [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    Screen.keepOn(false);
    Screen.setBrightness(_disposeScreenBrightness);
    super.dispose();
  }

  void changeDisplayMode(int mode) {
    startDelayHidePanel();
    if (_displayMode == mode) {
      return;
    }
    MySp.then((sp) => sp.set("display_mode", mode));
    setState(() {
      _displayMode = mode;
    });
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
            width: 250,
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
                  Container(width: 10,),
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
