// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:rickandmorty/constants/styles_constants.dart';

/// Author: Carlos López-Jamar
/// Widget: Custom TabBar
/// Version 3.3.4

// ignore: must_be_immutable
class CustomTabBar extends StatelessWidget {
  TabController controller;
  CustomTabBar({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TabBar(
        controller: controller,
        indicatorSize: TabBarIndicatorSize.label,
        indicatorColor: Colors.transparent,
        labelColor: StaticStyles.primaryGreen,
        unselectedLabelColor: StaticStyles.darkGrey,
        tabs: const [
          Tab(
              icon: Icon(
                Icons.emoji_emotions,
                size: 20,
              ),
              text: 'Characters'),
          Tab(
              icon: Icon(
                Icons.public,
                size: 20,
              ),
              text: 'Locations'),
          Tab(
              icon: Icon(
                Icons.play_circle_fill,
                size: 20,
              ),
              text: 'Episodes'),
        ]);
  }
}
