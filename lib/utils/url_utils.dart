import 'package:url_launcher/url_launcher.dart';

Future launchUri(String uri) async {
  if (await canLaunch(uri)) {
    launch(uri);
  } else {
    throw "canot open $uri";
  }
}
