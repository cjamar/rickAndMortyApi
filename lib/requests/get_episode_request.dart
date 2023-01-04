import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rickandmorty/bloc/episode_bloc/episode_bloc.dart';
import 'package:rickandmorty/constants/methods_constants.dart';
import 'package:rickandmorty/models/episode_model.dart';
import 'package:rickandmorty/models/error_model.dart';

/// Author: Carlos López-Jamar
/// Request Service: Get Episodes
/// Version 3.3.4

class GetEpisodes {
  Future<dynamic> getEpisodes(BuildContext context, {int? page}) async {
    EpisodeBloc episodeBloc = BlocProvider.of<EpisodeBloc>(context);
    List<EpisodeModel> listOfEpisodes = [];
    List<EpisodeModel> moreEpisodesList = [];

    HttpClient httpClient = HttpClient();
    dynamic data;
    dynamic jsonData;

    try {
      final request = await httpClient
          .getUrl(Uri.parse('${StaticMethods.baseUrl}/episode?page=$page'))
          .timeout(const Duration(seconds: 8));
      var response = await request.close();

      data = await response.transform(utf8.decoder).join();
      jsonData = jsonDecode(data);

      if (response.statusCode == 200) {
        if (kDebugMode) print('RESPONSE Episode 200');
        RickAndMortyEpisodeModel rickAndMortyEpisodeModel = RickAndMortyEpisodeModel.fromJson(jsonData);
        listOfEpisodes = rickAndMortyEpisodeModel.listOfEpisodes!;
        moreEpisodesList.addAll(episodeBloc.state.listOfEpisodes!);
        moreEpisodesList.addAll(listOfEpisodes);
        episodeBloc.add(AddEpisodeList(moreEpisodesList));

        return rickAndMortyEpisodeModel;
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
