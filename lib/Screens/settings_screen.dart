import 'package:flutter/material.dart';
import 'edit_farm_screen.dart'; 
import 'change_password.dart'; // Import change password screen

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),

          // ================= Account Section =================
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              "Account",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Profile → navigates to EditFarmScreen
          Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Profile"),
              subtitle: const Text("Edit farm info, name, logo, etc."),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditFarmScreen(),
                  ),
                );
              },
            ),
          ),

          // Change Password → navigates to ChangePasswordScreen
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              leading: const Icon(Icons.lock),
              title: const Text("Change Password"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChangePasswordScreen(),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // ================= Notifications Section =================
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              "Notifications",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Card(
            margin: const EdgeInsets.all(8),
            child: SwitchListTile(
              title: const Text("Enable Notifications"),
              secondary: Icon(
                Icons.notifications,
                color: _notificationsEnabled ? Colors.orange : Colors.grey,
              ),
              value: _notificationsEnabled,
              activeColor: Colors.orange,
              activeTrackColor: Colors.orange.shade200,
              onChanged: (val) {
                setState(() {
                  _notificationsEnabled = val;
                });
              },
            ),
          ),

          const SizedBox(height: 20),

          // ================= Appearance Section =================
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              "Appearance",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Card(
            margin: const EdgeInsets.all(8),
            child: SwitchListTile(
              title: const Text("Dark Mode"),
              secondary: Icon(
                Icons.dark_mode,
                color: _darkMode ? Colors.orange : Colors.grey,
              ),
              value: _darkMode,
              activeColor: Colors.orange,
              activeTrackColor: Colors.orange.shade200,
              onChanged: (val) {
                setState(() {
                  _darkMode = val;
                });
              },
            ),
          ),

          const SizedBox(height: 20),

          // ================= Logout Button =================
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: () {
                // Handle logout
              },
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text(
                "Logout",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}