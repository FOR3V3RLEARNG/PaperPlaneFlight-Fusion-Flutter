import 'dart:ui';

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

abstract final class FlightColors {
  static const deepNavy = Color(0xFF06122B);
  static const nightBlue = Color(0xFF111A2E);
  static const glass = Color(0xB812294C);
  static const glassHigh = Color(0xDD17355B);
  static const skyBlue = Color(0xFF3DB8FF);
  static const aeroCyan = Color(0xFF00E5FF);
  static const violet = Color(0xFF7B61FF);
  static const sunOrange = Color(0xFFFFB347);
  static const leafGreen = Color(0xFF3DDC84);
  static const coral = Color(0xFFFF6668);
  static const cloudWhite = Color(0xFFF2F6FF);
  static const muted = Color(0xFFA9B9D5);
}

ThemeData buildFlightTheme() {
  final base = FlexThemeData.dark(
    colors: const FlexSchemeColor(
      primary: FlightColors.skyBlue,
      secondary: FlightColors.aeroCyan,
      tertiary: FlightColors.violet,
      appBarColor: FlightColors.deepNavy,
      error: FlightColors.coral,
    ),
    useMaterial3: true,
  );

  final text = base.textTheme.copyWith(
    displayLarge: const TextStyle(
      color: FlightColors.cloudWhite,
      fontSize: 56,
      height: .95,
      fontWeight: FontWeight.w800,
      letterSpacing: -2.1,
      fontVariations: <FontVariation>[FontVariation('wght', 800)],
    ),
    headlineLarge: const TextStyle(
      color: FlightColors.cloudWhite,
      fontSize: 34,
      height: 1.03,
      fontWeight: FontWeight.w700,
      letterSpacing: -1.2,
      fontVariations: <FontVariation>[FontVariation('wght', 750)],
    ),
    headlineSmall: const TextStyle(
      color: FlightColors.cloudWhite,
      fontSize: 22,
      fontWeight: FontWeight.w700,
    ),
    titleLarge: const TextStyle(
      color: FlightColors.cloudWhite,
      fontSize: 20,
      fontWeight: FontWeight.w700,
    ),
    titleMedium: const TextStyle(
      color: FlightColors.cloudWhite,
      fontSize: 15,
      fontWeight: FontWeight.w600,
    ),
    bodyLarge: const TextStyle(
      color: FlightColors.cloudWhite,
      fontSize: 16,
      height: 1.45,
    ),
    bodyMedium: const TextStyle(
      color: FlightColors.muted,
      fontSize: 14,
      height: 1.45,
    ),
    labelLarge: const TextStyle(
      color: FlightColors.cloudWhite,
      fontSize: 13,
      fontWeight: FontWeight.w700,
      letterSpacing: .2,
    ),
  );

  return base.copyWith(
    scaffoldBackgroundColor: FlightColors.deepNavy,
    textTheme: text,
    cardTheme: const CardThemeData(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: FlightColors.glass,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(24)),
        side: BorderSide(color: Color(0x332F83C7)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 52),
        shape: const StadiumBorder(),
        textStyle: text.labelLarge,
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        minimumSize: const Size(48, 48),
        shape: const CircleBorder(),
      ),
    ),
    dividerColor: const Color(0x263D8BC8),
    splashFactory: InkSparkle.splashFactory,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
        TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
        TargetPlatform.macOS: ZoomPageTransitionsBuilder(),
        TargetPlatform.windows: ZoomPageTransitionsBuilder(),
        TargetPlatform.linux: ZoomPageTransitionsBuilder(),
      },
    ),
  );
}

TextStyle metricTextStyle(BuildContext context, {double size = 44}) {
  return Theme.of(context).textTheme.displayLarge!.copyWith(
        fontSize: size,
        fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
      );
}
