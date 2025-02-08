import 'package:flutter/material.dart';

// Definizione dei colori principali
const Color primaryColor = Colors.yellow; // Giallo
const Color accentColor = Colors.orange; // Arancione
const Color backgroundColor = Colors.black; // Nero

// Definizione del tema
final ThemeData appTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: primaryColor,
  hintColor: accentColor,
  scaffoldBackgroundColor: backgroundColor,
  fontFamily: 'Roboto',
  textTheme: TextTheme(
    displayLarge: TextStyle(
        fontSize: 32.0, fontWeight: FontWeight.bold, color: primaryColor),
    bodyLarge: TextStyle(fontSize: 16.0, color: Colors.white),
  ),
  appBarTheme: AppBarTheme(
    color: backgroundColor,
    elevation: 0,
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: primaryColor,
    textTheme: ButtonTextTheme.primary,
  ),
);
