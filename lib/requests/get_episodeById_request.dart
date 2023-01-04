import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:rickandmorty/models/episode_model.dart';
import 'package:rickandmorty/models/error_model.dart';

/// Author: Carlos López-Jamar
/// Request Service: Get Episode by Id
/// Version 3.3.4

class GetEpisodeById {
  Future<dynamic> getEpisodeById(BuildContext context, String characterurl) async {
    EpisodeModel episodeModel;

    // Instancia del httpClient
    HttpClient httpClient = HttpClient();
    // Manejo de datos del response
    dynamic data;
    dynamic jsonData;
    try {
      final request = await httpClient.getUrl(Uri.parse(characterurl)).timeout(const Duration(seconds: 4));

      var response = await request.close();

      data = await response.transform(utf8.decoder).join();
      jsonData = jsonDecode(data);

      if (response.statusCode == 200) {
        if (kDebugMode) print('RESPONSE Episode 200');
        episodeModel = EpisodeModel.fromJson(jsonData);

        return episodeModel;
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
