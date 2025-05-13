import 'package:birdify_flutter/screens/loginscreen.dart';
import 'package:birdify_flutter/screens/testdashboardscreen.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hexcolor/hexcolor.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {

  final box = GetStorage();

  changeScreen() {
    var uid;
    setState(() {
       uid  = box.read('uid');
    });
    print("already login $uid");
    if(uid != null && uid.toString().isNotEmpty) {
      Future.delayed(const Duration(seconds: 3),(){
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const Testdashboardscreen(),), (route) => false);
      });
    }
    else {
      Future.delayed(const Duration(seconds: 3),(){
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const Loginscreen(),), (route) => false);
      });
    }

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    changeScreen();
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