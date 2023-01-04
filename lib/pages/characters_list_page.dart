import 'dart:async';
import 'dart:developer';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rickandmorty/bloc/character_bloc/character_bloc.dart';
import 'package:rickandmorty/constants/boxes_constants.dart';
import 'package:rickandmorty/constants/methods_constants.dart';
import 'package:rickandmorty/constants/styles_constants.dart';
import 'package:rickandmorty/helpers/capitalize_string_helper.dart';
import 'package:rickandmorty/helpers/observable_list_helpers.dart';
import 'package:rickandmorty/helpers/observable_tabbar_helper.dart';
import 'package:rickandmorty/models/character_model.dart';
import 'package:rickandmorty/models/error_model.dart';
import 'package:rickandmorty/models/info_model.dart';
import 'package:rickandmorty/pages/character_page.dart';
import 'package:rickandmorty/requests/get_character_request.dart';
import 'package:rickandmorty/widgets/appbar_widget.dart';
import 'package:rickandmorty/widgets/errorpage_widget.dart';

/// Author: Carlos López-Jamar
/// Page: CharacterListPage
/// Version 3.3.4

class CharactersListPage extends StatefulWidget {
  const CharactersListPage({super.key});

  @override
  State<CharactersListPage> createState() => _CharactersListPageState();
}

class _CharactersListPageState extends State<CharactersListPage> with AutomaticKeepAliveClientMixin {
  /// Connectivity Service
  ConnectivityResult connectivityResult = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  final ScrollController _scrollController = ScrollController();
  late int _currentPage;
  late List<CharacterModel> charactersInBloc;
  late List<CharacterModel> matchCharacters;
  late CharacterBloc characterBloc;
  Map<String, bool> modalGenderMap = {};
  Map<String, bool> modalStatusMap = {};
  List<bool> boleanGender = [];
  List<bool> boleanStatus = [];
  InfoModel infoModel = const InfoModel();
  final TextEditingController _textFieldController = TextEditingController();

  bool noInternet = false;
  bool error = false;
  String errorMessage = '';
  bool enabledModalButton = true;
  bool filterButtonClicked = false;
  IconData iconSearchBar = Icons.search;
  Widget textSearchBar = Text('Characters', style: StaticStyles.mainTitleStyleGreen);
  String _filterByNameValue = '';
  Timer? _debounce;
  bool _showBackToTopButton = false;

