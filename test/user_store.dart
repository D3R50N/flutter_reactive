import 'package:flutter/foundation.dart';
import 'package:flutter_reactive/flutter_reactive.dart';

class UserStore extends ReactiveDependency {
  final name = 'Alice'.rx;

  void updateName(String newName) {
    name.value = newName;
  }

  @override
  void onCreate() {
    debugPrint('UserStore created');
  }

  @override
  void onDispose() {
    debugPrint('UserStore disposed');
  }
}
