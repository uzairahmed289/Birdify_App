import 'package:birdify_flutter/constants/AppColors.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static final light = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.bgColor,
    cardColor: AppColors.cardBg,
    dividerColor: AppColors.white,
  );

  static final dark = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBgColor,
    cardColor: AppColors.darkCardBg,
    dividerColor: AppColors.black
  );
}
