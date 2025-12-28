import 'package:flutter/material.dart';

/// Model class for onboarding page content
class OnboardingItem {
  final String title;
  final String description;
  final IconData icon;
  final Color primaryColor;
  final Color secondaryColor;

  const OnboardingItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.primaryColor,
    required this.secondaryColor,
  });
}
