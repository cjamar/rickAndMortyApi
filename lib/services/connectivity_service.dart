// import 'dart:async';
// import 'dart:developer';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/services.dart';
// import 'package:rickandmorty/models/error_model.dart';

// /// Author: Carlos López-Jamar
// /// Request Service: Connectivity Service
// /// Version 3.3.4

// class ConnectivityService {
//   ConnectivityResult connectivityResult = ConnectivityResult.none;
//   final Connectivity _connectivity = Connectivity();
//   late StreamSubscription<ConnectivityResult> _connectivitySubscription;

//   StreamSubscription<ConnectivityResult> getConnectivitySubscription() {
//     _connectivitySubscription = _connectivity.onConnectivityChanged.listen(updateConnectionStatus);
//     return _connectivitySubscription;
//   }

//   Future<dynamic> initConnectivity() async {
//     late ConnectivityResult result;
//     try {
//       result = await _connectivity.checkConnectivity();
//     } on PlatformException catch (e) {
//       if (kDebugMode) log('Couldnt check connectivity status', error: e);
//       return ErrorModel.empty;
//     }
//     return updateConnectionStatus(result);
//   }

//   Future<dynamic> updateConnectionStatus(ConnectivityResult result) async {
//     if (result != ConnectivityResult.wifi && result != ConnectivityResult.mobile) {
//       return ErrorModel.empty;
//     } else {
//       return result;
//     }
//   }
// }
