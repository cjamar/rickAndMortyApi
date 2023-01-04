import 'dart:async';
import 'dart:developer';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rickandmorty/bloc/episode_bloc/episode_bloc.dart';
import 'package:rickandmorty/constants/methods_constants.dart';
import 'package:rickandmorty/constants/styles_constants.dart';
import 'package:rickandmorty/helpers/observable_tabbar_helper.dart';
import 'package:rickandmorty/models/episode_model.dart';
import 'package:rickandmorty/models/error_model.dart';
import 'package:rickandmorty/models/info_model.dart';
import 'package:rickandmorty/pages/episode_page.dart';
import 'package:rickandmorty/requests/get_episode_request.dart';
import 'package:rickandmorty/widgets/appbar_widget.dart';
import 'package:rickandmorty/widgets/errorpage_widget.dart';

/// Author: Carlos López-Jamar
/// Page: EpisodeListPage
/// Version 3.3.4

class EpisodesListPage extends StatefulWidget {
  const EpisodesListPage({super.key});

  @override
  State<EpisodesListPage> createState() => _EpisodesListPageState();
}

class _EpisodesListPageState extends State<EpisodesListPage> with AutomaticKeepAliveClientMixin {
  /// Connectivity Service
  ConnectivityResult connectivityResult = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  List<EpisodeModel> episodesList = [];
  late List<EpisodeModel> matchEpisodes;
  InfoModel infoModel = const InfoModel();
  bool noInternet = false;
  bool error = false;
  String errorMessage = '';
  late int _currentPage;
  final ScrollController _scrollController = ScrollController();
  String filterByNameValue = '';
  Timer? _debounce;
  IconData iconSearchBar = Icons.search;
  Widget textSearchBar = Text('Episodes', style: StaticStyles.mainTitleStyleGreen);
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

