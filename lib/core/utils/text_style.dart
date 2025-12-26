// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:nti_project/core/constants/app_colors.dart';

abstract class TextStyles {
  static const title24Bold = TextStyle(
    fontFamily: 'Inter',
    fontSize: 24,
    fontWeight: FontWeight.w800,
  );
  static const subtitle18Bold = TextStyle(
    fontFamily: 'Inter',
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );
  static const subtitle16Bold = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );
  static const text16SemiBold = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    // color: Colors.black54,
  );
  static const text14Light = TextStyle(fontFamily: 'Inter', fontSize: 14);
  static const text14Medium = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );
  static const text12Light = TextStyle(fontFamily: 'Inter', fontSize: 12);
  static const projectNameStyle = TextStyle(
    fontFamily: 'Lobster',
    fontSize: 44,
    color: AppColors.primary,
  );
}
