import 'dart:async';
import 'dart:developer';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:rickandmorty/bloc/character_bloc/character_bloc.dart';
import 'package:rickandmorty/bloc/resident_bloc/resident_bloc.dart';
import 'package:rickandmorty/constants/methods_constants.dart';
import 'package:rickandmorty/constants/styles_constants.dart';
import 'package:rickandmorty/models/character_model.dart';
import 'package:rickandmorty/models/error_model.dart';
import 'package:rickandmorty/models/location_model.dart';
import 'package:rickandmorty/pages/character_page.dart';
import 'package:rickandmorty/requests/get_characterById_request.dart';
import 'package:rickandmorty/widgets/appbar_widget.dart';
import 'package:rickandmorty/widgets/errorpage_widget.dart';

/// Author: Carlos López-Jamar
/// Page: Location Page
/// Version 3.3.4
class LocationPage extends StatefulWidget {
  final LocationModel locationModel;

  const LocationPage({super.key, required this.locationModel});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  /// Connectivity Service
  ConnectivityResult connectivityResult = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  late DateTime created;
  late List<CharacterModel> listOfResidents;
  // List<CharacterModel> listOfResidents = [];
  bool callingResidents = false;
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
    // Parsing the 'created' data to Datetime of the location model before printing
    created = DateTime.parse(widget.locationModel.created!);
    await _initConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    await _getResidentsById();
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
  Future<void> _getResidentsById() async {
    setState(() {
      callingResidents = true;
    });

    listOfResidents = [];
    ResidentBloc residentBloc = BlocProvider.of<ResidentBloc>(context);

    // Waiting for complete the residents loop and add every resident into the list and then return it
    await Future.wait(widget.locationModel.residents!.map((resident) async {
      var resp = await GetCharacterById().getCharacterById(context, resident);
      if (resp is CharacterModel) {
        if (!listOfResidents.contains(resp)) listOfResidents.add(resp);
        // Add the character if the list doesn't contain this character already
        residentBloc.add(AddResidentsList(listOfResidents));
      } else {
        if (resp is ErrorModel) {
          if (kDebugMode) print('Error,  $resp');
          errorMessage = 'Error occurred, swipe to refresh or restart the app if the problem persists';
          error = true;
        } else {
          error = false;
        }
      }
    }).toList());
    if (listOfResidents.isEmpty) {
      // If some of the locations are empty of residents, clear the bloc to show the current list. If not, it will load with new residents
      residentBloc.add(const AddResidentsList([]));
    }
    setState(() {
      callingResidents = false;
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
          appBar: CustomAppBar(title: widget.locationModel.name!),
          backgroundColor: StaticStyles.darkBackground,
          body: BlocBuilder<CharacterBloc, CharacterState>(
            builder: (context, state) {
              if (state is CharacterLoadingState && (!error && !noInternet)) {
                return Center(
                    child: CircularProgressIndicator.adaptive(
                        valueColor: AlwaysStoppedAnimation<Color>(StaticStyles.primaryGreen)));
              } else if (state is CharacterSuccessfulState && (!error && !noInternet)) {
                return _body(size);
              } else {
                return RefreshIndicator(
                    color: StaticStyles.primaryGreen,
                    onRefresh: () async {
                      await _getResidentsById().then((value) {
                        error = false;
                      });
                    },
                    child: ErrorPage(
                      errorMessage: errorMessage,
                      iconPage: noInternet ? Icons.signal_wifi_off : null,
                    ));
                // return Center(child: Text('Error state', style: StaticStyles.greyTitleStyle));
              }
            },
          )),
    );
  }

  _body(Size size) {
    return SizedBox(
      width: size.width,
      height: size.height,
      child: SingleChildScrollView(
        child: Column(children: [_locationInitialData(size), _locationResidents(size)]),
      ),
    );
  }

