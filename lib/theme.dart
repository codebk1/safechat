import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    primaryColor: Colors.blue.shade800,
    fontFamily: 'Roboto',
    scaffoldBackgroundColor: Colors.white,
    dividerColor: Colors.blueGrey.shade50,
    textTheme: const TextTheme(
      headlineSmall: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 16.0,
      ),
      titleSmall: TextStyle(
        color: Colors.grey,
        fontSize: 14,
        fontWeight: FontWeight.w300,
      ),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: Colors.blueGrey.shade900,
    ),
    inputDecorationTheme: InputDecorationTheme(
      //focusColor: Colors.blue.shade900,
      filled: true,
      enabledBorder: UnderlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: const BorderSide(color: Colors.blue),
      ),
    ),
  );
}
