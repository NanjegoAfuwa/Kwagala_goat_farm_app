import 'package:flutter/material.dart';
import 'edit_farm_screen.dart';
import 'change_password_screen.dart';

// PLACEHOLDERS FOR SUB-SCREENS (Create files or point to your existing paths)
class EditProfileScreen extends StatelessWidget { const EditProfileScreen({Key? key}) : super(key: key); @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text("Edit Personal Profile"))); }
class DataSynchronizationScreen extends StatelessWidget { const DataSynchronizationScreen({Key? key}) : super(key: key); @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text("Data Sync Control"))); }

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  String _activeFarmRole = "Farm Manager"; // Options: Owner, Farm Manager, Herdsman, Veterinarian

  // Kwagala Farm Brand Colors
  final Color kwagalaGreen = const Color(0xFF4CAF50);
  final Color kwagalaOrange = const Color(0xFFF57C00);
  final Color backgroundGray = const Color(0xFFF8F9FA);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGray,
      appBar: AppBar(
        title: const Text("Application Settings", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F172A))),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          
          // 1. ANCHOR USER PROFILE METADATA SECTION
          _buildUserProfileHeader(),
          
          const SizedBox(height: 20),

          // 2. OFFLINE TELEMETRY LOCAL DATA CACHING GAUGE
          _buildSectionHeader("Data Connection Management"),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: kwagalaOrange.withOpacity(0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kwagalaOrange.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.cloud_done_rounded, color: kwagalaOrange),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Local Field Cache Secured", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF7C2D12))),
                      SizedBox(height: 2),
                      Text(
                        "All farm operational logs cached safely. System auto-sync will trigger immediately once connectivity resets.",
                        style: TextStyle(fontSize: 11, color: Color(0xFF9A3412), height: 1.3),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          
          const SizedBox(height: 24),

          // 3. SECURITY & ROLE SPECIFICATIONS
          _buildSectionHeader("Security & Access Permissions"),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white, 
              borderRadius: BorderRadius.circular(16), 
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Active Simulation Access Role", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                const SizedBox(height: 4),
                const Text("Modify roles to verify contextual system clearance variables across UI channels.", style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _activeFarmRole,
                  dropdownColor: Colors.white,
                  style: const TextStyle(color: Color(0xFF0F172A), fontSize: 14, fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: kwagalaGreen, width: 1.5)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: ["Owner", "Farm Manager", "Herdsman", "Veterinarian"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (v) {
                    setState(() {
                      _activeFarmRole = v!;
                    });
                  },
                )
              ],
            ),
          ),

          const SizedBox(height: 24),
          
          // 4. FUNCTIONAL OPTIONS BLOCK
          _buildSectionHeader("Application Parameters"),
          const SizedBox(height: 8),
          _buildDynamicOptionsByRole(),

          const SizedBox(height: 32),
          
          // LOGOUT TRIGGER BUTTON
          ElevatedButton.withIcon(
            icon: const Icon(Icons.logout_rounded, size: 18, color: Colors.white),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              elevation: 0,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () => Navigator.pop(context),
            label: const Text("Log Out Account Profile", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          ),
          
          const SizedBox(height: 16),
          const Center(
            child: Text(
              "Kwagala Goat Farm • Engine v2.4.1", 
              style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
            ),
          )
        ],
      ),
    );
  }

  // CUSTOM PROFILE HEADER ROW WIDGET
  Widget _buildUserProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: kwagalaGreen.withOpacity(0.1),
            child: Icon(Icons.person_rounded, color: kwagalaGreen, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Kwagala Farm Operator", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                const SizedBox(height: 2),
                Text(_activeFarmRole, style: TextStyle(fontSize: 12, color: kwagalaOrange, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit_square, color: const Color(0xFF64748B), size: 22),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())),
          )
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(), 
      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B), trackingWidth: 0.8),
    );
  }

  // DYNAMIC OPERATION DISCLOSURE CONTAINER
  Widget _buildDynamicOptionsByRole() {
    List<Widget> allowedOptions = [];

    // Push Notification Toggle Switch Row
    allowedOptions.add(
      SwitchListTile(
        title: const Text("Push Telemetry Feed Notifications", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
        subtitle: const Text("Receive live health, gestation and transactional feeds instantly", style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: kwagalaGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(Icons.notifications_active_outlined, color: kwagalaGreen, size: 20),
        ),
        value: _notificationsEnabled,
        activeColor: kwagalaGreen,
        onChanged: (v) => setState(() => _notificationsEnabled = v),
      ),
    );
    
    allowedOptions.add(const Divider(height: 1, indent: 56, color: Color(0xFFF1F5F9)));

    // Theme Selector Mode Toggle Switch Row
    allowedOptions.add(
      SwitchListTile(
        title: const Text("Dark Theme Mode UI", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
        subtitle: const Text("Optimize dashboard visibility for night field tracking operations", style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.zinc.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.dark_mode_outlined, color: Color(0xFF475569), size: 20),
        ),
        value: _darkModeEnabled,
        activeColor: kwagalaGreen,
        onChanged: (v) => setState(() => _darkModeEnabled = v),
      ),
    );

    allowedOptions.add(const Divider(height: 1, indent: 56, color: Color(0xFFF1F5F9)));
    
    // Change Password Action Tile
    allowedOptions.add(
      _buildListTile(
        icon: Icons.lock_reset_rounded,
        iconColor: Colors.blue.shade600,
        title: "Change Security Password",
        subtitle: "Update account master core authentication credentials",
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordScreen())),
      ),
    );

    // Conditional Clearance Rules Parsing
    if (_activeFarmRole == "Owner" || _activeFarmRole == "Farm Manager") {
      allowedOptions.add(const Divider(height: 1, indent: 56, color: Color(0xFFF1F5F9)));
      allowedOptions.add(
        _buildListTile(
          icon: Icons.edit_note_rounded,
          iconColor: kwagalaOrange,
          title: "Edit Farm Registry Metadata",
          subtitle: "Modify official metrics, batch configurations, and specs",
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditFarmScreen())),
        ),
      );
      
      allowedOptions.add(const Divider(height: 1, indent: 56, color: Color(0xFFF1F5F9)));
      allowedOptions.add(
        _buildListTile(
          icon: Icons.sync_problem_rounded,
          iconColor: Colors.teal,
          title: "Forced Sync Processing Pipelines",
          subtitle: "Manually flush local transactions ledger up to Django DB",
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DataSynchronizationScreen())),
        ),
      );
    } else if (_activeFarmRole == "Veterinarian") {
      allowedOptions.add(const Divider(height: 1, indent: 56, color: Color(0xFFF1F5F9)));
      allowedOptions.add(
        _buildListTile(
          icon: Icons.health_and_safety_rounded,
          iconColor: Colors.purple,
          title: "Medical Diagnostic Ledgers",
          subtitle: "Authorized operational clearance to update treatments tracking",
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vet health logs authorization validation success.")));
          },
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(children: allowedOptions),
    );
  }

  // REUSABLE UNIFORM LIST TILE ELEMENT WRAPPER
  Widget _buildListTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
      trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8), size: 22),
    );
  }
}