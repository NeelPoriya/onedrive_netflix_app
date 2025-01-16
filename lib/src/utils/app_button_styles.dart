import 'package:flutter/material.dart';

class AppButtonStyles {
  // Light-colored button
  static final ButtonStyle lightButton = ElevatedButton.styleFrom(
    backgroundColor: Color.fromRGBO(100, 100, 100, 125),
    foregroundColor: Colors.white, // Text color
    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
    elevation: 2, // Shadow effect
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(4),
    ),
  );

  // Danger button
  static final ButtonStyle dangerButton = ElevatedButton.styleFrom(
    backgroundColor: Colors.primaries.first,
    foregroundColor: Colors.white, // Text color
    elevation: 2,
    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(4),
    ),
  );

  // Light-colored outlined button
  static final ButtonStyle transparentButton = OutlinedButton.styleFrom(
    foregroundColor: Colors.white,
    backgroundColor: Colors.transparent,
    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(4),
    ),
  );
}
