import 'package:flutter/material.dart';
import 'package:rickandmorty/constants/styles_constants.dart';
import 'package:rickandmorty/helpers/observable_list_helpers.dart';

/// Author: Carlos López-Jamar
/// Widget: Custom AppBar
/// Version 3.3.4

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final bool? needActions;

  const CustomAppBar({Key? key, required this.title, this.needActions}) : super(key: key);

  @override
  State<CustomAppBar> createState() => CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class CustomAppBarState extends State<CustomAppBar> {
  bool tappedFromAppBar = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
        title: Text(widget.title, style: StaticStyles.mainTitleStyleWhite),
        backgroundColor: StaticStyles.primaryGreen,
        centerTitle: true,
        elevation: 0,
        actions: widget.needActions != null
            ? [
                IconButton(
                  icon: Icon(!tappedFromAppBar ? Icons.menu : Icons.error),
                  onPressed: (() {
                    ObservableAppBarAction.tappedFromAppBar(true);
                  }),
                ),
              ]
            : []);
  }
}
