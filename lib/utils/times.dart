
import 'package:intl/intl.dart';

///
///
///
String formatSeconds(int secs) {
  DateTime now = DateTime.now();
  DateTime time = DateTime.fromMillisecondsSinceEpoch(secs * 1000);
  if(time.year==now.year) {
    return DateFormat("MM-dd HH:mm").format(time);
  }else{
    return DateFormat("yyyy-MM-dd").format(time);
  }
}
