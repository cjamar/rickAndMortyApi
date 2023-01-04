import 'dart:developer';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rickandmorty/bloc/character_bloc/character_bloc.dart';
import 'package:rickandmorty/constants/boxes_constants.dart';
import 'package:rickandmorty/models/error_model.dart';
import 'package:rickandmorty/models/character_model.dart';
import 'package:rickandmorty/constants/methods_constants.dart';

/// Author: Carlos López-Jamar
/// Request Service: Get Characters
/// Version 3.3.4

class GetCharacters {
  Future<dynamic> getCharacters(BuildContext context, {int? page}) async {
    // Instancia del Bloc
    CharacterBloc characterBloc = BlocProvider.of<CharacterBloc>(context);
    // Listas para tratar el Bloc
    List<CharacterModel> listOfCharacters = [];
    List<CharacterModel> moreCharactersList = [];
    // Instancia del httpClient
    HttpClient httpClient = HttpClient();
    // Manejo de datos del response
    dynamic data;
    dynamic jsonData;

    try {
      final request = await httpClient
          .getUrl(Uri.parse('${StaticMethods.baseUrl}/character?page=$page'))
          .timeout(const Duration(seconds: 8));

      var response = await request.close();

      data = await response.transform(utf8.decoder).join();
      jsonData = jsonDecode(data);

      if (response.statusCode == 200) {
        if (kDebugMode) print('RESPONSE Characters 200');
        RickAndMortyCharacterModel rickAndMortyModel = RickAndMortyCharacterModel.fromJson(jsonData);
        listOfCharacters = rickAndMortyModel.listOfCharacters!;
        moreCharactersList.addAll(characterBloc.state.listOfCharacters!);
        moreCharactersList.addAll(listOfCharacters);
        characterBloc.add(AddCharactersList(moreCharactersList));

        _addCharactersToDB(moreCharactersList);

        return rickAndMortyModel;
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

  /// Add characters to DataBase (Hive)
  _addCharactersToDB(List<CharacterModel> moreCharactersList) async {
    final boxCharacters = Boxes.getCharacters();
    for (var character in moreCharactersList) {
      if (!boxCharacters.containsKey(character.id)) {
        await boxCharacters.put('${character.id}', character);
      }
    }
    log('DATABASE LENGHT -> ${boxCharacters.length}');
  }
}