  _initialSteps() async {
    await _initConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    _addListenerToBottomNavigationObservable();
    _currentPage = 0;
    matchEpisodes = [];

    _scrollController.addListener(() async {
      if (_scrollController.position.maxScrollExtent == _scrollController.offset) {
        if (_currentPage < infoModel.pages!) {
          await _getEpisodes();
        } else {
          StaticMethods.showSnackBar(context, 'You arrived at the end of the list');
        }
      }
    });

    await _getEpisodes();
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
      if (event && matchEpisodes.isNotEmpty) {
        if (mounted) {
          if (kDebugMode) print('ObservableTabBarAction.streamStatus - $event');
          setState(() {
            _closeSearchBar();
          });
        }
      }
    });
  }

  /// Calling to request to get episodes from api
  Future _getEpisodes() async {
    _currentPage++;
    if (kDebugMode) print('Current page: $_currentPage');

    var resp = await GetEpisodes().getEpisodes(context, page: _currentPage);

    if (resp is RickAndMortyEpisodeModel) {
      infoModel = resp.info!;
    } else if (resp is ErrorModel) {
      if (kDebugMode) print('Error,  $resp');
      error = true;
      errorMessage = 'Error occurred, swipe to refresh or restart the app if the problem persists';
    } else {
      error = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // for AutomaticKeepAliveClientMixin
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Rick & Morty Api'),
      backgroundColor: StaticStyles.darkBackground,
      body: BlocBuilder<EpisodeBloc, EpisodeState>(
        builder: (context, state) {
          if (state is EpisodeLoadingState && (!error && !noInternet)) {
            return Center(
                child: CircularProgressIndicator.adaptive(
                    valueColor: AlwaysStoppedAnimation<Color>(StaticStyles.primaryGreen)));
          } else if (state is EpisodeSuccessfulState && (!error && !noInternet)) {
            matchEpisodes = state.listOfEpisodesState;
            // If we're typing, apply the filterByName
            if (filterByNameValue.isNotEmpty) _filterListName(filterByNameValue);

            return _body(size);
          } else {
            if (kDebugMode) print('Episodes load failed!');
            return RefreshIndicator(
              color: StaticStyles.primaryGreen,
              onRefresh: (() async {
                await _initConnectivity();
                _currentPage = 0;
                _closeSearchBar();
                setState(() {
                  error = false;
                });
                if (infoModel.pages != null && matchEpisodes.isEmpty) {
                  // Call getCharacters again, but fetching page by page until arrives to the total pages
                  _listNotScrollable();
                }
              }),
              child: ErrorPage(errorMessage: errorMessage, iconPage: noInternet ? Icons.signal_wifi_off : null),
            );
          }
        },
      ),
    );
  }

  _body(Size size) {
    return Scrollbar(
      radius: const Radius.circular(8),
      thickness: 7,
      child: RefreshIndicator(
        color: StaticStyles.primaryGreen,
        onRefresh: () async {
          if (_currentPage < infoModel.pages!) await _getEpisodes();
        },
        child: Column(
          children: [
            _searchBar(size),
            Expanded(
                child: matchEpisodes.isEmpty
                    ? Center(child: Text('No episodes found', style: StaticStyles.whitecharacterTitleStyle))
                    : _episodesList(size))
          ],
        ),
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
    textSearchBar = Text('Episodes', style: StaticStyles.mainTitleStyleGreen);
  }

  _episodesList(Size size) {
    return SizedBox(
      width: size.width,
      height: size.height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          matchEpisodes.isEmpty
              ? Center(child: Text('No episodes found', style: StaticStyles.greyTitleStyle))
              : Expanded(
                  child: ListView.builder(
                      controller: _scrollController,
                      itemCount: matchEpisodes.length,
                      itemBuilder: ((context, index) {
                        return _episodeCard(size, matchEpisodes[index], index);
                      })))
        ],
      ),
    );
  }

  _episodeCard(Size size, EpisodeModel episode, int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: (() async {
            await Navigator.push(context, MaterialPageRoute(builder: (context) => EpisodePage(episodeModel: episode)))
                .then((value) {
              setState(() {
                _closeSearchBar();
              });
            });
          }),
          child: Container(
            margin: EdgeInsets.only(top: 6, bottom: index != matchEpisodes.length - 1 ? 6 : 80),
            padding: const EdgeInsets.all(12),
            height: size.height * 0.08,
            width: size.width * 0.96,
            decoration: BoxDecoration(
              color: StaticStyles.darkCard,
              borderRadius: const BorderRadius.all(Radius.circular(6)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [_iconEpisodeCard(size), _detailsEpisodeCard(size, episode)],
            ),
          ),
        ),
      ],
    );
  }

  _iconEpisodeCard(Size size) {
    return SizedBox(
      width: size.width * 0.1,
      child: Icon(Icons.play_circle_fill, color: StaticStyles.grey, size: 30),
    );
  }

  _detailsEpisodeCard(Size size, EpisodeModel episode) {
    return SizedBox(
      width: size.width * 0.75,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: size.width * 0.15,
            child: Text(episode.episode ?? 'No episode num', style: StaticStyles.whitecharacterDescriptionStyle),
          ),
          SizedBox(
            width: size.width * 0.55,
            child: Text(episode.name ?? 'No name',
                style: StaticStyles.characterTitleCardStyle, overflow: TextOverflow.ellipsis, maxLines: 2),
          ),
        ],
      ),
    );
  }

  void _filterListName(String value) {
    filterByNameValue = value;
    List<EpisodeModel> aux = [];

    for (var element in matchEpisodes) {
      if (element.name!.toLowerCase().contains(filterByNameValue.toLowerCase())) {
        aux.add(element);
      }
    }
    matchEpisodes = aux;
    _listNotScrollable();
  }

  /// If the filtered list of characters cant be scrollable (having less items than the screen height size)
  void _listNotScrollable() async {
    try {
      if (matchEpisodes.length < 4 && _currentPage < infoModel.pages!) {
        await _getEpisodes();
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching episodes, $e');
      setState(() {
        error = true;
      });
    }
  }

  @override

  /// To mantain the state of the page every time we comeback - TRUE
  bool get wantKeepAlive => true;
}
