import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'loginscreen.dart';

// void main() {
//   runApp(BirdifyApp());
// }

// class BirdifyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData.dark(),
//       home: Testdashboardscreen(),
//     );
//   }
// }

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
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const Loginscreen(),), (route) => false);

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      name = box.read('name');
      email = box.read('email');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DASHBOARD'),
        centerTitle: true,
        // leading: IconButton(icon: Icon(LucideIcons.menu), onPressed: () {}),
        actions: [
          IconButton(icon: Icon(LucideIcons.bell), onPressed: () {}),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            // DrawerHeader(
            //   padding: EdgeInsets.symmetric(vertical: 10.0),
            //   margin: EdgeInsets.symmetric(vertical: 10.0),
            //   child: Column(
            //   crossAxisAlignment: CrossAxisAlignment.start,
            //   children: [
            //     SizedBox(height: 10.0,),
            //     CircleAvatar(
            //       radius: 30.0,
            //       // backgroundImage: AssetImage('assetName'),
            //     ),
            //     SizedBox(height: 10.0,),
            //     Text('Uzair Ahmed'),
            //     Text('uzairahmed289@gmail.com'),
            //   ],
            // )),
            Container(
              color: Colors.blue,
              padding: EdgeInsets.only(left: 17.0, top: 10.0, bottom: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 30.0,),
                  CircleAvatar(
                    radius: 30.0,
                    backgroundImage: AssetImage('assets/dummy.png'),
                  ),
                  SizedBox(height: 10.0,),
                  Text(name ?? "", style: TextStyle(color: Colors.white,),),
                  Text(email ?? "", style: TextStyle(color: Colors.white),),
                ],
              ),
            ),
            Divider(
              color: Colors.white70,
            ),
            ListTile(
              title: Text('Profile'),
              leading: Icon(Icons.person),
              onTap: () => {
                Navigator.pop(context),
              },
            ),
            ListTile(
              title: Text('Settings'),
              leading: Icon(Icons.settings),
              onTap: () => {
                Navigator.pop(context),
              },

            ),
            ListTile(
              title: Text('Logout'),
              leading: Icon(Icons.logout),
              onTap: () => {
                logoutUser()
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          spacing: 60.0,
          children: [
            // TextField(
            //   decoration: InputDecoration(
            //     hintText: 'Search',
            //     prefixIcon: Icon(LucideIcons.search),
            //     suffixIcon: Icon(LucideIcons.filter),
            //     border: OutlineInputBorder(
            //       borderRadius: BorderRadius.circular(12),
            //     ),
            //     filled: true,
            //     fillColor: Colors.grey[900],
            //   ),
            // ),
            _buildDashboardButton(LucideIcons.shoppingCart, 'Bird Marketplace', context),
            _buildDashboardButton(LucideIcons.camera, 'Identify a Bird (AI Recognition)', context),
            _buildDashboardButton(LucideIcons.folder, 'My Listings', context),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(LucideIcons.plus, size: 36),
        shape: CircleBorder(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: Colors.black,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(icon: Icon(LucideIcons.home), onPressed: () {}),
            IconButton(icon: Icon(LucideIcons.heart), onPressed: () {}),
            SizedBox(width: 48),
            IconButton(icon: Icon(LucideIcons.messageSquare), onPressed: () {}),
            IconButton(icon: Icon(LucideIcons.user), onPressed: () {}),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardButton(IconData icon, String title, BuildContext context) {

    double screenHeight = MediaQuery.of(context).size.height;
    return
      InkWell(
        highlightColor: Colors.green,
        onTap: () {},
        child:
        Container(
          padding: EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: Colors.lightBlue,
          ),
          // alignment: Alignment.center,
          height: screenHeight*0.1,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(icon, size: 30, color: Colors.white),
              SizedBox(width: 10),
              Text(title, style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
  }
}

