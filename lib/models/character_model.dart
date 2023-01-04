import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rickandmorty/models/info_model.dart';
import 'package:rickandmorty/models/location_model.dart';
import 'package:rickandmorty/models/origin_model.dart';
part 'character_model.g.dart';

/// Author: Carlos López-Jamar
/// Model: CharacterModel
/// Version 3.3.4
@HiveType(typeId: 0)
// ignore: must_be_immutable
class CharacterModel extends Equatable with HiveObjectMixin {
  CharacterModel({
    this.id,
    this.name,
    this.status,
    this.species,
    this.type,
    this.gender,
    this.origin,
    this.location,
    this.image,
    this.episode,
    this.url,
    this.created,
  });

  @HiveField(0)
  final int? id;
  @HiveField(1)
  final String? name;
  @HiveField(2)
  final String? status;
  @HiveField(3)
  final String? species;
  @HiveField(4)
  final String? type;
  @HiveField(5)
  final String? gender;
  @HiveField(6)
  final OriginModel? origin;
  @HiveField(7)
  final LocationModel? location;
  @HiveField(8)
  final String? image;
  @HiveField(9)
  final List<String>? episode;
  @HiveField(10)
  final String? url;
  @HiveField(11)
  final DateTime? created;

  factory CharacterModel.fromJson(Map<String, dynamic> json) => CharacterModel(
        id: json["id"],
        name: json["name"],
        status: json["status"],
        species: json["species"],
        type: json["type"],
        gender: json["gender"],
        origin: OriginModel.fromJson(json["origin"]),
        location: LocationModel.fromJson(json["location"]),
        image: json["image"],
        episode:
            json["episode"] == null || json["episode"] == [] ? [] : List<String>.from(json["episode"].map((x) => x)),
        url: json["url"],
        created: DateTime.parse(json["created"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "status": status,
        "species": species,
        "type": type,
        "gender": gender,
        "origin": origin!.toJson(),
        "location": location!.toJson(),
        "image": image,
        "episode": List<dynamic>.from(episode!.map((x) => x)),
        "url": url,
        "created": created!.toIso8601String(),
      };

  @override
  List<Object?> get props => [id, name, status, species, type, gender, origin, location, image, episode, url, created];

  @override
  bool get stringify => true;
}

/// Model: RickAndMortyCharacterModel

class RickAndMortyCharacterModel extends Equatable {
  const RickAndMortyCharacterModel({
    this.info,
    this.listOfCharacters,
  });

  final InfoModel? info;
  final List<CharacterModel>? listOfCharacters;

  factory RickAndMortyCharacterModel.fromJson(Map<String, dynamic> json) => RickAndMortyCharacterModel(
        info: InfoModel.fromJson(json["info"]),
        listOfCharacters: List<CharacterModel>.from(json["results"].map((x) => CharacterModel.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "info": info!.toJson(),
        "results": List<dynamic>.from(listOfCharacters!.map((x) => x.toJson())),
      };

  @override
  List<Object?> get props => [info, listOfCharacters];

  @override
  bool get stringify => true;
}
