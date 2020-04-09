import 'package:flutter_test/flutter_test.dart';

main() {
  Future.delayed(Duration(seconds: 1), () {
    return 1;
  }).then((v) {
    print(v);
  }).catchError((e) {
    print(e);
  });
}
