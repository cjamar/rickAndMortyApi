import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rickandmorty/constants/styles_constants.dart';
import 'package:rickandmorty/helpers/observable_tabbar_helper.dart';
import 'package:rickandmorty/pages/characters_list_page.dart';
import 'package:rickandmorty/pages/episodes_list_page.dart';
import 'package:rickandmorty/pages/locations_list_page.dart';
import 'package:rickandmorty/widgets/tabbar_widget.dart';

/// Author: Carlos López-Jamar
/// Page: HomePage
/// Version 3.3.4
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    tabController = TabController(length: 3, vsync: this);
    tabController.addListener(() {
      if (tabController.indexIsChanging) {
        // Inform pageview is changing
        ObservableTabBarAction.tapBottomNavigation(true);
      }
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StaticStyles.darkBackground,
      bottomNavigationBar: CustomTabBar(controller: tabController),
      body: TabBarView(controller: tabController, children: const [
        CharactersListPage(),
        LocationsListPage(),
        EpisodesListPage(),
      ]),
    );
  }
}
