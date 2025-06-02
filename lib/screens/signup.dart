import 'package:birdify_flutter/screens/testdashboardscreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();

}


class _SignupState extends State<Signup> {
  TextEditingController passwordController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  bool passvisibilty = true;


  var isLoad = false;

  Future<String?> registerUser() async {
    // if (password != confirmPassword) return 'Passwords do not match';
    try {
      setState(() {
        isLoad = true;
      });
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: emailController.text, password: passwordController.text);
          
      // Save additional fields in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'email': emailController.text.trim(),
        'name': nameController.text.trim(),
        'username': userNameController.text.trim(),
        'phone': phoneController.text.trim(),
        'uid': userCredential.user!.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return null; // success
    } on FirebaseAuthException catch (e) {
      setState(() {
        isLoad = false;
      });
      return e.message;
    } catch (e) {
      setState(() {
        isLoad = false;
      });
      return 'An unknown error occurred';
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
                Text("Create an account!", style: TextStyle(color: Colors.black, fontSize: 30, fontWeight: FontWeight.w600),),
                SizedBox(height: 10,),
                Text("Please enter your details", style: TextStyle(fontSize: 15, color: Colors.black38),),
                SizedBox(height: 20,),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Name',
                  ),
                  controller: nameController,
                ),
                SizedBox(height: 10.0,),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Username',
                  ),
                  controller: userNameController,
                ),
                SizedBox(height: 10.0,),
                TextField(
                  decoration: InputDecoration(
                    hintText: "Email",
                    suffixIcon: Icon(Icons.email),
                  ),
                  controller: emailController,
                ),
                SizedBox(height: 10.0,),
                TextField(
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: "Phone No",
                    suffixIcon: Icon(Icons.phone),
                  ),
                  controller: phoneController,
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
                    :  SizedBox(
                  width: 1000,
                  height: 50,
                  child: FilledButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(HexColor('#83CBEB'))
                      ),
                      onPressed: () async {
                        final error = await registerUser();

                        if (error != null) {
                          setState(() {
                            isLoad = false;
                          });
                          print("Error -> $error");
                        } else {
                          setState(() {
                            isLoad = false;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.black,
                            content: Text(
                              "User Registered Successfully, Please login",
                              style: TextStyle(color: Colors.white, fontSize: 18),
                            ),
                            duration: const Duration(seconds: 3),
                          ));
                          Navigator.pop(context);

                          print("Registration Successfully");
                        }
                      }, child: Text("Sign up")),
                ),
                SizedBox(height: 7.0,),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account?', style: TextStyle(color: Colors.black, fontSize: 15.0, fontWeight: FontWeight.w600),),
                    SizedBox(
                      width: 4.0,
                    ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Sign in',
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