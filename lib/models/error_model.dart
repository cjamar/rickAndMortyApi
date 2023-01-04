import 'package:equatable/equatable.dart';

/// Author: Carlos López-Jamar
/// Model: Error Model
/// Version 3.3.4

class ErrorModel extends Equatable {
  final String? statusCode;
  final List? messages;

  const ErrorModel({this.statusCode, this.messages});

  factory ErrorModel.fromJson(Map<String, dynamic> json) =>
      ErrorModel(statusCode: json["status"] ?? '', messages: json["message"] ?? '');

  Map<String, dynamic> toJson() => {"messsage": messages, "status": statusCode};

  static const empty = ErrorModel(statusCode: '', messages: []);

  @override
  List<Object?> get props => [statusCode, messages];

  @override
  bool get stringify => true;
}
