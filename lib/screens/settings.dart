import 'package:birdify_flutter/screens/changepassword.dart';
import 'package:birdify_flutter/screens/loginscreen.dart';
import 'package:birdify_flutter/screens/mylisting.dart';
import 'package:birdify_flutter/screens/profilepage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get_storage/get_storage.dart';
import 'package:birdify_flutter/screens/controllers/DashboardController.dart';
import 'package:birdify_flutter/screens/testdashboardscreen.dart';

class SettingsPage extends StatelessWidget {
  final box = GetStorage();

void logoutUser(BuildContext context) {
  box.erase();
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => const Loginscreen()),
    (route) => false,
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildSectionTitle("Account"),
          _buildTile(Icons.edit, "Edit Profile", () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context)=> ProfilePage()),
              );
          }),
          _buildTile(Icons.lock, "Change Password", () {
            Navigator.push(context, MaterialPageRoute(builder: (context)=> ChangePasswordScreen()));
          }),
          _buildTile(Icons.logout, "Logout", () {
            logoutUser(context);
          }),

          // _buildSectionTitle("Notifications"),
          // _buildSwitchTile(Icons.chat, "Chat Notifications", true, (val) {}),
          // _buildSwitchTile(Icons.notifications, "Listing Alerts", true, (val) {}),

          _buildSectionTitle("App Preferences"),

          GetBuilder<DashboardController>(
  builder: (dashboard) => _buildSwitchTile(
    Icons.dark_mode,
    "Dark Mode",
    dashboard.isDark,
    (val) {
      dashboard.changeTheme();
    },
  ),
),
          // _buildTile(Icons.language, "Language", () {}),
          // _buildTile(Icons.text_fields, "Text Size", () {}),

          _buildSectionTitle("Marketplace"),
          _buildTile(Icons.list, "My Listings", () {
            Navigator.push(context, MaterialPageRoute(builder: (context)=> MyListing()));
          }),
          // _buildTile(Icons.favorite, "Saved Listings", () {}),

          _buildSectionTitle("About"),
_buildTile(Icons.info_outline, "About Birdify", () {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text("About Birdify"),
      content: SingleChildScrollView(
        child: Text(
          "Birdify is your all-in-one platform for bird enthusiasts. "
          "You can identify bird species, detect gender using AI, and explore a dedicated marketplace for buying and selling birds, cages, and feed.\n\n"
          "Version: 1.0.0\nDeveloped by: Team Birdify",
        ),
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text("Got it"))],
    ),
  );
}),
_buildTile(Icons.privacy_tip, "Terms & Privacy", () {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text("Terms & Privacy"),
      content: SingleChildScrollView(
        child: Text(
          "By using Birdify, you agree to our terms of service and privacy policy. "
          "We respect your privacy and never share your data without consent. "
          "All activity is governed by local and international data protection regulations.",
        ),
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text("Close"))],
    ),
  );
}),
          _buildTile(Icons.app_settings_alt, "App Version", () {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: Text("App Version"),
                content: Text("Birdify v1.0.0"),
              ),
            );
          }),

          _buildSectionTitle("Support"),
_buildTile(Icons.support_agent, "Contact Support", () {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text("Contact Support"),
      content: Text("For support, please email us at birdify0@gmail.com or WhatsApp us at +923041348792."),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text("OK"))],
    ),
  );
}),

_buildTile(Icons.bug_report, "Report a Bug", () {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text("Report a Bug"),
      content: Text("Found a bug? Email us with details and screenshots at birdify0@gmail.com."),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text("OK"))],
    ),
  );
}),

_buildTile(Icons.help, "FAQs", () {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text("FAQs"),
      content: Text("Coming soon! We're working on a helpful FAQ section for your common questions."),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text("OK"))],
    ),
  );
}),

        ],
      ),
    );
  }

  Widget _buildTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile(IconData icon, String title, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      secondary: Icon(icon),
      title: Text(title),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }
}
