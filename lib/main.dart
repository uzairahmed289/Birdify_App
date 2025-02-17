// ignore: unused_import
import 'dart:developer';
import 'package:birdify_flutter/screens/splashscreen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const Birdify());
}

class Birdify extends StatelessWidget {
  const Birdify({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Splashscreen(),
    );
  }
}