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

//友好的

String friendlyFormat(int secs) {
  DateTime time = DateTime.fromMillisecondsSinceEpoch(secs * 1000);
  DateTime now = DateTime.now();
  if (time.year == now.year) {
    if (time.month == now.month) {
      if (time.day < now.day) {
        return "${(now.day - time.day)}天前";
      } else if (time.day == now.day) {
        if (time.hour < now.hour) {
          return "${(now.hour - time.hour)}小时前";
        } else if (time.hour == now.hour) {
          if (time.minute < now.minute) {
            return "${(now.minute - time.minute)}分钟前";
          } else {
            return DateFormat("HH:mm").format(time);
          }
        } else {
          return DateFormat("HH:mm").format(time);
        }
      } else {
        return DateFormat("MM-dd").format(time);
      }
    } else {
      return DateFormat("MM-dd").format(time);
    }
  } else {
    return DateFormat("yyyy-MM-dd").format(time);
  }
}
