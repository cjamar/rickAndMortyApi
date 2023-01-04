import 'package:hive_flutter/hive_flutter.dart';
import 'package:rickandmorty/models/character_model.dart';
import 'package:rickandmorty/models/location_model.dart';
import 'package:rickandmorty/models/origin_model.dart';

/// Author: Carlos López-Jamar
/// Static: Boxes
/// Version 3.3.4

class Boxes {
  static Box<CharacterModel> getCharacters() => Hive.box<CharacterModel>('characters');
  static Box<LocationModel> getLocations() => Hive.box<LocationModel>('locations');
  static Box<OriginModel> getOrigins() => Hive.box<OriginModel>('origins');
}
