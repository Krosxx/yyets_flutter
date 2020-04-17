import 'dart:io';

import 'package:auto_orientation/auto_orientation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_yyets/utils/mysp.dart';
import 'package:flutter_yyets/utils/toast.dart';
import 'package:video_player/video_player.dart';

class LocalVideoPlayerPage extends StatefulWidget {
  final String resRri;

  LocalVideoPlayerPage(this.resRri);

  @override
  State createState() => _PageState();
}

class _PageState extends State<LocalVideoPlayerPage> {
  VideoPlayerController _controller;

  int _lastSavePos = 0;

  @override
  void initState() {
    super.initState();
    AutoOrientation.landscapeAutoMode();
    SystemChrome.setEnabledSystemUIOverlays([]);
    _controller = VideoPlayerController.file(File(widget.resRri))
      ..initialize().then((_) {
        MySp.then((sp) {
          setState(() {
            int pos = sp.get("pos_${widget.resRri.hashCode}", 0);
            if (_controller.value.duration.inMilliseconds - pos < 3000) {
              pos = 0;
            }
            _controller
                .seekTo(Duration(milliseconds: pos))
                .whenComplete(() => _controller.play());
          });
        });
      }).catchError((e) {
        print(e);
        toast(e);
      });
    _controller.addListener(() {
      int now = DateTime.now().millisecondsSinceEpoch;
      if (now - _lastSavePos > 1000) {
        _lastSavePos = now;
        _controller.position.then((p) {
          int pos = p.inMilliseconds;
          MySp.then((sp) {
            sp.set("pos_${widget.resRri.hashCode}", pos);
          });
          print("listened position ${pos}");
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _controller.value.initialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : Container(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _controller.value.isPlaying
                ? _controller.pause()
                : _controller.play();
          });
        },
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    AutoOrientation.fullAutoMode();
    SystemChrome.setEnabledSystemUIOverlays(
        [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    super.dispose();
  }
}
