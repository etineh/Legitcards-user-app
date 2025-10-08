import 'package:flutter_web_plugins/flutter_web_plugins.dart';

void configurePlatform() {
  // print("i am ion web");
  setUrlStrategy(PathUrlStrategy());
  // setUrlStrategy(HashUrlStrategy());
}
