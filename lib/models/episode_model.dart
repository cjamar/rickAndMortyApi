// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/foundation.dart';

import 'package:rickandmorty/models/info_model.dart';

/// Author: Carlos López-Jamar
/// Model: EpisodeModel
/// Version 3.3.4

class EpisodeModel {
  const EpisodeModel({this.id, this.name, this.airDate, this.episode, this.characters, this.url, this.created});

  final int? id;
  final String? name;
  final String? airDate;
  final String? episode;
  final List<String>? characters;
  final String? url;
  final DateTime? created;

  factory EpisodeModel.fromJson(Map<String, dynamic> json) => EpisodeModel(
      id: json["id"],
      name: json["name"],
      airDate: json["air_date"],
      episode: json["episode"],
      characters: json["characters"] == null || json["characters"] == []
          ? []
          : List<String>.from(json["characters"].map((x) => x)),
      url: json["url"],
      created: DateTime.parse(json["created"]));

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "air_date": airDate,
        "episode": episode,
        "characters": List<dynamic>.from(characters!.map((x) => x)),
        "url": url,
        "created": created!.toIso8601String()
      };

  @override
  String toString() {
    return 'EpisodeModel(id: $id, name: $name, airDate: $airDate, episode: $episode, characters: $characters, url: $url, created: $created)';
  }
}

class RickAndMortyEpisodeModel {
  const RickAndMortyEpisodeModel({this.info, this.listOfEpisodes});

  final InfoModel? info;
  final List<EpisodeModel>? listOfEpisodes;

  factory RickAndMortyEpisodeModel.fromJson(Map<String, dynamic> json) => RickAndMortyEpisodeModel(
      info: InfoModel.fromJson(json["info"]),
      listOfEpisodes: List<EpisodeModel>.from(json["results"].map((x) => EpisodeModel.fromJson(x))));

  Map<String, dynamic> toJson() =>
      {"info": info!.toJson(), "results": List<dynamic>.from(listOfEpisodes!.map((x) => x.toJson()))};
}
