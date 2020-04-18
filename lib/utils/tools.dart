import 'dart:io';

import 'package:flutter/material.dart';
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
  Clipboard.setData(ClipboardData(text: data));
}

void share(String text, {String subject}) {
  if (Platform.isWindows) {
    setClipboardData((subject ?? "") + "\n\n" + text);
    toastLong("分享内容已复制");
    return;
  }
  Share.share(text, subject: subject);
}

dynamic nullEmptyElse(value, elseValue) {
  if (value == null) {
    return elseValue;
  }
  if (value is String) {
    if (value.isEmpty) {
      return elseValue;
    }
    return value;
  } else {
    return value ?? elseValue;
  }
}

bool get isMobilePhone {
  try {
    return Platform.isFuchsia || Platform.isAndroid || Platform.isIOS;
  } catch (e) {
    //web
    return false;
  }
}

extension Context on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}
