// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';

/// Author: Carlos López-Jamar
/// Model: InfoModel
/// Version 3.3.4

class InfoModel extends Equatable {
  const InfoModel({
    this.count,
    this.pages,
    this.next,
    this.prev,
  });

  final int? count;
  final int? pages;
  final String? next;
  final dynamic prev;

  factory InfoModel.fromJson(Map<String, dynamic> json) => InfoModel(
        count: json["count"],
        pages: json["pages"],
        next: json["next"],
        prev: json["prev"],
      );

  Map<String, dynamic> toJson() => {
        "count": count,
        "pages": pages,
        "next": next,
        "prev": prev,
      };

  @override
  List<Object?> get props => [count, pages, next, prev];

  @override
  bool get stringify => true;
}
