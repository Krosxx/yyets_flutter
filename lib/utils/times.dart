import 'package:intl/intl.dart';

///
///
///
String formatSeconds(int secs) {
  DateTime now = DateTime.now();
  DateTime time = DateTime.fromMillisecondsSinceEpoch(secs * 1000);
  if (time.year == now.year) {
    return DateFormat("MM-dd HH:mm").format(time);
  } else {
    return DateFormat("yyyy-MM-dd").format(time);
  }
}

String formatLength(int millisSecs) {
  DateTime time = DateTime(0, 0, 0, 0, 0, 0, millisSecs, 0);
  if (time.hour > 0) {
    return DateFormat("HH:mm:ss").format(time);
  } else {
    return DateFormat("mm:ss").format(time);
  }
}
