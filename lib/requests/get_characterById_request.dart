import 'dart:developer';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:rickandmorty/constants/boxes_constants.dart';
import 'package:rickandmorty/models/error_model.dart';
import 'package:rickandmorty/models/character_model.dart';

/// Author: Carlos López-Jamar
/// Request Service: Get Character by Id
/// Version 3.3.4

class GetCharacterById {
  Future<dynamic> getCharacterById(BuildContext context, String characterUrl) async {
    // Instancia del httpClient
    HttpClient httpClient = HttpClient();
    // Manejo de datos del response
    dynamic data;
    dynamic jsonData;
    final boxCharacters = Boxes.getCharacters();

    for (var charDB in boxCharacters.values) {
      if (charDB.url == characterUrl) {
        return charDB;
      }
    }

    try {
      final request = await httpClient.getUrl(Uri.parse(characterUrl)).timeout(const Duration(seconds: 6));

      var response = await request.close();

      data = await response.transform(utf8.decoder).join();
      jsonData = jsonDecode(data);

      if (response.statusCode == 200) {
        if (kDebugMode) print('RESPONSE Character by Id 200');

        CharacterModel characterModel = CharacterModel.fromJson(jsonData);

        await boxCharacters.put('${characterModel.id}', characterModel);

        return characterModel;
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
