import 'package:flutter/material.dart';
import 'app_colors.dart';

InputDecorationTheme kenyanInputTheme() {
  return InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.kenyaGreen),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.kenyaGold, width: 2),
    ),
    labelStyle: const TextStyle(color: AppColors.kenyaGreen),
    floatingLabelStyle: const TextStyle(color: AppColors.kenyaGold),
  );
}
