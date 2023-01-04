import 'dart:async';
import 'dart:developer';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:rickandmorty/constants/methods_constants.dart';
import 'package:rickandmorty/constants/styles_constants.dart';
import 'package:rickandmorty/models/character_model.dart';
import 'package:rickandmorty/models/episode_model.dart';
import 'package:rickandmorty/models/error_model.dart';
import 'package:rickandmorty/models/info_model.dart';
import 'package:rickandmorty/models/location_model.dart';
import 'package:rickandmorty/pages/episode_page.dart';
import 'package:rickandmorty/pages/location_page.dart';
import 'package:rickandmorty/requests/get_episodeById_request.dart';
import 'package:rickandmorty/requests/get_locationById_request.dart';
import 'package:rickandmorty/widgets/appbar_widget.dart';
import 'package:rickandmorty/widgets/errorpage_widget.dart';

/// Author: Carlos López-Jamar
/// Page: CharacterPage
/// Version 3.3.4

class CharacterPage extends StatefulWidget {
  final CharacterModel characterModel;
  const CharacterPage({super.key, required this.characterModel});

  @override
  State<CharacterPage> createState() => _CharacterPageState();
}

class _CharacterPageState extends State<CharacterPage> {
  /// Connectivity Service
  ConnectivityResult connectivityResult = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  late LocationModel locationModel;
  late EpisodeModel episodeModel;
  List<CharacterModel> listOfCharacters = [];
  List<EpisodeModel> listOfEpisodes = [];
  bool callingLocation = false;
  bool callingEpisodes = false;
  bool unknownLocation = false;
  InfoModel infoModel = const InfoModel();
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
    await _getEpisodesById();
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

