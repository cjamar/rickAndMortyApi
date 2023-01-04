import 'dart:async';
import 'dart:developer';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:rickandmorty/bloc/actor_bloc/actor_bloc.dart';
import 'package:rickandmorty/constants/methods_constants.dart';
import 'package:rickandmorty/constants/styles_constants.dart';
import 'package:rickandmorty/models/character_model.dart';
import 'package:rickandmorty/models/episode_model.dart';
import 'package:rickandmorty/models/error_model.dart';
import 'package:rickandmorty/pages/character_page.dart';
import 'package:rickandmorty/requests/get_characterById_request.dart';
import 'package:rickandmorty/widgets/appbar_widget.dart';
import 'package:rickandmorty/widgets/errorpage_widget.dart';

/// Author: Carlos López-Jamar
/// Page: EpisodePage
/// Version 3.3.4

class EpisodePage extends StatefulWidget {
  final EpisodeModel episodeModel;
  const EpisodePage({super.key, required this.episodeModel});

  @override
  State<EpisodePage> createState() => _EpisodePageState();
}

class _EpisodePageState extends State<EpisodePage> {
  /// Connectivity Service
  ConnectivityResult connectivityResult = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  late List<CharacterModel> listOfActors;
  bool callingActors = false;
  bool noInternet = false;
  bool error = false;
  String errorMessage = '';

  @override
  void initState() {
    _initialSteps();
    super.initState();
  }

  @override
  void dispose() {
    // Close the Connectivity Service
    _connectivitySubscription.cancel();
    super.dispose();
  }

