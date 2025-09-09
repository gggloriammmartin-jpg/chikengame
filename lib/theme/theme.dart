import 'package:flutter/material.dart';
import 'app_colors.dart';

final primaryColor = AppColors.primaryColor;
final _font = 'Poppins';

final lightTheme = ThemeData(
  primaryColor: primaryColor,
  colorScheme: ColorScheme.fromSeed(
    seedColor: primaryColor,
    brightness: Brightness.light,
    surface: AppColors.whiteColor,
    onSurface: AppColors.blackColor,
    background: AppColors.whiteColor,
    onBackground: AppColors.blackColor,
    primary: AppColors.primaryColor,
    onPrimary: AppColors.blackColor,
    secondary: AppColors.primaryColor,
    onSecondary: AppColors.blackColor,
  ),
  scaffoldBackgroundColor: AppColors.whiteColor,
  canvasColor: AppColors.whiteColor,
  cardColor: AppColors.whiteColor,
  appBarTheme: AppBarTheme(
    elevation: 0,
    centerTitle: true,
    backgroundColor: AppColors.whiteColor,
    surfaceTintColor: AppColors.whiteColor,
  ),
  textTheme: textTheme,
);

final darktTheme = ThemeData(
  primaryColor: primaryColor,
  colorScheme: ColorScheme.fromSeed(
    seedColor: primaryColor,
    brightness: Brightness.dark,
    // surface: AppColors.darkSurfaceColor,
    // onSurface: AppColors.darkTextColor,
  ),
  // scaffoldBackgroundColor: AppColors.darkBackgroundColor,
  appBarTheme: AppBarTheme(
    elevation: 0,
    centerTitle: true,
    // backgroundColor: AppColors.darkBackgroundColor,
    // surfaceTintColor: AppColors.darkBackgroundColor,
  ),
  textTheme: textTheme,
);

final textTheme = TextTheme(
  displayLarge: TextStyle(
    fontSize: 57,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
    fontFamily: _font,
  ),
  displayMedium: TextStyle(
    fontSize: 45,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    fontFamily: _font,
  ),
  displaySmall: TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    fontFamily: _font,
  ),
  headlineLarge: TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    fontFamily: _font,
  ),
  headlineMedium: TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    fontFamily: _font,
  ),
  headlineSmall: TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    fontFamily: _font,
  ),
  titleLarge: TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    letterSpacing: 0,
    fontFamily: _font,
  ),
  titleMedium: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    fontFamily: _font,
  ),
  titleSmall: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    fontFamily: _font,
  ),
  bodyLarge: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    fontFamily: _font,
  ),
  bodyMedium: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    fontFamily: _font,
  ),
  bodySmall: TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    fontFamily: _font,
  ),
  labelLarge: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    fontFamily: _font,
  ),
  labelMedium: TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    fontFamily: _font,
  ),
  labelSmall: TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    fontFamily: _font,
  ),
);
