import 'package:birdify_flutter/screens/loginscreen.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(const Duration(seconds: 3),(){
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const Loginscreen(),), (route) => false);
    });
    // changeScreen();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      color: HexColor('#83CBEB'),
      padding: EdgeInsets.all(15.0),
      child: Image.asset('assets/bb3.png')
    );
  }
}