  _initialSteps() async {
    await _initConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    await _getActorsById();
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

  /// Calling to request for every character in current location and add to bloc
  Future<void> _getActorsById() async {
    setState(() {
      callingActors = true;
    });

    ActorBloc actorBloc = BlocProvider.of<ActorBloc>(context);
    List<CharacterModel> listOfActors = [];

    // Waiting for complete the residents loop and add every resident into the list and then return it
    await Future.wait(widget.episodeModel.characters!.map((actor) async {
      var resp = await GetCharacterById().getCharacterById(context, actor);

      if (resp is CharacterModel) {
        if (!listOfActors.contains(resp)) listOfActors.add(resp);
        actorBloc.add(AddActorsList(listOfActors));
      } else if (resp is ErrorModel) {
        if (kDebugMode) print('Error,  $resp');
        error = true;
        errorMessage = 'Error occurred, swipe to refresh or restart the app if the problem persists';
      } else {
        error = false;
      }
    }).toList());

    if (listOfActors.isEmpty) {
      // If some of the locations are empty of residents, clear the bloc to show the current list. If not, it will load with new residents
      actorBloc.add(const AddActorsList([]));
    }

    setState(() {
      callingActors = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async {
        return error || noInternet
            ? await StaticMethods.showSnackBar(context, 'Error occurred. Please, refresh the page')
            : true;
      },
      child: Scaffold(
        appBar: CustomAppBar(title: widget.episodeModel.name ?? 'No name'),
        backgroundColor: StaticStyles.darkBackground,
        body: BlocBuilder<ActorBloc, ActorState>(
          builder: (context, state) {
            if ((state is ActorLoadingState || callingActors) && (!error && !noInternet)) {
              return Center(
                  child: CircularProgressIndicator.adaptive(
                      valueColor: AlwaysStoppedAnimation<Color>(StaticStyles.primaryGreen)));
            } else if (state is ActorSuccessfulState && (!error && !noInternet)) {
              return _body(size);
            } else {
              if (kDebugMode) print('Actors load failed!');
              return RefreshIndicator(
                  color: StaticStyles.primaryGreen,
                  onRefresh: () async {
                    await _getActorsById().then((value) {
                      error = false;
                    });
                  },
                  child: ErrorPage(errorMessage: errorMessage, iconPage: noInternet ? Icons.signal_wifi_off : null));
            }
          },
        ),
      ),
    );
  }

  _body(Size size) {
    return Container(
      color: StaticStyles.darkBackground,
      width: size.width,
      child: Column(
        children: [_episodeInitialData(size), _episodeCharacters(size)],
      ),
    );
  }

  _episodeInitialData(Size size) {
    return Column(
      children: [
        SizedBox(width: size.width, height: size.height * 0.03),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: size.width * 0.95,
              height: size.height * 0.15,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _episodeNumber(size),
                  _episodeRowData(size, 'Name: ', widget.episodeModel.name ?? 'No name'),
                  _episodeRowData(size, 'Air date: ', widget.episodeModel.airDate ?? 'No air date'),
                  _episodeRowData(size, 'Created: ', DateFormat.yMMMd().format(widget.episodeModel.created!).toString())
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  _episodeNumber(Size size) {
    return Container(
      width: size.width,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Text(widget.episodeModel.episode ?? 'No number episode',
          style: StaticStyles.mainTitleStyleGreen, textAlign: TextAlign.center),
    );
  }

  _episodeRowData(Size size, String description, String data) {
    return Container(
      width: size.width * 0.95,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(description, style: StaticStyles.whitecharacterDescriptionStyle),
          Flexible(
              child: Text(data,
                  style: StaticStyles.whitecharacterDataStyle,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  textAlign: TextAlign.center))
        ],
      ),
    );
  }

  _episodeCharacters(Size size) {
    return SizedBox(
      width: size.width * 0.95,
      height: size.height * 0.7,
      child: BlocBuilder<ActorBloc, ActorState>(
        builder: (context, state) {
          if ((state is ActorLoadingState || callingActors) && (!error && !noInternet)) {
            return Center(
                child: CircularProgressIndicator.adaptive(
                    valueColor: AlwaysStoppedAnimation<Color>(StaticStyles.primaryGreen)));
          } else if (state is ActorSuccessfulState && (!error && !noInternet)) {
            listOfActors = state.listOfActorsState;
          } else {
            if (kDebugMode) print('Actors load failed!');
            return RefreshIndicator(
                color: StaticStyles.primaryGreen,
                onRefresh: () async {
                  await _getActorsById().then((value) {
                    error = false;
                  });
                },
                child: ErrorPage(errorMessage: errorMessage, iconPage: noInternet ? Icons.signal_wifi_off : null));
          }
          return Column(
            children: [
              SizedBox(
                  height: size.height * 0.05,
                  width: size.width,
                  child: Text('Characters appearing', style: StaticStyles.characterTitleStyleGreen)),
              Expanded(
                  child: ListView.builder(
                      itemCount: listOfActors.length,
                      itemBuilder: ((context, index) {
                        return _actorCard(size, listOfActors[index]);
                      }))),
            ],
          );
        },
      ),
    );
  }

  _actorCard(Size size, CharacterModel characterModel) {
    return GestureDetector(
      onTap: (() async {
        await Navigator.push(
            context, MaterialPageRoute(builder: (context) => CharacterPage(characterModel: characterModel)));
      }),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        width: size.width * 0.9,
        height: size.height * 0.08,
        decoration:
            BoxDecoration(color: StaticStyles.darkCard, borderRadius: const BorderRadius.all(Radius.circular(6))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _actorImage(size, characterModel.image ?? StaticStyles.alternativeImage),
            _actorData(size, characterModel)
          ],
        ),
      ),
    );
  }

  _actorImage(Size size, String characterImage) {
    return SizedBox(
      width: size.width * 0.15,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), bottomLeft: Radius.circular(6)),
        child: FadeInImage.assetNetwork(placeholder: StaticStyles.placeholderImage, image: characterImage),
      ),
    );
  }

  _actorData(Size size, CharacterModel characterModel) {
    return Container(
      padding: const EdgeInsets.only(right: 12),
      width: size.width * 0.77,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: size.width * 0.5,
                child: Row(
                  children: [
                    Text('Name: ', style: StaticStyles.whitecharacterDescriptionStyle),
                    Flexible(
                      child: Text(characterModel.name ?? 'No name',
                          style: StaticStyles.whitecharacterDataStyle, overflow: TextOverflow.ellipsis, maxLines: 1),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Text('Id: ', style: StaticStyles.whitecharacterDescriptionStyle),
                  Text(characterModel.id.toString(), style: StaticStyles.whitecharacterDataStyle),
                ],
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text('Gender: ', style: StaticStyles.whitecharacterDescriptionStyle),
                  Text(characterModel.gender ?? 'No gender', style: StaticStyles.whitecharacterDataStyle),
                ],
              ),
              Row(
                children: [
                  Text('Status: ', style: StaticStyles.whitecharacterDescriptionStyle),
                  Text(characterModel.status ?? 'No status', style: StaticStyles.whitecharacterDataStyle),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
