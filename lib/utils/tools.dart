import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_yyets/utils/toast.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

Future launchUri(String uri) async {
  try {
    if (Platform.isWindows) {
      Process.start("explorer ", [uri]);
      return true;
    }
  } catch (e) {}
  if (await canLaunch(uri)) {
    return await launch(uri);
  } else {
    throw "canot open $uri";
  }
}

///
///复制到剪切板
///兼容windows
///
setClipboardData(String data) {
  try {
    if (Platform.isWindows) {
      var tf = File("tmp_clip.txt");
      tf.writeAsStringSync(data);
      String path = tf.absolute.parent.path;
      path = path.replaceAll('\\', "/");
      print(path);
      Process.run("clip < tmp_clip.txt", [],
              runInShell: true, workingDirectory: path)
          .whenComplete(() => tf.deleteSync());
      return;
    }
  } catch (e) {}
  Clipboard.setData(ClipboardData(text: "123"));
}

void share(String text, {String subject}) {
  if (Platform.isWindows) {
    //todo
    toastLong("暂不支持Win端分享");
    return;
  }
  Share.share(text, subject: subject);
}
