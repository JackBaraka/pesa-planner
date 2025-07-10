import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'input_decoration.dart';

final kenyanTheme = ThemeData(
  primaryColor: AppColors.kenyaGreen,
  colorScheme: ColorScheme.fromSwatch().copyWith(
    secondary: AppColors.kenyaGold,
  ),
  fontFamily: 'Nunito',
  textTheme: TextTheme(titleLarge: heading1, bodyLarge: bodyText),
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.kenyaGreen,
    titleTextStyle: TextStyle(
      color: AppColors.kenyaWhite,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
  inputDecorationTheme: kenyanInputTheme(),
);
