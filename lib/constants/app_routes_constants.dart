import 'package:flutter/material.dart';
import 'package:rickandmorty/pages/home_page.dart';

/// Author: Carlos López-Jamar
/// Static: App Routes
/// Version 3.3.4

class AppRoutes {
  static String initialRoute = 'home';

  static Map<String, Widget Function(BuildContext)> getAppRoutes() {
    Map<String, WidgetBuilder> routes = {
      'home': (context) => const HomePage(),
    };
    return routes;
  }
}
