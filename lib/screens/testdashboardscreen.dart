import 'package:birdify_flutter/constants/AppColors.dart';
import 'package:birdify_flutter/screens/addbirdlisting.dart';
import 'package:birdify_flutter/screens/addcagelisting.dart';
import 'package:birdify_flutter/screens/addfeedlisting.dart';
import 'package:birdify_flutter/screens/controllers/DashboardController.dart';
import 'package:birdify_flutter/screens/identification.dart';
import 'package:birdify_flutter/screens/inbox.dart';
import 'package:birdify_flutter/screens/marketplace.dart';
import 'package:birdify_flutter/screens/mylisting.dart';
import 'package:birdify_flutter/screens/profilepage.dart';
import 'package:birdify_flutter/screens/settings.dart';
import 'package:birdify_flutter/screens/webview_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'loginscreen.dart';
import 'package:url_launcher/url_launcher.dart';

class Testdashboardscreen extends StatefulWidget {
  const Testdashboardscreen({super.key});

  @override
  State<Testdashboardscreen> createState() => _TestdashboardscreenState();
}

class _TestdashboardscreenState extends State<Testdashboardscreen> {
  final box = GetStorage();
  final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);
  

  var name;
  var email;
  var profileImage;

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
  saveTokenToFirestore();
  name = box.read('name');
  email = box.read('email');



  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid != null) {
    FirebaseFirestore.instance.collection('users').doc(uid).get().then((doc) {
      if (doc.exists) {
        final data = doc.data();
        setState(() {
          profileImage = data != null && data.containsKey('profileImage')
              ? data['profileImage']
              : null;
        });
      }
    }).catchError((e) {
      // Optional: log error if needed
      //print("Error loading profile image: $e");
    });
  }
}

void saveTokenToFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'fcmToken': token,
      });
      print("📱 FCM Token saved: $token");
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(
        init: DashboardController(),
        builder: (dashboard) => Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Theme.of(context).dividerColor),
        title: Text('Birdify Dashboard', style: TextStyle(
          color: Theme.of(context).dividerColor
        ),),
        centerTitle: true,
        backgroundColor: HexColor('#83CBEB'),
        actions: [
          IconButton(icon: Icon(LucideIcons.bell, color: Theme.of(context).dividerColor,), onPressed: () {}),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return UserAccountsDrawerHeader(
                    accountName: Text(""),
                    accountEmail: Text(""),
                    currentAccountPicture: CircleAvatar(
                      backgroundImage: AssetImage('assets/dummy.png'),
                    ),
                    decoration: BoxDecoration(color: HexColor('#83CBEB')),
                  );
                }

                final data = snapshot.data!.data() as Map<String, dynamic>;
                final name = data['name'] ?? "";
                final email = data['email'] ?? "";
                final imageUrl = data['profileImage'];

                return UserAccountsDrawerHeader(
                  decoration: BoxDecoration(color: AppColors.darkBlue),
                  accountName: Text(name.toString().capitalizeFirst.toString(), style: TextStyle(fontWeight: FontWeight.w600 ,color: Theme.of(context).dividerColor,),),
                  accountEmail: Text(email , style: TextStyle(color: Theme.of(context).dividerColor,),),
                  currentAccountPicture: CircleAvatar(
                    backgroundImage: imageUrl != null
                        ? NetworkImage(imageUrl)
                        : const AssetImage('assets/dummy.png') as ImageProvider,
                  ),
                );
              },
            ),

            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: Icon(Icons.person),
                    title: Text('Profile'),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfilePage()),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.settings),
                    title: Text('Settings'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context)=> SettingsPage())
                        );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.logout),
                    title: Text('Logout'),
                    onTap: logoutUser,
                  ),
                ],
              ),
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Dark Mode'),
                  Switch(
                      value: dashboard.isDark,
                      onChanged: (val) {
                        dashboard.changeTheme();
                  }),
                ],
              ),
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
  child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
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
            _buildDashboardCard(LucideIcons.plusCircle, 'Add Listing', () {
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
                          Navigator.push(context, MaterialPageRoute(builder: (_) => NewCageListing()));
                        },
                      ),
                      ListTile(
                        leading: Icon(LucideIcons.utensils),
                        title: Text('Add Feed Listing'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => NewFeedListing()));
                        },
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
        const SizedBox(height: 32),
        BlogSection(),
      ],
    ),
  ),
),

      
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.darkBlue,
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
        shape: CircleBorder(),
        child: Icon(LucideIcons.plus, size: 36),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: HexColor('#83CBEB'),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(icon: Icon(LucideIcons.home, color: Theme.of(context).dividerColor,), onPressed: () { }),
            IconButton(icon: Icon(LucideIcons.store , color: Theme.of(context).dividerColor,), onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=> Marketplace()));
            }),
            SizedBox(width: 48),
            IconButton(icon: Icon(LucideIcons.messageSquare, color: Theme.of(context).dividerColor,), onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=> Inboxpage()));
            }),
            IconButton(icon: Icon(LucideIcons.user , color: Theme.of(context).dividerColor,), onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=>ProfilePage()));
            }),
          ],
        ),
      ),
    ));
  }

  Widget _buildDashboardCard(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 5,
        color: Theme.of(context).cardColor,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40, color: AppColors.darkBlue),
              SizedBox(height: 10),
              Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}



class BlogSection extends StatelessWidget {
  final List<Map<String, String>> blogs = [
    {
      'title': '🐦 10 Tips for New Bird Owners',
      'url': 'https://www.thesprucepets.com/tips-for-new-bird-owners-390491'
    },
    {
      'title': '🪺 Choosing the Right Cage for Your Pet Bird',
      'url': 'https://www.petsmart.com/learning-center/bird-care/birdcage-setup/A0043.html'
    },
    {
      'title': '🥣 What Should You Feed Your Bird?',
      'url': 'https://kb.rspca.org.au/knowledge-base/what-should-i-feed-my-birds/'
    },
    {
      'title': '🧠 Training Your Bird – A Beginner’s Guide',
      'url': 'https://myrightbird.com/articles/5-essential-tips-for-training-your-pet-bird'
    },
    {
      'title': '🦜 How to Keep Your Bird Mentally Stimulated',
      'url': 'https://www.batcopetsitting.com/parrots-mental-health/'
    },
  ];

void _openInWebView(BuildContext context, String title, String url) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => BlogWebViewScreen(title: title, url: url),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Birdify Blogs',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...blogs.map((blog) => InkWell(
              onTap: () => _openInWebView(context, blog['title']!, blog['url']!),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  blog['title']!,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.blue,
                  ),
                ),
              ),
            )),
      ],
    );
  }
}

