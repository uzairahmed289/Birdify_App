// ignore: unused_import
import 'dart:developer';
import 'package:birdify_flutter/screens/splashscreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get_storage/get_storage.dart';

import 'app_theme.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Request notification permission
  await FirebaseMessaging.instance.requestPermission();

  await GetStorage.init();
  print("🌓 Stored dark mode? ${GetStorage().read('isDarkMode')}");
  runApp( Birdify());
}


class Birdify extends StatelessWidget {
  final box = GetStorage();

  @override
  Widget build(BuildContext context) {
    final isDark = box.read('isDarkMode') ?? false;

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: Splashscreen(),
    );
  }
}