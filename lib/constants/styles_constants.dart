import 'package:flutter/material.dart';

class StaticStyles {
  // ASSETS /////////////////////////////////////////////
  static String placeholderImage = 'assets/images/placeholder-image.jpg';
  static String planetImage = 'assets/images/planet.png';
  static String episodeImage = 'assets/images/episode.png';
  static String footerCharacterPageImage = 'assets/images/footer-characterPage.png';
  static String alternativeImage =
      'https://st3.depositphotos.com/6672868/13701/v/450/depositphotos_137014128-stock-illustration-user-profile-icon.jpg';
  // TEXTSTYLES /////////////////////////////////////////////
  static TextStyle mainTitleStyle = const TextStyle(fontSize: 18, color: Colors.black87, fontWeight: FontWeight.w500);
  static TextStyle mainTitleStyleWhite =
      const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w500);
  static TextStyle mainTitleStyleGreen = TextStyle(fontSize: 18, color: primaryGreen, fontWeight: FontWeight.w500);
  static TextStyle characterTitleStyle =
      const TextStyle(fontSize: 18, color: Colors.black54, fontWeight: FontWeight.w500);
  static TextStyle characterTitleStyleGreen = TextStyle(fontSize: 18, color: primaryGreen, fontWeight: FontWeight.w500);
  static TextStyle greyTitleStyle = const TextStyle(fontSize: 16, color: Colors.white38, fontWeight: FontWeight.w500);
  static TextStyle whitecharacterTitleStyle =
      const TextStyle(fontSize: 18, color: Colors.white70, fontWeight: FontWeight.w500);
  static TextStyle characterDataStyle =
      const TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w500);
  static TextStyle whitecharacterDataStyle =
      const TextStyle(fontSize: 14, color: Colors.white70, fontWeight: FontWeight.w500);
  static TextStyle whiteCharacterPrimaryDataStyle =
      const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500);
  static TextStyle whiteCharacterModalDataStyle =
      TextStyle(fontSize: 15, color: almostwhite, fontWeight: FontWeight.w500);
  static TextStyle greencharacterDataStyle = TextStyle(fontSize: 14, color: primaryGreen, fontWeight: FontWeight.w500);
  static TextStyle characterTitleCardStyle = TextStyle(fontSize: 15, color: white, fontWeight: FontWeight.w500);
  static TextStyle episodeTitleCardStyle =
      const TextStyle(fontSize: 15, color: Colors.white38, fontWeight: FontWeight.w500);
  static TextStyle characterDescriptionStyle =
      const TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w500);
  static TextStyle whitecharacterDescriptionStyle =
      const TextStyle(fontSize: 14, color: Colors.white38, fontWeight: FontWeight.w500);
  static TextStyle buttonStyle = const TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w500);
  static TextStyle searchBarLabelStyle =
      const TextStyle(fontSize: 16, color: Colors.white70, fontWeight: FontWeight.w500);
  static TextStyle searchBarHintStyle =
      const TextStyle(fontSize: 16, color: Colors.white30, fontWeight: FontWeight.w500);
  static TextStyle characterSectionStyle =
      const TextStyle(fontSize: 16, color: Colors.black45, fontWeight: FontWeight.w500);
  static TextStyle primarySnackbarStyle = TextStyle(fontSize: 15, color: primaryGreen, fontWeight: FontWeight.w500);

  static Color primaryGreen = const Color.fromARGB(255, 82, 161, 85);
  static Color slightlyDarkGreen = const Color.fromARGB(255, 45, 89, 46);
  static Color slightlyClearGreen = const Color.fromARGB(255, 105, 174, 108);
  static Color disabledGreen = const Color.fromARGB(255, 150, 197, 151);
  static Color darkGreen = const Color.fromARGB(255, 18, 35, 18);
  static Color darkestGrey = Colors.grey.shade800;
  static Color darkGrey = Colors.grey.shade500;
  static Color grey = Colors.grey.shade400;
  static Color cleargrey = Colors.grey.shade300;
  static Color almostwhite = const Color.fromARGB(204, 255, 255, 255);
  static Color white = const Color.fromARGB(255, 232, 232, 232);
  static Color dark = const Color.fromARGB(255, 49, 44, 44);
  static Color darkSnackbar = const Color.fromARGB(255, 32, 29, 29);
  static Color almostBlack = const Color.fromARGB(255, 39, 35, 35);
  static Color darkCard = const Color.fromARGB(255, 59, 55, 55);
  static Color darkBackground = const Color.fromARGB(255, 45, 43, 43);
  static Color red = Colors.redAccent;
  static Color amber = Colors.amberAccent;
}
