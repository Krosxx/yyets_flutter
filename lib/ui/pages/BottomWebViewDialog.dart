import 'package:flutter/material.dart';
import 'package:flutter_yyets/ui/widgets/adjustable_bottomsheet.dart';
import 'package:flutter_yyets/utils/tools.dart';
import 'package:webview_flutter/webview_flutter.dart';

class BottomWebViewDialog {
  static Future show(BuildContext context, String url, [String title]) {
    if (PlatformExt.isWindows || PlatformExt.isWeb) {
      print("Win Web 不支持WebView");
      launchUri(url);
      return Future.value();
    }
    return showAdjustableBottomSheet(
      context: context,
      isScrollControlled: false,
      enableDrag: false,
      heightP: 14.0 / 16,
      builder: (c) => Scaffold(
        appBar: AppBar(
          leading: CloseButton(),
          title: Text(title ?? ""),
          actions: [
            IconButton(
              onPressed: () => launchUri(url),
              icon: Icon(Icons.open_in_browser),
            )
          ],
        ),
        body: WebView(
          initialUrl: url,
          javascriptMode: JavascriptMode.unrestricted,
          gestureNavigationEnabled: true,
        ),
      ),
    );
  }

}