  @override
  void initState() {
    _initialSteps().then((_) => WidgetsBinding.instance.addPostFrameCallback((_) {
          _loadModalGender();
          _loadModalStatus();
          _filterListGender();
          _filterListStatus();
          setState(() {});
        }));
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

  Future _initialSteps() async {
    await _initConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    _addListenerToBottomNavigationObservable();
    _addListenerToAppBarObservable();
    charactersInBloc = [];
    matchCharacters = [];
    _currentPage = 0;
    _scrollController.addListener(() async {
      if (_scrollController.position.maxScrollExtent == (_scrollController.offset)) {
        // If when scroll to fetch the next page and the current page is the same or superior to total pages,
        // show an snackbar to inform you arrive at the final of the list (filtered or not).
        if (_currentPage < infoModel.pages!) {
          if (kDebugMode) print('Loading more characters...');
          await _getCharacters();
        } else {
          StaticMethods.showSnackBar(context, 'You arrived at the end of the list');
        }
      }
      setState(() {});
      // For show to top button
      if (_scrollController.offset >= 400) {
        _showBackToTopButton = true;
      } else {
        _showBackToTopButton = false;
      }
    });
    await _getCharacters();
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
      if (event && matchCharacters.isNotEmpty) {
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
  Future _getCharacters() async {
    if (kDebugMode) print('Current page: $_currentPage');
    _currentPage++;

    var resp = await GetCharacters().getCharacters(context, page: _currentPage);

    if (resp is RickAndMortyCharacterModel) {
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
    // Adding listener for modal opening from AppBar iconButton

    /// BlocBuilder handles 2 states: loading (shows a progressIndicator) & successful (shows the list of characters).
    /// if theese two doesn't appear it will show a center error text
    return Scaffold(
        backgroundColor: StaticStyles.darkBackground,
        appBar: const CustomAppBar(title: 'Rick & Morty Api', needActions: true),
        body: BlocBuilder<CharacterBloc, CharacterState>(builder: (context, state) {
          if (state is CharacterLoadingState && !error && !noInternet) {
            if (kDebugMode) print('Bloc State ----> Character Loading state');
            return Center(
                child: CircularProgressIndicator.adaptive(
                    valueColor: AlwaysStoppedAnimation<Color>(StaticStyles.primaryGreen)));
          } else if (state is CharacterSuccessfulState && !error && !noInternet) {
            if (kDebugMode) print('Bloc State ----> Character Successful state');
            charactersInBloc = state.listOfCharactersState;
            matchCharacters = state.listOfCharactersState;
            _filterListGender();
            _filterListStatus();
            // If we're typing, apply the filterByName
            if (_filterByNameValue.isNotEmpty) _filterListName(_filterByNameValue);

            return _homeBody(size);
          } else {
            if (kDebugMode) print('Characters load failed!');
            return RefreshIndicator(
              color: StaticStyles.primaryGreen,
              onRefresh: () async {
                await _initConnectivity();
                _currentPage = 0;
                _loadModalGender();
                _loadModalStatus();
                _filterListGender();
                _filterListStatus();
                _closeSearchBar();
                setState(() {
                  error = false;
                });
                if (infoModel.pages != null && matchCharacters.isEmpty) {
                  // Call getCharacters again, but fetching page by page until arrives to the total pages
                  _listNotScrollable();
                }
              },
              child: ErrorPage(
                errorMessage: errorMessage,
                iconPage: noInternet ? Icons.signal_wifi_off : null,
              ),
            );
          }
        }),
        floatingActionButton: _showBackToTopButton && !error && !noInternet
            ? FloatingActionButton(
                backgroundColor: StaticStyles.darkSnackbar,
                onPressed: _scrollToTop,
                child: Icon(Icons.arrow_upward, color: StaticStyles.primaryGreen),
              )
            : null);
  }

  /// Entire page except the appbar (Body)
  _homeBody(Size size) {
    return Container(
      color: StaticStyles.darkBackground,
      child: Column(
        children: [
          _searchBar(size),
          Expanded(
            child: matchCharacters.isEmpty
                ? Center(child: Text('No characters found', style: StaticStyles.whitecharacterTitleStyle))
                : _charactersList(size),
          ),
        ],
      ),
    );
  }

  /// Listview of Characters with scrollBar & refreshIndicator
  _charactersList(Size size) {
    return Scrollbar(
      radius: const Radius.circular(8),
      thickness: 7,
      child: RefreshIndicator(
        color: StaticStyles.primaryGreen,
        onRefresh: () async {
          if (_currentPage < infoModel.pages!) await _getCharacters();
        },
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: matchCharacters.length,
                shrinkWrap: true,
                physics: const AlwaysScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  // If the list is completely showed it will show at the end a loader as a infinite scroll indicator
                  return matchCharacters.isEmpty ? _noCharactersFound() : _characterCard(size, matchCharacters[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  _noCharactersFound() {
    return Column(
      children: [
        Center(child: Text('No characters found', style: StaticStyles.whitecharacterTitleStyle)),
        IconButton(
            onPressed: () async {
              await _getCharacters();
            },
            icon: Icon(Icons.refresh, color: StaticStyles.primaryGreen)),
      ],
    );
  }

  /// Character card widget
  _characterCard(Size size, CharacterModel characterModel) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
                context, MaterialPageRoute(builder: ((context) => CharacterPage(characterModel: characterModel))))
            .then((value) {
          /// This function is commented to avoid scroll to top & reset the filter because is an unconfortable experience
          // setState(() {
          //   _closeSearchBar();
          // });
        });
      },
      child: Container(
        width: size.height * 0.2,
        decoration: BoxDecoration(
          color: StaticStyles.darkCard,
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        child: Row(
          children: [
            _characterImageList(size, characterModel),
            _characterDetailsList(size, characterModel),
          ],
        ),
      ),
    );
  }

  /// Character image card
  Widget _characterImageList(Size size, CharacterModel characterModel) {
    return Container(
        margin: const EdgeInsets.only(right: 16),
        width: size.width * 0.35,
        height: size.width * 0.35,
        child: ClipRRect(
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(8)),
            child: _nullCheckCharacterImage(characterModel)));
  }

  /// Error control character image
  Widget _nullCheckCharacterImage(CharacterModel characterModel) {
    return characterModel.image != null && characterModel.image!.isNotEmpty
        ? _characterImageContainer(characterModel)
        : Container(color: StaticStyles.grey, child: Text('No image', style: StaticStyles.whitecharacterDataStyle));
  }

  /// Character Image error control
  Widget _characterImageContainer(CharacterModel characterModel) {
    return characterModel.image != null || characterModel.image!.isEmpty
        ? FadeInImage.assetNetwork(
            placeholderErrorBuilder: (context, error, stackTrace) {
              if (kDebugMode) print('Error character image placeholder, returning alternative placeholder');
              return Image(image: AssetImage(StaticStyles.placeholderImage));
            },
            placeholder: StaticStyles.placeholderImage,
            imageErrorBuilder: (context, error, stackTrace) {
              if (kDebugMode) print('Error character image, returning alternative image');
              return Image(image: AssetImage(StaticStyles.placeholderImage));
            },
            image: characterModel.image!)
        : Container(color: StaticStyles.grey);
  }

  /// Character text card
  Widget _characterDetailsList(Size size, CharacterModel characterModel) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      width: size.width * 0.5,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _characterTitleList(size, characterModel),
          Column(
            children: [
              _characterStatus(characterModel),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _characterGender(characterModel),
                  _characterLocation(size, characterModel),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }

  /// Location text card
  Widget _characterLocation(Size size, CharacterModel characterModel) {
    return SizedBox(
        width: size.width * 0.5,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Location: ',
                style: StaticStyles.whitecharacterDescriptionStyle, maxLines: 1, overflow: TextOverflow.ellipsis),
            Expanded(
              child: Text(characterModel.location!.name ?? 'No location',
                  style: StaticStyles.whitecharacterDataStyle, maxLines: 2, overflow: TextOverflow.ellipsis),
            ),
          ],
        ));
  }

  /// Gender text card
  Widget _characterGender(CharacterModel characterModel) {
    return Row(
      children: [
        SizedBox(child: Text('Gender: ', style: StaticStyles.whitecharacterDescriptionStyle)),
        SizedBox(child: Text(characterModel.gender ?? 'No gender', style: StaticStyles.whitecharacterDataStyle)),
      ],
    );
  }

  /// Status text card
  Widget _characterStatus(CharacterModel characterModel) {
    return Row(
      children: [
        SizedBox(child: Text('Status: ', style: StaticStyles.whitecharacterDescriptionStyle)),
        SizedBox(child: Text(characterModel.status ?? 'No status', style: StaticStyles.whitecharacterDataStyle)),
      ],
    );
  }

  /// Title character card
  Widget _characterTitleList(Size size, CharacterModel characterModel) {
    return Container(
      margin: const EdgeInsets.only(bottom: 0),
      height: size.width * 0.1,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(right: 8, top: 4),
            width: size.width * 0.025,
            height: size.width * 0.025,
            decoration: BoxDecoration(
                color: characterModel.status == 'Alive'
                    ? StaticStyles.primaryGreen
                    : characterModel.status == 'Dead'
                        ? StaticStyles.red
                        : StaticStyles.amber,
                shape: BoxShape.circle),
          ),
          SizedBox(
              width: size.width * 0.45,
              child: Text(characterModel.name ?? 'No name',
                  style: StaticStyles.characterTitleCardStyle, overflow: TextOverflow.ellipsis, maxLines: 2)),
        ],
      ),
    );
  }

