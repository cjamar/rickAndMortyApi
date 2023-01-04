import 'package:flutter/material.dart';
import 'package:rickandmorty/constants/styles_constants.dart';

class StaticMethods {
  static String baseUrl = 'https://rickandmortyapi.com/api';
  static String initialCharacterEndpoint = '/character';
  static String initialUrl = 'https://rickandmortyapi.com/api/character';

  static showSnackBar(BuildContext context, String text) {
    return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        text,
        style: StaticStyles.primarySnackbarStyle,
        textAlign: TextAlign.center,
      ),
      backgroundColor: StaticStyles.darkSnackbar,
    ));
  }
}
