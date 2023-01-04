import 'dart:async';

/// Author: Carlos López-Jamar
/// Helper: ObservableTabBarAction
/// Version 3.3.4

class ObservableTabBarAction {
  static final StreamController<bool> streamController = StreamController.broadcast();
  static Stream<bool> get streamStatus => streamController.stream;

  static closeStreams() {
    streamController.close();
  }

  static tapBottomNavigation(bool tapBottomNavigation) {
    streamController.add(tapBottomNavigation);
  }
}