  /// Adding listener
  void _addListenerToAppBarObservable() {
    ObservableAppBarAction.streamStatus.listen((event) async {
      if (event && !noInternet && !error) {
        if (mounted) {
          if (kDebugMode) print('ObservableAppBarAction.streamStatus - $event');

          boleanGender = modalGenderMap.values.toList();
          boleanStatus = modalStatusMap.values.toList();

          await _showModal();
        }
      } else {
        StaticMethods.showSnackBar(context, 'Error occurred. Please, refresh the page');
      }
    });
  }

  /// Calling to modalBottomSheet with filter by Gender & filter by Status
  Future _showModal() async {
    final size = MediaQuery.of(context).size;

    return await showModalBottomSheet(
        backgroundColor: StaticStyles.darkSnackbar,
        context: context,
        builder: ((_) {
          return StatefulBuilder(
            builder: (_, setter) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                            margin: const EdgeInsets.only(left: 10),
                            child: TextButton(
                              onPressed: () {
                                if (kDebugMode) print('Clearing filters');
                                if (_modalValueFalseControl()) {
                                  setState(() {
                                    _loadModalGender();
                                    _loadModalStatus();
                                    _filterListGender();
                                    _filterListStatus();
                                  });
                                  Navigator.pop(context);
                                  _scrollToTop();
                                }
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 15),
                                backgroundColor: _modalValueFalseControl() ? StaticStyles.almostBlack : null,
                              ),
                              child: Row(
                                children: [
                                  Text('CLEAR',
                                      style: StaticStyles.buttonStyle.copyWith(
                                          color: _modalValueFalseControl()
                                              ? StaticStyles.primaryGreen
                                              : StaticStyles.darkestGrey)),
                                  const SizedBox(width: 5),
                                  Icon(Icons.cancel,
                                      color: _modalValueFalseControl()
                                          ? StaticStyles.primaryGreen
                                          : StaticStyles.darkestGrey,
                                      size: 18)
                                ],
                              ),
                            )),
                        Text('FILTER CHARACTERS', style: StaticStyles.whitecharacterDescriptionStyle),
                        Container(
                            margin: const EdgeInsets.only(right: 15),
                            child: IconButton(
                                onPressed: (() => Navigator.pop(context)),
                                icon: Icon(
                                  Icons.close,
                                  color: StaticStyles.darkGrey,
                                ))),
                      ],
                    ),
                    ListView.builder(
                      itemCount: modalGenderMap.entries.toList().length,
                      shrinkWrap: true,
                      itemBuilder: (_, int index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          height: size.height * 0.06,
                          decoration: BoxDecoration(
                              color: StaticStyles.almostBlack,
                              borderRadius: const BorderRadius.all(Radius.circular(10))),
                          child: SwitchListTile(
                              controlAffinity: ListTileControlAffinity.platform,
                              secondary: Text('GENDER', style: StaticStyles.whitecharacterDescriptionStyle),
                              title: Text(modalGenderMap.keys.toList()[index],
                                  style: StaticStyles.whiteCharacterModalDataStyle),
                              value: boleanGender[index],
                              activeColor: StaticStyles.primaryGreen,
                              activeTrackColor: StaticStyles.slightlyDarkGreen,
                              inactiveTrackColor: Colors.black,
                              inactiveThumbColor: StaticStyles.darkGrey,
                              onChanged: ((value) {
                                setter(() {
                                  boleanGender[index] = !boleanGender[index];
                                });
                                enabledModalButton = _modalValueTrueControl();
                              })),
                        );
                      },
                    ),
                    ListView.builder(
                      itemCount: modalStatusMap.entries.toList().length,
                      shrinkWrap: true,
                      itemBuilder: (_, int index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          height: size.height * 0.06,
                          decoration: BoxDecoration(
                              color: StaticStyles.almostBlack,
                              borderRadius: const BorderRadius.all(Radius.circular(10))),
                          child: SwitchListTile(
                              controlAffinity: ListTileControlAffinity.platform,
                              secondary: Text('STATUS', style: StaticStyles.whitecharacterDescriptionStyle),
                              title: Text(modalStatusMap.keys.toList()[index],
                                  style: StaticStyles.whiteCharacterModalDataStyle),
                              value: boleanStatus[index],
                              activeColor: StaticStyles.primaryGreen,
                              activeTrackColor: StaticStyles.slightlyDarkGreen,
                              inactiveTrackColor: Colors.black,
                              inactiveThumbColor: StaticStyles.darkGrey,
                              onChanged: ((value) {
                                setter(() {
                                  boleanStatus[index] = !boleanStatus[index];
                                });
                                enabledModalButton = _modalValueTrueControl();
                              })),
                        );
                      },
                    ),
                    Container(
                        width: MediaQuery.of(context).size.width * 0.95,
                        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        child: TextButton(
                          onPressed: () {
                            if (enabledModalButton) {
                              _scrollToTop();
                              _updateModalMapsWithBoolList();
                              setState(() {});
                              Navigator.pop(context);
                            } else {
                              null;
                            }
                          },
                          style: TextButton.styleFrom(
                              backgroundColor:
                                  enabledModalButton ? StaticStyles.primaryGreen : StaticStyles.darkestGrey),
                          child: Text('FILTER', style: StaticStyles.buttonStyle),
                        ))
                  ],
                ),
              );
            },
          );
        }));
  }

  /// After build the list, load the modalMap with every option of gender property and set initially to true
  void _loadModalGender() {
    String genderCapitalized = '';
    for (var element in charactersInBloc) {
      if (element.gender != null) genderCapitalized = Capitalize().string(element.gender!);
      modalGenderMap.addAll({genderCapitalized: true});
    }
    boleanGender = List.generate(modalGenderMap.entries.length, (index) => true);
  }

  /// After build the list, load the modalMap with every option of status property and set initially to true
  void _loadModalStatus() {
    String statusCapitalized = '';
    for (var element in charactersInBloc) {
      if (element.status != null) statusCapitalized = Capitalize().string(element.status!);
      modalStatusMap.addAll({statusCapitalized: true});
    }
    boleanStatus = List.generate(modalStatusMap.entries.length, (index) => true);
  }

  /// Filtering the list by each property of gender
  _filterListGender() {
    List<CharacterModel> aux = [];
    for (var element in charactersInBloc) {
      modalGenderMap.forEach((key, value) {
        if (value == true && element.gender!.toLowerCase() == key.toLowerCase()) {
          aux.add(element);
        }
      });
    }
    matchCharacters = aux;
    _listNotScrollable();
  }

  /// Filtering the list by each property of status
  _filterListStatus() {
    List<CharacterModel> aux = [];
    for (var element in matchCharacters) {
      modalStatusMap.forEach((key, value) {
        if (value == true && element.status!.toLowerCase() == key.toLowerCase()) {
          aux.add(element);
        }
      });
    }
    matchCharacters = aux;
    _listNotScrollable();
  }

  /// If the filtered list of characters cant be scrollable (having less items than the screen height size)
  void _listNotScrollable() async {
    try {
      if (matchCharacters.length < 4 && _currentPage < infoModel.pages!) {
        await _getCharacters();
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching characters, $e');
      setState(() {
        error = true;
      });
    }
  }

  /// Control if almost one of each switch group has value on true (to active the filter button)
  bool _modalValueTrueControl() {
    return boleanGender.contains(true) && boleanStatus.contains(true);
  }

  /// Control if almost one switch has value on false (to active the clear button)
  bool _modalValueFalseControl() {
    return boleanGender.contains(false) || boleanStatus.contains(false);
  }

  void _updateModalMapsWithBoolList() {
    Map<String, bool> auxGender = {};
    Map<String, bool> auxStatus = {};
    int indexGender = 0;
    int indexStatus = 0;

    for (var element in boleanGender) {
      modalGenderMap.forEach((key, value) {
        if (!auxGender.containsKey(key) && indexGender == auxGender.entries.length) {
          auxGender.addAll({key: element});
        }
      });
      modalGenderMap.addAll(auxGender);
      indexGender++;
    }

    for (var element in boleanStatus) {
      modalStatusMap.forEach((key, value) {
        if (!auxStatus.containsKey(key) && indexStatus == auxStatus.entries.length) {
          auxStatus.addAll({key: element});
        }
      });
      modalStatusMap.addAll(auxStatus);
      indexStatus++;
    }
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
                _scrollToTop();
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
    _scrollToTop();
    _textFieldController.clear();
    _filterListName('');
    iconSearchBar = Icons.search;
    textSearchBar = Text('Characters', style: StaticStyles.mainTitleStyleGreen);
  }

  /// Filter by name with in the searchBar
  /// with gender & status filter activated
  void _filterListName(String value) {
    _filterByNameValue = value;
    List<CharacterModel> aux = [];

    for (var element in matchCharacters) {
      if (element.name!.toLowerCase().contains(_filterByNameValue.toLowerCase())) {
        aux.add(element);
      }
    }

    matchCharacters = aux;
    _listNotScrollable();
  }

  /// Automatic scrolling to the top of the list
  _scrollToTop() {
    _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.linear);
  }

  @override

  /// To mantain the state of the page every time we comeback - TRUE
  bool get wantKeepAlive => true;
}