  /// Calling to request for every episode in current character and add to bloc
  Future<List<EpisodeModel>> _getEpisodesById() async {
    setState(() {
      callingEpisodes = true;
    });

    // Waiting for complete the episodes loop and add every episode into the list and then return it
    await Future.wait(widget.characterModel.episode!.map((episode) async {
      var resp = await GetEpisodeById().getEpisodeById(context, episode);
      if (resp is EpisodeModel) {
        listOfEpisodes.add(resp);
        listOfEpisodes.sort(((b, a) => b.id!.compareTo(a.id!)));
        return listOfEpisodes;
      } else {
        if (resp is ErrorModel) {
          if (kDebugMode) print('Error,  $resp');
          errorMessage = 'Error occurred, swipe to refresh or restart the app if the problem persists';
          error = true;
          return null;
        } else {
          error = false;
          return null;
        }
      }
    }).toList());

    setState(() {
      callingEpisodes = false;
    });
    return listOfEpisodes;
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
        child: Scaffold(appBar: CustomAppBar(title: widget.characterModel.name!), body: _characterBody(size)));
  }

  _characterBody(Size size) {
    if (!error && !noInternet) {
      return SizedBox(
        width: size.width,
        height: size.height,
        child: SingleChildScrollView(
          child: Column(
            children: [_characterImage(size), _characterContent(size)],
          ),
        ),
      );
    } else {
      return RefreshIndicator(
          onRefresh: () async {
            await _getEpisodesById().then((value) {
              error = false;
            });
          },
          child: ErrorPage(
            errorMessage: errorMessage,
            iconPage: noInternet ? Icons.signal_wifi_off : null,
          ));
    }
  }

  _characterContent(Size size) {
    return Container(
      color: StaticStyles.darkBackground,
      width: size.width,
      child: Column(
        children: [_characterTitle(size), _characterData(size), _characterEpisodes(size)],
      ),
    );
  }

  _characterImage(Size size) {
    return SizedBox(
      width: size.width,
      height: size.height * 0.45,
      child: FittedBox(
        fit: BoxFit.cover,
        child: FadeInImage.assetNetwork(
            placeholder: StaticStyles.placeholderImage,
            image: widget.characterModel.image ?? StaticStyles.placeholderImage),
      ),
    );
  }

  _characterTitle(Size size) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      width: size.width * 0.95,
      height: size.height * 0.1,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                  color: StaticStyles.darkCard,
                ),
                child: Row(
                  children: [
                    _characterCircleStatus(size),
                    Text('ID: ${widget.characterModel.id.toString()}', style: StaticStyles.greyTitleStyle),
                  ],
                ),
              ),
            ],
          ),
          _characterLocation(size)
        ],
      ),
    );
  }

  _characterCircleStatus(Size size) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      width: size.width * 0.025,
      height: size.width * 0.025,
      decoration: BoxDecoration(
          color: widget.characterModel.status == 'Alive'
              ? StaticStyles.primaryGreen
              : widget.characterModel.status == 'Dead'
                  ? Colors.redAccent
                  : Colors.amberAccent,
          shape: BoxShape.circle),
    );
  }

  _characterLocation(Size size) {
    return GestureDetector(
      onTap: () async {
        // if we had pushed episodes and waiting charactersByEpisode response
        if (!callingEpisodes && !noInternet) {
          setState(() {
            callingLocation = true;
          });
          if (widget.characterModel.location != null && widget.characterModel.location!.name != 'unknown') {
            // Get the locationModel for pass to the locationPage constructor.
            // Use this location to loop the residents and add to the list for pass to the locationPage constructor too.
            _getLocationById().then((location) async {
              setState(() {
                callingLocation = false;
              });
              await Navigator.push(
                  context, MaterialPageRoute(builder: (context) => LocationPage(locationModel: locationModel)));
            });
          } else {
            StaticMethods.showSnackBar(context, "This character doesn't contain location");
          }
        } else {
          if (callingEpisodes) if (kDebugMode) print('Cannot entry to location page, waiting for episodes response...');
          null;
        }
      },
      child: Container(
          width: size.width * 0.6,
          decoration: BoxDecoration(
            color: widget.characterModel.location != null && widget.characterModel.location?.name != 'unknown'
                ? StaticStyles.primaryGreen
                : StaticStyles.darkCard,
            borderRadius: const BorderRadius.all(Radius.circular(7)),
          ),
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _locationData(
                  size,
                  'Location:',
                  widget.characterModel.location?.name == null || widget.characterModel.location?.name == 'unknown'
                      ? 'No location'
                      : widget.characterModel.location!.name!),
              Icon(Icons.arrow_circle_right, color: StaticStyles.almostwhite),
            ],
          )),
    );
  }

  _locationData(Size size, String description, String data) {
    return SizedBox(
      width: size.width * 0.48,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(description, style: StaticStyles.whitecharacterDescriptionStyle.copyWith(color: Colors.white70)),
          Flexible(
              child: Text(data.isNotEmpty ? data : '',
                  style: StaticStyles.whiteCharacterPrimaryDataStyle, overflow: TextOverflow.ellipsis, maxLines: 1))
        ],
      ),
    );
  }

  _characterData(Size size) {
    return SizedBox(
      width: size.width * 0.95,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _characterDataRow(size, 'Gender: ', widget.characterModel.gender ?? 'No gender'),
              _characterDataRow(size, 'Species: ', widget.characterModel.species ?? 'No species'),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _characterDataRow(size, 'Origin: ',
                  widget.characterModel.origin != null ? widget.characterModel.origin!.name! : 'No origin'),
              _characterDataRow(size, 'Created: ', DateFormat.yMMMd().format(widget.characterModel.created!)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _characterDataRow(size, 'Status: ', widget.characterModel.status ?? 'No status'),
              _characterDataRow(
                  size,
                  'Type: ',
                  widget.characterModel.type == null || widget.characterModel.type!.isEmpty
                      ? 'No type'
                      : widget.characterModel.type!),
            ],
          ),
          _characterUrl(size),
        ],
      ),
    );
  }

  _characterDataRow(Size size, String description, String data) {
    return Container(
      width: size.width * 0.45,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(description, style: StaticStyles.whitecharacterDescriptionStyle),
          Flexible(
              child: Text(data.isNotEmpty ? data : '',
                  style: StaticStyles.whitecharacterDataStyle, overflow: TextOverflow.ellipsis, maxLines: 2))
        ],
      ),
    );
  }

  _characterUrl(Size size) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: StaticStyles.darkCard, borderRadius: const BorderRadius.all(Radius.circular(6))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Icon(Icons.arrow_forward, size: 18, color: StaticStyles.primaryGreen),
          ),
          Text('Url: ', style: StaticStyles.whitecharacterDescriptionStyle),
          Text(widget.characterModel.url!.isNotEmpty ? widget.characterModel.url! : '',
              style: StaticStyles.whitecharacterDataStyle),
        ],
      ),
    );
  }

  _characterEpisodes(Size size) {
    if (listOfEpisodes.isNotEmpty) {
      return SizedBox(
        width: size.width,
        height: size.height * 0.35,
        child: Column(
          children: [
            Container(
                width: size.width * 0.95,
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text('Episodes: ', style: StaticStyles.whitecharacterTitleStyle)),
            Expanded(
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: listOfEpisodes.length,
                  itemBuilder: ((context, index) {
                    return _episodeContainer(size, listOfEpisodes[index], index);
                  })),
            ),
          ],
        ),
      );
    } else {
      return SizedBox(
        width: size.width,
        height: size.height * 0.35,
        child: Center(
            child: CircularProgressIndicator.adaptive(
                valueColor: AlwaysStoppedAnimation<Color>(StaticStyles.primaryGreen))),
      );
    }
  }

  _episodeContainer(Size size, EpisodeModel? episodeModel, int index) {
    return GestureDetector(
      onTap: () async {
        // if we had pushed episodes and waiting charactersByEpisode responses
        if (!callingLocation && !noInternet) {
          setState(() {
            callingEpisodes = true;
          });
          if (episodeModel.url != null && episodeModel.name != 'unknown') {
            await Navigator.push(
                context, MaterialPageRoute(builder: (context) => EpisodePage(episodeModel: episodeModel)));
          } else {
            StaticMethods.showSnackBar(context, "This character doesn't contain episode");
          }
          setState(() {
            callingEpisodes = false;
          });
        } else {
          if (callingLocation) if (kDebugMode) print('Cannot entry to episode page, waiting for locations response...');
          null;
        }
      },
      child: Container(
        // Only the first item has a left margin to get the scrolling effect without margins
        margin: EdgeInsets.only(right: 8, left: index == 0 ? 8 : 0),
        child: Column(
          children: [
            Container(
              width: size.width * 0.25,
              height: size.height * 0.15,
              decoration: BoxDecoration(
                color: StaticStyles.darkCard,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
                child: FittedBox(fit: BoxFit.cover, child: Image(image: AssetImage(StaticStyles.episodeImage))),
              ),
            ),
            Container(
              width: size.width * 0.25,
              height: size.height * 0.1,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: StaticStyles.darkSnackbar,
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(episodeModel!.episode ?? 'No episode number',
                      style: StaticStyles.whitecharacterDescriptionStyle, overflow: TextOverflow.ellipsis),
                  Text(episodeModel.name ?? 'No name',
                      style: StaticStyles.whitecharacterDataStyle, overflow: TextOverflow.ellipsis, maxLines: 3),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Get the complete model of the current location by calling to request with the url reference
  Future<LocationModel> _getLocationById() async {
    LocationModel emptyLocation = LocationModel();
    var response = await GetLocationById().getLocationById(context, widget.characterModel.location!.url!);
    if (response is LocationModel) {
      locationModel = response;
      return locationModel;
    } else {
      if (kDebugMode) print('${widget.characterModel.name} has not contain location');
      callingLocation = false;
      return emptyLocation;
    }
  }
}
