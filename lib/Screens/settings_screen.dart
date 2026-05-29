import 'package:flutter/material.dart';
import 'edit_farm_screen.dart';
import 'change_password_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  String _activeFarmRole = "Farm Manager"; // Options: Owner, Farm Manager, Herdsman, Veterinarian

  @override
  Widget build(BuildContext context) {
    final Color primaryGreen = Colors.green.shade700;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Settings Tracker", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // 1. OFFLINE DATA LOCAL CACHING GAUGE BUBBLE
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.cloud_done_rounded, color: Colors.blue.shade700),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    "All farm logs locally cached safely. Auto-sync will run once connectivity resets.",
                    style: TextStyle(fontSize: 12, color: Color(0xFF1E3A8A)),
                  ),
                )
              ],
            ),
          ),
          
          const SizedBox(height: 20),

          // 2. INTERACTIVE ROLE SELECTOR CARD
          const Text("Security Configuration", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Active Profile System Access Role", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text("Switch roles below to test different dynamic layout permissions.", style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _activeFarmRole,
                  decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                  items: ["Owner", "Farm Manager", "Herdsman", "Veterinarian"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (v) {
                    setState(() {
                      _activeFarmRole = v!; // Triggers a rebuild to show/hide relevant edit tools below!
                    });
                  },
                )
              ],
            ),
          ),

          const SizedBox(height: 24),
          const Text("Available Operations", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
          const SizedBox(height: 8),

          // 3. DYNAMIC CONFIGURATION VIEWS DEPENDING ON CHOSEN ROLE STATUS
          _buildDynamicOptionsByRole(primaryGreen),

          const SizedBox(height: 32),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              elevation: 0,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text("Log Out Account Profile", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  // Generates different functional cards dynamically based on user context permissions
  Widget _buildDynamicOptionsByRole(Color themeColor) {
    List<Widget> allowedOptions = [];

    // General options everyone can use
    allowedOptions.add(
      SwitchListTile(
        title: const Text("Push Notifications", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        subtitle: const Text("Receive health alerts instantly", style: TextStyle(fontSize: 12, color: Colors.grey)),
        secondary: Icon(Icons.notifications_outlined, color: themeColor),
        value: _notificationsEnabled,
        activeColor: themeColor,
        onChanged: (v) => setState(() => _notificationsEnabled = v),
      ),
    );
    allowedOptions.add(const Divider(height: 1, indent: 50));
    allowedOptions.add(
      _buildListTile(
        icon: Icons.lock_reset_rounded,
        iconColor: Colors.blue,
        title: "Change Password",
        subtitle: "Update account authentication key credentials",
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordScreen())),
      ),
    );

    // Dynamic filtering blocks
    if (_activeFarmRole == "Owner" || _activeFarmRole == "Farm Manager") {
      // Add heavy high-clearance administration features
      allowedOptions.add(const Divider(height: 1, indent: 50));
      allowedOptions.add(
        _buildListTile(
          icon: Icons.edit_note_rounded,
          iconColor: Colors.orange.shade700,
          title: "Edit Farm Profile Metadata",
          subtitle: "Modify official name, imagery assets, and location specs",
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditFarmScreen())),
        ),
      );
    } else if (_activeFarmRole == "Veterinarian") {
      // Add medicine log parameters configurations instead
      allowedOptions.add(const Divider(height: 1, indent: 50));
      allowedOptions.add(
        _buildListTile(
          icon: Icons.health_and_safety_rounded,
          iconColor: Colors.purple,
          title: "Medical Ledger Controls",
          subtitle: "Authorized access to prescribe batch treatments",
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vet medical log access authorized.")));
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
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
      trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8), size: 20),
    );
  }
}