import 'package:birdify_flutter/screens/signup.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:birdify_flutter/screens/testdashboardscreen.dart';

class Loginscreen extends StatefulWidget {
  const Loginscreen({super.key});

  @override
  State<Loginscreen> createState() => _LoginscreenState();
}
class _LoginscreenState extends State<Loginscreen> {
  TextEditingController passwordController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  bool passvisibilty = true;

  var isLoad = false;
  String? errorMessage;
  final box = GetStorage();

  Future<Map<String, dynamic>?> loginUser({
    required String emailOrUsername,
    required String password,
  }) async {
    try {
      setState(() {
        isLoad = true;
      });
      String email = emailOrUsername;

      // Resolve username to email if needed
      if (!emailOrUsername.contains('@')) {
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('username', isEqualTo: emailOrUsername)
            .limit(1)
            .get();

        if (snapshot.docs.isEmpty) {
          return {'error': 'No user found with this username'};
        }

        email = snapshot.docs.first['email'];
      }

      // Authenticate with Firebase
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      String uid = userCredential.user!.uid;

      // Fetch user data from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (!userDoc.exists) {
        return {'error': 'User document does not exist'};
      }

      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      userData['uid'] = uid; // Optionally include UID

      print("Login successful, user data: $userData");

      return userData; // Return full user data

    } on FirebaseAuthException catch (e) {
      setState(() {
        isLoad = false;
      });
      return {'error': e.message};
    } catch (e) {
      setState(() {
        isLoad = false;
      });
      return {'error': 'An unknown error occurred'};
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
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
                  controller: emailController,
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
                isLoad ?
                    Center(child: CircularProgressIndicator(color: Colors.blue,),)
                    : SizedBox(
                  width: 1000,
                  height: 50,
                  child: FilledButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(HexColor('#83CBEB'))
                      ),
                      onPressed: () async {
                        final response = await loginUser(emailOrUsername: emailController.text, password: passwordController.text);
                        
                        if (response != null && response['error'] != null) {
                          setState(() {
                            isLoad = false;
                          });
                          print('Login failed: ${response['error']}');
                        } else {
                          setState(() {
                            box.write('uid', response?['uid']);
                            box.write('name', response?['name']);
                            box.write('email', response?['email']);
                            isLoad = false;
                          });
                          print("ID -> ${response?['uid']}");
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context)=> Testdashboardscreen())
                            );
                          // Access user fields: response['email'], response['username'], etc.
                        }

                      }, child: Text("Login")),
                ),
                SizedBox(height: 7.0,),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account?", style: TextStyle(color: Colors.black, fontSize: 15.0, fontWeight: FontWeight.w600),),
                    SizedBox(
                      width: 4.0,
                    ),
                TextButton(
                  onPressed: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context)=> Signup()));
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
  }}