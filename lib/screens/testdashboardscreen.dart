import 'package:birdify_flutter/screens/addbirdlisting.dart';
import 'package:birdify_flutter/screens/addcagelisting.dart';
import 'package:birdify_flutter/screens/addfeedlisting.dart';
import 'package:birdify_flutter/screens/identification.dart';
import 'package:birdify_flutter/screens/marketplace.dart';
import 'package:birdify_flutter/screens/mylisting.dart';
import 'package:birdify_flutter/screens/profilepage.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'loginscreen.dart';

class Testdashboardscreen extends StatefulWidget {
  const Testdashboardscreen({super.key});

  @override
  State<Testdashboardscreen> createState() => _TestdashboardscreenState();
}

class _TestdashboardscreenState extends State<Testdashboardscreen> {
  final box = GetStorage();
  var name;
  var email;

  logoutUser() {
    box.erase();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const Loginscreen()),
      (route) => false,
    );
  }

  @override
  void initState() {
    super.initState();
    name = box.read('name');
    email = box.read('email');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Birdify Dashboard'),
        centerTitle: true,
        backgroundColor: Colors.teal,
        actions: [
          IconButton(icon: Icon(LucideIcons.bell), onPressed: () {}),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Colors.teal),
              accountName: Text(name ?? ""),
              accountEmail: Text(email ?? ""),
              currentAccountPicture: CircleAvatar(
                backgroundImage: AssetImage('assets/dummy.png'),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profile'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage())),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () => {},
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: logoutUser,
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildDashboardCard(LucideIcons.shoppingCart, 'Marketplace', () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => Marketplace()));
            }),
            _buildDashboardCard(LucideIcons.camera, 'Identify a Bird', () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => IdentificationPage()));
            }),
            _buildDashboardCard(LucideIcons.folder, 'My Listings', () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => MyListing()));
            }),
            _buildDashboardCard(LucideIcons.plusCircle, 'Add Listing [N/A]', () {
              //Navigator.push(context, MaterialPageRoute(builder: (_) => NewListing()));
            }),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(LucideIcons.bird),
            title: Text('Add Bird Listing'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => NewBirdListing()));
            },
          ),
          ListTile(
            leading: Icon(LucideIcons.package),
            title: Text('Add Cage Listing'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to CageListing() page
              // Example:
               Navigator.push(context, MaterialPageRoute(builder: (_) => NewCageListing()));
            },
          ),
          ListTile(
            leading: Icon(LucideIcons.utensils),
            title: Text('Add Feed Listing'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to FeedListing() page
              // Example:
              Navigator.push(context, MaterialPageRoute(builder: (_) => NewFeedListing()));
            },
          ),
        ],
      ),
    ),
  );
},

        child: Icon(LucideIcons.plus, size: 36),
        shape: CircleBorder(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: Colors.teal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(icon: Icon(LucideIcons.home), onPressed: () { }),
            IconButton(icon: Icon(LucideIcons.store), onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=> Marketplace()));
            }),
            SizedBox(width: 48),
            IconButton(icon: Icon(LucideIcons.messageSquare), onPressed: () {}),
            IconButton(icon: Icon(LucideIcons.user), onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=>ProfilePage()));
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 5,
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40, color: Colors.teal),
              SizedBox(height: 10),
              Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
