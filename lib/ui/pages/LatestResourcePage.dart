import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_yyets/app/Api.dart';
import 'package:flutter_yyets/ui/pages/LoadingPageState.dart';
import 'package:flutter_yyets/ui/widgets/no_counter_text.dart';
import 'package:flutter_yyets/ui/widgets/visibility.dart';
import 'package:flutter_yyets/ui/widgets/wrapped_material_dialog.dart';
import 'package:flutter_yyets/utils/RRResManager.dart';
import 'package:flutter_yyets/utils/toast.dart';
import 'package:flutter_yyets/utils/tools.dart';

class LatestResourcePage extends StatefulWidget {
  @override
  State createState() => _ResPageState();
}

class _ResPageState extends LoadingPageState<LatestResourcePage> {
  TextEditingController queryController;

  String query = "";

  @override
  Future<List> fetchData(int page) {
    if (query == "") {
      return Api.latestResource(page);
    } else {
      return Api.queryRRResource(query, page);
    }
  }

  String _toUrl(item) {
    return "yyets://N=${item['file_name']}|S=${item['file_size']}|H=${item['fileid']}|";
  }

  @override
  Widget buildItem(BuildContext context, int index, dynamic item) {
    return ListTile(
      onTap: () => requestDownload(item),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      title: Text(item['file_name']),
      trailing: Icon(Icons.file_download),
      onLongPress: () => showDebugInfo(context, item),
      subtitle: Text(item['create_time']),
    );
  }

  @override
  Widget build(BuildContext context) {
    var list = super.build(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("最新资源"),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.maxFinite,
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: TextField(
              buildCounter: NoCounterText,
              maxLength: 20,
              onSubmitted: (_) => submitQuery(),
              decoration: InputDecoration(
                counter: Container(),
                contentPadding: EdgeInsets.all(18),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(200),
                    borderSide: BorderSide(width: 0, color: Colors.blueAccent)),
                suffixIcon: IconButton(
                  icon: Icon(
                    Icons.search,
                    color: Theme.of(context).backgroundColor,
                  ),
                  onPressed: submitQuery,
                ),
              ),
              controller: queryController,
            ),
          ),
          Expanded(child: list)
        ],
      ),
    );
  }

  void submitQuery() {
    query = queryController.text.trim();
    if (query != "") {
      refresh();
    }
  }

  @override
  void initState() {
    super.initState();
    queryController = TextEditingController();
  }

  void requestDownload(item) {
    var rrUri = _toUrl(item);
    var magnetUrl = item['magnet_url'];
    if (magnetUrl == "") {
      magnetUrl = null;
    }
    showDialog(
      context: context,
      builder: (c) => WrappedMaterialDialog(
        c,
        enableCloseButton: true,
        onCloseButtonClicked: () => Navigator.pop(c),
        title: Text("确认下载"),
        content: SelectableText(
            rrUri + (magnetUrl == null ? "" : "\n\n磁力：$magnetUrl")),
        actions: [
          Visible(
            visible: magnetUrl != null,
            childBuilder: () => FlatButton(
              child: Text("使用迅雷下载"),
              onPressed: () {
                launchUri(item['magnet_url']).catchError((e) {
                  toast("请安装迅雷");
                });
                Navigator.pop(c);
              },
            ),
          ),
          FlatButton(
            child: Text("下载"),
            onPressed: () {
              var id = item['fileid'].hashCode;
              if (id > 0) id = -id;
              RRResManager.addTask(id.toString(), rrUri, "").then((value) {
                Navigator.pushReplacementNamed(c, "/download");
              }).catchError((e) => toast(e.toString()));
            },
          ),
        ],
      ),
    );
  }
}
