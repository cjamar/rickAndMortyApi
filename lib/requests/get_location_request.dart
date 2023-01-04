import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rickandmorty/bloc/location_bloc/location_bloc.dart';
import 'package:rickandmorty/models/location_model.dart';
import 'package:rickandmorty/models/error_model.dart';
import 'package:rickandmorty/constants/methods_constants.dart';

/// Author: Carlos López-Jamar
/// Request Service: Get Locations
/// Version 3.3.4

class GetLocations {
  Future<dynamic> getLocations(BuildContext context, {int? page}) async {
    // Instancia del Bloc
    LocationBloc locationBloc = BlocProvider.of<LocationBloc>(context);
    // Listas para tratar el Bloc
    List<LocationModel> listOfLocations = [];
    List<LocationModel> moreLocationsList = [];
    // Instancia del httpClient
    HttpClient httpClient = HttpClient();
    // Manejo de datos del response
    dynamic data;
    dynamic jsonData;
    try {
      final request = await httpClient
          .getUrl(Uri.parse('${StaticMethods.baseUrl}/location?page=$page'))
          .timeout(const Duration(seconds: 8));

      var response = await request.close();

      data = await response.transform(utf8.decoder).join();
      jsonData = jsonDecode(data);

      if (response.statusCode == 200) {
        if (kDebugMode) print('RESPONSE Location 200');
        RickAndMortyLocationModel rickAndMortyLocationModel = RickAndMortyLocationModel.fromJson(jsonData);
        listOfLocations = rickAndMortyLocationModel.listOfLocations!;
        moreLocationsList.addAll(locationBloc.state.listOfLocations!);
        moreLocationsList.addAll(listOfLocations);
        locationBloc.add(AddLocationList(moreLocationsList));
        return rickAndMortyLocationModel;
      } else {
        return ErrorModel.empty;
      }
    } catch (e) {
      if (kDebugMode) print('ERROR, $e');
      return ErrorModel.empty;
    } finally {
      httpClient.close();
    }
  }
}
