import 'package:flutter/material.dart';

abstract final class FlightColors {
  static const deepNavy = Color(0xFF03172C);
  static const panel = Color(0xFF092B50);
  static const skyBlue = Color(0xFF3DB8FF);
  static const cyan = Color(0xFF00E5FF);
  static const violet = Color(0xFF7B61FF);
  static const orange = Color(0xFFFFB347);
  static const green = Color(0xFF3DDC84);
  static const white = Color(0xFFF2F6FF);
  static const red = Color(0xFFFF5E6B);
}

ThemeData flightTheme() => ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: FlightColors.deepNavy,
  colorScheme: const ColorScheme.dark(
    primary: FlightColors.cyan,
    secondary: FlightColors.violet,
    tertiary: FlightColors.orange,
    surface: FlightColors.panel,
    error: FlightColors.red,
  ),
  textTheme: const TextTheme(
    displaySmall: TextStyle(
      fontSize: 34,
      fontWeight: FontWeight.w900,
      color: FlightColors.white,
    ),
    headlineSmall: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w900,
      color: FlightColors.white,
    ),
    titleMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w800,
      color: FlightColors.white,
    ),
    bodyMedium: TextStyle(fontSize: 12, height: 1.45, color: Color(0xFFC7D9EA)),
  ),
);
