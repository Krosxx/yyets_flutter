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
  var time = DateTime.fromMillisecondsSinceEpoch(secs * 1000);

  var now = DateTime.now();
  DateTime d = DateTime.fromMillisecondsSinceEpoch(
      now.millisecondsSinceEpoch - secs * 1000);
  var dd = d.day - 1;
  var dm = d.month - 1;
  var dy = d.year - 1970;

  if (dy == 0) {
    if (dm == 0) {
      if (dd > 0 && dd < 10) {
        return "${dd}天前";
      } else if (dd == 0) {
        if (d.hour > 0) {
          return "${d.hour}小时前";
        } else if (d.hour == 0) {
          if (d.minute > 0) {
            return "${d.minute}分钟前";
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
