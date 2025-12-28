import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/app/app_initializer.dart';
import 'core/app/nti_app.dart';

/// Entry point of the NTI E-Commerce application
void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations (portrait only)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize all services
  await AppInitializer.initialize();

  // Run the app
  runApp(const NTIApp());
}
