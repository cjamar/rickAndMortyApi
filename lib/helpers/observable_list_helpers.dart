import 'dart:async';

/// Author: Carlos López-Jamar
/// Helper: ObservableAppBarAction
/// Version 3.3.4

class ObservableAppBarAction {
  static final StreamController<bool> streamController = StreamController.broadcast();
  static Stream<bool> get streamStatus => streamController.stream;

  static closeStreams() {
    streamController.close();
  }

  static tappedFromAppBar(bool tappedFromAppBar) {
    streamController.add(tappedFromAppBar);
  }
}
