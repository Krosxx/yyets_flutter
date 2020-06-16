import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_yyets/app/Api.dart';
import 'package:flutter_yyets/main.dart';
import 'package:flutter_yyets/ui/widgets/wrapped_material_dialog.dart';
import 'package:flutter_yyets/utils/toast.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

Future launchUri(String uri) async {
  try {
    if (Platform.isWindows) {
      Process.start('explorer "$uri"', []);
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

extension Context on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}

extension PlatformExt on Platform {
  static bool get isWeb {
    try {
      return Platform.operatingSystem == null;
    } catch (e) {
      return true;
    }
  }

  static bool get isWindows {
    try {
      return Platform.isWindows;
    } catch (e) {
      return false;
    }
  }

  static bool get isMobilePhone {
    try {
      return Platform.isFuchsia || Platform.isAndroid || Platform.isIOS;
    } catch (e) {
      //web
      return false;
    }
  }
}

int version2Number(String version) {
  int num = 0;
  var ss = version.split('.');
  var i = (ss.length - 1) * 2;
  for (var value in ss) {
    num += int.parse(value) * pow(10, i);
    i -= 2;
  }
  print("$version >> $num");
  return num;
}

Future<bool> checkUpgrade(context) async {
  var topRoundBorder = RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  );
  void _showUpgradeDialog(version, content) {
    showModalBottomSheet(
      shape: topRoundBorder,
      context: context,
      builder: (c) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            shape: topRoundBorder,
            automaticallyImplyLeading: false,
            elevation: 1,
            title: Text("发现新版本 $version"),
          ),
          body: Container(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text(content == null || content == "" ? "无更新内容" : content),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.blueAccent,
            tooltip: "下载",
            child: Icon(
              Icons.file_download,
              color: Colors.white,
            ),
            onPressed: () {
              launchUri("https://gitee.com/Vove/yyets_flutter/releases");
              Navigator.pop(c);
            },
          ),
        );
      },
    );
  }

  var data = await Api.checkUpgrade();

  print(data);
  if (version2Number(data['tag_name']) > version2Number(MyApp.VERSION)) {
    _showUpgradeDialog(data['name'], data['body']);
    return true;
  } else {
    return false;
  }
}

void showDebugInfo(BuildContext context, data) {
  showDialog(
    context: context,
    builder: (c) => WrappedMaterialDialog(
      c,
      title: Text("DebugInfo"),
      content: SelectableText(_prettyFormat(data)),
    ),
  );
}

String _prettyFormat(data) {
  if (data is Map) {
    return data.entries.map((e) => "${e.key}: ${e.value}").join("\n");
  }

  return data.toString();
}

//格式化文件大小
String renderSize(int value) {
  if (null == value || value == 0) {
    return "0B";
  }
  var unitArr = ["Bytes", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
  var index = 0;
  var srcsize = value.toDouble();
  index = (log(srcsize) / log(1024)).floor();
  dynamic size = srcsize / pow(1024, index);
  size = size.toStringAsFixed(2); //保留的小数位数
  return size + unitArr[index];
}
