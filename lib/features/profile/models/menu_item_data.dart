import 'package:flutter/material.dart';

class MenuItemData {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool isLast;

  MenuItemData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.isLast = false,
  });
}
