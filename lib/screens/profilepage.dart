import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:birdify_flutter/screens/mylisting.dart';
import 'package:birdify_flutter/screens/loginscreen.dart';
import 'package:get_storage/get_storage.dart';
import 'package:birdify_flutter/screens/changepassword.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final user = FirebaseAuth.instance.currentUser;
  final box = GetStorage();
  bool uploading = false;

  void logoutUser() {
    box.erase();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const Loginscreen()),
      (route) => false,
    );
  }

  Future<void> uploadImage() async {
  final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
  if (pickedFile == null) return;

  setState(() => uploading = true);

  try {
    final bytes = await pickedFile.readAsBytes();
    final base64Image = base64Encode(bytes);
    final apiKey = '30b867aa9885cca834f786514b9a2dde';
    final url = Uri.parse("https://api.imgbb.com/1/upload?key=$apiKey");

    final response = await http.post(url, body: {
      "image": base64Image,
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final imageUrl = data['data']['url'];

      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({'profileImage': imageUrl});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile picture updated!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Something went wrong: $e')),
    );
  } finally {
    setState(() => uploading = false);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile Settings')),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(user!.uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('No user data found'));
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final profileImage = userData['profileImage'];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: profileImage != null
                          ? NetworkImage(profileImage)
                          : const AssetImage('assets/dummy.png') as ImageProvider,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: uploadImage,
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.teal,
                          child: Icon(Icons.edit, size: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                if (uploading) const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: CircularProgressIndicator(),
                ),
                const SizedBox(height: 16),
                Text(
                  userData['name'] ?? 'User Name',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  userData['email'] ?? '',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const Divider(height: 40),
                ListTile(
                  leading: const Icon(Icons.lock),
                  title: const Text('Change Password'),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const ChangePasswordScreen()));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.folder),
                  title: const Text('My Listings'),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => MyListing()));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Logout'),
                  onTap: logoutUser,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
