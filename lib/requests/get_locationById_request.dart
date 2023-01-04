import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:rickandmorty/models/location_model.dart';
import 'package:rickandmorty/models/error_model.dart';

/// Author: Carlos López-Jamar
/// Request Service: Get Location by Id
/// Version 3.3.4

class GetLocationById {
  Future<dynamic> getLocationById(BuildContext context, String locationUrl) async {
    LocationModel locationModel;

    // Instancia del httpClient
    HttpClient httpClient = HttpClient();
    // Manejo de datos del response
    dynamic data;
    dynamic jsonData;
    try {
      final request = await httpClient.getUrl(Uri.parse(locationUrl)).timeout(const Duration(seconds: 4));

      var response = await request.close();

      data = await response.transform(utf8.decoder).join();
      jsonData = jsonDecode(data);

      if (response.statusCode == 200) {
        if (kDebugMode) print('RESPONSE Location 200');
        locationModel = LocationModel.fromJson(jsonData);

        return locationModel;
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