  _locationInitialData(Size size) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      width: size.width * 0.95,
      height: size.height * 0.22,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _rowData(size, 'Name:', widget.locationModel.name ?? 'No name'),
              _rowData(size, 'Type', widget.locationModel.type ?? 'No type'),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _rowData(size, 'Dimension', widget.locationModel.dimension ?? 'No dimension'),
              _rowData(size, 'Created', created.toString().isEmpty ? '' : DateFormat.yMMMd().format(created)),
            ],
          ),
          _columnData(size, 'Url: ', widget.locationModel.url ?? 'No url'),
        ],
      ),
    );
  }

  _rowData(Size size, String description, String data) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      width: size.width * 0.45,
      height: size.height * 0.06,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(description, style: StaticStyles.whitecharacterDescriptionStyle),
        Flexible(
            child: Text(data.isNotEmpty ? data : '',
                style: StaticStyles.whitecharacterDataStyle, overflow: TextOverflow.ellipsis, maxLines: 2)),
      ]),
    );
  }

  _columnData(Size size, String description, String data) {
    return Container(
      decoration: BoxDecoration(
        color: StaticStyles.darkCard,
        borderRadius: const BorderRadius.all(Radius.circular(6)),
      ),
      padding: const EdgeInsets.all(8),
      width: size.width * 0.95,
      child: Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Icon(Icons.arrow_forward, size: 18, color: StaticStyles.primaryGreen),
        ),
        Text(description, style: StaticStyles.whitecharacterDescriptionStyle),
        Text(data, style: StaticStyles.whitecharacterDataStyle),
      ]),
    );
  }

  _locationResidents(Size size) {
    return SizedBox(
      width: size.width * 0.95,
      height: size.height * 0.65,
      child: BlocBuilder<ResidentBloc, ResidentState>(
        builder: (context, state) {
          if ((state is ResidentLoadingState || callingResidents) && !error) {
            return Center(
                child: CircularProgressIndicator.adaptive(
                    valueColor: AlwaysStoppedAnimation<Color>(StaticStyles.primaryGreen)));
          } else if (state is ResidentSuccessfulState && !error) {
            listOfResidents = state.listOfResidentsState;
            if (kDebugMode) print('Residents in bloc: ${listOfResidents.length}');
          } else {
            if (kDebugMode) print('Locations load failed!');
            return RefreshIndicator(
                onRefresh: () async {
                  _getResidentsById();
                },
                child: ErrorPage(errorMessage: errorMessage));
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                  height: size.height * 0.05,
                  width: size.width,
                  child: Text('Residents', style: StaticStyles.characterTitleStyleGreen)),
              listOfResidents.isEmpty
                  ? Center(child: Text('No residents found', style: StaticStyles.greyTitleStyle))
                  : Expanded(
                      child: ListView.builder(
                          itemCount: listOfResidents.length,
                          itemBuilder: ((context, index) {
                            return _residentsCard(size, listOfResidents[index]);
                          })))
            ],
          );
        },
      ),
    );
  }

  _residentsCard(Size size, CharacterModel characterModel) {
    return GestureDetector(
      onTap: () async {
        if (kDebugMode) print('Character ---> ${characterModel.name}');
        await Navigator.push(
            context, MaterialPageRoute(builder: ((context) => CharacterPage(characterModel: characterModel))));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        width: size.width * 0.9,
        height: size.height * 0.08,
        decoration:
            BoxDecoration(color: StaticStyles.darkCard, borderRadius: const BorderRadius.all(Radius.circular(6))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [_residentImage(size, characterModel), _residentData(size, characterModel)],
        ),
      ),
    );
  }

  _residentImage(Size size, CharacterModel characterModel) {
    return SizedBox(
      width: size.width * 0.15,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(8)),
        child: FadeInImage.assetNetwork(
            placeholder: StaticStyles.placeholderImage,
            image: characterModel.image != null ? characterModel.image! : StaticStyles.alternativeImage),
      ),
    );
  }

  _residentData(Size size, CharacterModel characterModel) {
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
