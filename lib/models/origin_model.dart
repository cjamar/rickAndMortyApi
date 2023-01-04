import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';
part 'origin_model.g.dart';

/// Author: Carlos López-Jamar
/// Class: Origin Model
/// Version 3.3.4

@HiveType(typeId: 2)
// ignore: must_be_immutable
class OriginModel extends Equatable with HiveObjectMixin{
  @HiveField(0)
  final String? name;
  @HiveField(1)
  final String? url;

  OriginModel({this.name, this.url});

  factory OriginModel.fromJson(Map<String, dynamic> json) =>
      OriginModel(name: json["name"] ?? '', url: json["url"] ?? '');

  Map<String, dynamic> toJson() => {"name": name, "url": url};

  @override
  List<Object?> get props => [name, url];

  @override
  bool get stringify => true;
}
