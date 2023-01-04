import 'dart:async';
import 'dart:developer';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rickandmorty/bloc/location_bloc/location_bloc.dart';
import 'package:rickandmorty/constants/methods_constants.dart';
import 'package:rickandmorty/constants/styles_constants.dart';
import 'package:rickandmorty/helpers/observable_tabbar_helper.dart';
import 'package:rickandmorty/models/error_model.dart';
import 'package:rickandmorty/models/info_model.dart';
import 'package:rickandmorty/models/location_model.dart';
import 'package:rickandmorty/pages/location_page.dart';
import 'package:rickandmorty/requests/get_location_request.dart';
import 'package:rickandmorty/widgets/appbar_widget.dart';
import 'package:rickandmorty/widgets/errorpage_widget.dart';

/// Author: Carlos López-Jamar
/// Page: LocationsListPage
/// Version 3.3.4

class LocationsListPage extends StatefulWidget {
  const LocationsListPage({super.key});

  @override
  State<LocationsListPage> createState() => _LocationsListPageState();
}

class _LocationsListPageState extends State<LocationsListPage> with AutomaticKeepAliveClientMixin {
  /// Connectivity Service
  ConnectivityResult connectivityResult = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  final ScrollController _scrollController = ScrollController();
  bool noInternet = false;
  bool error = false;
  String errorMessage = '';
  late int _currentPage;
  late List<LocationModel> locationsList;
  late List<LocationModel> matchLocations;
  InfoModel infoModel = const InfoModel();
  String filterByNameValue = '';
  Timer? _debounce;
  IconData iconSearchBar = Icons.search;
  Widget textSearchBar = Text('Locations', style: StaticStyles.mainTitleStyleGreen);
  final TextEditingController _textFieldController = TextEditingController();

  @override
  void initState() {
    _initialSteps();
    super.initState();
  }

  @override
  void dispose() {
    // Close the Connectivity Service
    _connectivitySubscription.cancel();
    _scrollController.dispose();
    _textFieldController.dispose();
    super.dispose();
  }

  void _initialSteps() async {
    await _initConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    _addListenerToBottomNavigationObservable();
    _currentPage = 0;
    matchLocations = [];

    _scrollController.addListener(() async {
      if (_scrollController.position.maxScrollExtent == (_scrollController.offset)) {
        if (_currentPage < infoModel.pages!) {
          if (kDebugMode) print('Loading more locations...');
          await _getLocations();
        } else {
          StaticMethods.showSnackBar(context, 'You arrived at the end of the list');
        }
      }
    });

    await _getLocations();
  }

