// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rickandmorty/models/info_model.dart';
part 'location_model.g.dart';

/// Author: Carlos López-Jamar
/// Model: LocationModel
/// Version 3.3.4

@HiveType(typeId: 1)
// ignore: must_be_immutable
class LocationModel extends Equatable with HiveObjectMixin {
  LocationModel({this.id, this.name, this.type, this.dimension, this.residents, this.url, this.created});

  @HiveField(0)
  final int? id;
  @HiveField(1)
  final String? name;
  @HiveField(2)
  final String? type;
  @HiveField(3)
  final String? dimension;
  @HiveField(4)
  final List<String>? residents;
  @HiveField(5)
  final String? url;
  @HiveField(6)
  final String? created;

  factory LocationModel.fromJson(Map<String, dynamic> json) => LocationModel(
      id: json["id"],
      name: json["name"],
      type: json["type"],
      dimension: json["dimension"],
      residents: json["residents"] == null || json["residents"] == []
          ? []
          : List<String>.from(json["residents"].map((x) => x)),
      url: json["url"],
      created: json["created"]);

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "type": type,
        "dimension": dimension,
        "residents": residents,
        "url": url,
        "created": created
      };

  @override
  List<Object?> get props => [id, name, type, dimension, url, created];

  @override
  bool get stringify => true;
}

/// Model: RickAndMortyLocationModel
class RickAndMortyLocationModel extends Equatable {
  const RickAndMortyLocationModel({
    this.info,
    this.listOfLocations,
  });

  final InfoModel? info;
  final List<LocationModel>? listOfLocations;

  factory RickAndMortyLocationModel.fromJson(Map<String, dynamic> json) => RickAndMortyLocationModel(
        info: InfoModel.fromJson(json["info"]),
        listOfLocations: List<LocationModel>.from(json["results"].map((x) => LocationModel.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "info": info!.toJson(),
        "results": List<dynamic>.from(listOfLocations!.map((x) => x.toJson())),
      };

  @override
  List<Object?> get props => [info, listOfLocations];

  @override
  bool get stringify => true;
}
