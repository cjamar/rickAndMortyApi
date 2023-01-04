/// Author: Carlos López-Jamar
/// Helper: ObservableAppBarAction
/// Version 3.3.4

/// Receives a string to capitalize (separates the first letter from the rest and make an uppercase. Then, join the two parts again)
class Capitalize {
  String string(String text) {
    if (text.length <= 1) return text.toUpperCase();
    var words = text.split(' ');
    var capitalized = words.map((word) {
      var first = word[0].toUpperCase();
      var rest = word.substring(1).toLowerCase();
      return '$first$rest';
    });
    return capitalized.join();
  }
}
