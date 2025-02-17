// ignore: unused_import
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:birdify_flutter/screens/dashboardscreen.dart';
import 'package:hexcolor/hexcolor.dart';

class Loginscreen extends StatefulWidget {
  const Loginscreen({super.key});

  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  TextEditingController passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    bool passvisibilty = true;
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      // backgroundColor: Colors.transparent,
    // appBar: AppBar(
    //   backgroundColor: Colors.lightBlueAccent,
    // ),
    body: SafeArea(
      child: Container(
        height: screenHeight,
        width: screenWidth,
        decoration: BoxDecoration(
      image: DecorationImage(image: AssetImage('assets/background.jpeg'),
      fit: BoxFit.fill,
      )
    ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(15.0),
              margin: EdgeInsets.symmetric(horizontal: 20.0),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15.0)),
              child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Welcome Back!", style: TextStyle(color: Colors.black, fontSize: 30, fontWeight: FontWeight.w600),),
                SizedBox(height: 10,),
                Text("Please enter your details", style: TextStyle(fontSize: 15, color: Colors.black38),),
                SizedBox(height: 20,),
                TextField(
                  decoration: InputDecoration(
                    hintText: "Email",
                    suffixIcon: Icon(Icons.email),
                  ),
                  controller: TextEditingController(),
                ),
                SizedBox(height: 10,),
                TextFormField(
                  obscureText: passvisibilty,
                  decoration: InputDecoration(
                      hintText: ("Password"),
                      suffixIcon: InkWell(
                        child: Icon(Icons.visibility),
                        onTap: () {
                          setState(() {
                          passvisibilty = !passvisibilty; 
                          }
                          );
                        },
                      )
                  ),
                  controller: passwordController
                ),
                SizedBox(height: 10,),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text("Forgot Password?", style: TextStyle(),),
                ),
                SizedBox(height: 10,),
                SizedBox(
                  width: 1000,
                  height: 50,
                  child: FilledButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(HexColor('#83CBEB'))
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context)=> DashboardScreen()) 
                          );
                      }, child: Text("Login")),
                ),
                SizedBox(height: 7.0,),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Dont have an account?', style: TextStyle(color: Colors.black, fontSize: 15.0, fontWeight: FontWeight.w600),),
                    SizedBox(
                      width: 4.0,
                    ),
                TextButton(
                  onPressed: (){
                    print('Button Pressed');
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Register here',
                    style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                  ),),
                  ],
                )
              ],
            ),
          )
      ),
            )
          ],
        )
      ),
    ),
        );
  }
}