  /// Init connectivity
  Future<void> _initConnectivity() async {
    late ConnectivityResult result;
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      log('Couldnt check connectivity status', error: e);
      noInternet = true;
      errorMessage = 'No signal. Please check connectivity or restart the app if the problem persists';
      return;
    }
    if (!mounted) {
      return Future.value(null);
    }
    return _updateConnectionStatus(result);
  }

  /// Update connection
  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    if (result != ConnectivityResult.wifi && result != ConnectivityResult.mobile) {
      errorMessage = 'No signal. Please check connectivity or restart the app if the problem persists';
      noInternet = true;
    } else {
      noInternet = false;
    }
    setState(() {
      connectivityResult = result;
    });
  }

  /// Adding listener
  _addListenerToBottomNavigationObservable() {
    ObservableTabBarAction.streamStatus.listen((event) async {
      if (event && matchLocations.isNotEmpty) {
        if (mounted) {
          if (kDebugMode) print('ObservableTabBarAction.streamStatus - $event');
          setState(() {
            _closeSearchBar();
          });
        }
      }
    });
  }

  /// Calling to request tha call to the api
  Future _getLocations() async {
    _currentPage++;
    if (kDebugMode) print('Current page: $_currentPage');

    var resp = await GetLocations().getLocations(context, page: _currentPage);

    if (resp is RickAndMortyLocationModel) {
      infoModel = resp.info!;
    } else if (resp is ErrorModel) {
      if (kDebugMode) print('Error,  $resp');
      errorMessage = 'Error occurred, swipe to refresh or restart the app if the problem persists';
      setState(() {
        error = true;
      });
    } else {
      setState(() {
        error = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // for AutomaticKeepAliveClientMixin
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Rick & Morty Api'),
      backgroundColor: StaticStyles.darkBackground,
      body: Center(child: BlocBuilder<LocationBloc, LocationState>(builder: ((context, state) {
        if (state is LocationLoadingState && (!error && !noInternet)) {
          return Center(
              child: CircularProgressIndicator.adaptive(
                  valueColor: AlwaysStoppedAnimation<Color>(StaticStyles.primaryGreen)));
        } else if (state is LocationSuccessfulstate && (!error && !noInternet)) {
          matchLocations = state.listOfLocationsState;
          // If we're typing, apply the filterByName
          if (filterByNameValue.isNotEmpty) _filterListName(filterByNameValue);
          return _body(size);
        } else {
          if (kDebugMode) print('Locations load failed!');
          return RefreshIndicator(
              color: StaticStyles.primaryGreen,
              onRefresh: () async {
                await _initConnectivity();
                _currentPage = 0;
                _closeSearchBar();
                setState(() {
                  error = false;
                });
                if (infoModel.pages != null && matchLocations.isEmpty) {
                  // Call getCharacters again, but fetching page by page until arrives to the total pages
                  _listNotScrollable();
                }
              },
              child: ErrorPage(
                errorMessage: errorMessage,
                iconPage: noInternet ? Icons.signal_wifi_off : null,
              ));
        }
      }))),
    );
  }

  _body(Size size) {
    return SizedBox(
      width: size.width,
      child: Column(
        children: [
          _searchBar(size),
          Expanded(
              child: matchLocations.isEmpty
                  ? Center(child: Text('No locations found', style: StaticStyles.whitecharacterTitleStyle))
                  : _locationsList(size))
        ],
      ),
    );
  }

  /// SearchBar with title
  SizedBox _searchBar(Size size) {
    return SizedBox(
      width: size.width * 0.95,
      height: size.height * 0.07,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          textSearchBar,
          IconButton(
              icon: Icon(
                iconSearchBar,
                color: StaticStyles.primaryGreen,
                size: 26,
              ),
              onPressed: () {
                setState(() {
                  if (iconSearchBar == Icons.search) {
                    iconSearchBar = Icons.close;
                    textSearchBar = SizedBox(
                      width: size.width * 0.7,
                      child: TextField(
                        controller: _textFieldController,
                        onChanged: (value) {
                          if (_debounce?.isActive ?? false) _debounce!.cancel();
                          _debounce = Timer(const Duration(seconds: 1), () {
                            setState(() {
                              _filterListName(value);
                            });
                          });
                        },
                        autofocus: true,
                        decoration: InputDecoration(
                            hintText: 'Searching..',
                            hintStyle: StaticStyles.searchBarHintStyle,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                            border: InputBorder.none),
                        style: StaticStyles.searchBarLabelStyle,
                        cursorColor: StaticStyles.primaryGreen,
                      ),
                    );
                  } else {
                    _closeSearchBar();
                  }
                });
              })
        ],
      ),
    );
  }

  _closeSearchBar() {
    _textFieldController.clear();
    _filterListName('');
    iconSearchBar = Icons.search;
    textSearchBar = Text('Locations', style: StaticStyles.mainTitleStyleGreen);
  }

  _locationsList(Size size) {
    return Scrollbar(
      radius: const Radius.circular(8),
      thickness: 7,
      child: RefreshIndicator(
        color: StaticStyles.primaryGreen,
        onRefresh: () async {
          if (_currentPage < infoModel.pages!) await _getLocations();
        },
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                  controller: _scrollController,
                  itemCount: matchLocations.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, mainAxisSpacing: 16, childAspectRatio: 1.2),
                  itemBuilder: ((context, index) {
                    return matchLocations.isEmpty
                        ? Text('No locations found', style: StaticStyles.greyTitleStyle)
                        : _locationCard(size, matchLocations[index]);
                  })),
            ),
          ],
        ),
      ),
    );
  }

  _locationCard(Size size, LocationModel locationModel) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
            context, MaterialPageRoute(builder: (context) => LocationPage(locationModel: locationModel))).then((value) {
          setState(() {
            _closeSearchBar();
          });
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
            color: StaticStyles.darkCard,
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            border: Border.all(color: StaticStyles.darkestGrey)),
        child: Column(
          children: [_locationTitle(size, locationModel), _locationData(size, locationModel)],
        ),
      ),
    );
  }

  _locationTitle(Size size, LocationModel locationModel) {
    return Container(
      decoration:
          BoxDecoration(color: StaticStyles.dark, borderRadius: const BorderRadius.vertical(top: Radius.circular(8))),
      width: size.width,
      height: size.height * 0.07,
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Text(locationModel.name!,
            style: StaticStyles.characterTitleCardStyle, overflow: TextOverflow.ellipsis, maxLines: 2),
      ),
    );
  }

  _locationData(Size size, LocationModel locationModel) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: SizedBox(
        width: size.width,
        height: size.height * 0.1,
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Type: ', style: StaticStyles.whitecharacterDescriptionStyle),
                Flexible(child: Text(locationModel.type ?? 'No type', style: StaticStyles.whitecharacterDataStyle))
              ],
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Dimension: ', style: StaticStyles.whitecharacterDescriptionStyle),
                Flexible(
                    child: Text(locationModel.dimension ?? 'No dimension',
                        style: StaticStyles.whitecharacterDataStyle, overflow: TextOverflow.ellipsis, maxLines: 3))
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _filterListName(String value) {
    filterByNameValue = value;
    List<LocationModel> aux = [];

    for (var element in matchLocations) {
      if (element.name!.toLowerCase().contains(filterByNameValue.toLowerCase())) {
        aux.add(element);
      }
    }
    matchLocations = aux;
    _listNotScrollable();
  }

  /// If the filtered list of characters cant be scrollable (having less items than the screen height size)
  void _listNotScrollable() async {
    try {
      if (matchLocations.length < 4 && _currentPage < infoModel.pages!) {
        await _getLocations();
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching locations, $e');
      setState(() {
        error = true;
      });
    }
  }

  @override

  /// To mantain the state of the page every time we comeback - TRUE
  bool get wantKeepAlive => true;
}
