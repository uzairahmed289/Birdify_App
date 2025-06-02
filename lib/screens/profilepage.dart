import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:birdify_flutter/screens/mylisting.dart';
import 'package:birdify_flutter/screens/loginscreen.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/dummy.png'), // replace with NetworkImage if user has uploaded pic
            ),
            SizedBox(height: 16),
            Text(user?.displayName ?? 'User Name', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(user?.email ?? '', style: TextStyle(fontSize: 16, color: Colors.grey)),

            Divider(height: 40),

            ListTile(
              leading: Icon(Icons.lock),
              title: Text('Change Password'),
              onTap: () {
                // Navigate to ChangePasswordPage or show dialog
              },
            ),
            ListTile(
              leading: Icon(Icons.folder),
              title: Text('My Listings'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => MyListing()));
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
              },
            ),
          ],
        ),
      ),
    );
  }
}
