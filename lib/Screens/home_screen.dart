import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: const SizedBox(),
        elevation: 4,
        backgroundColor: Colors.green.shade700,
        centerTitle: false,
        titleSpacing: 0,
        iconTheme: const IconThemeData(color: Colors.white),

        // Orange bottom line
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(
            height: 3,
            color: Colors.orange,
          ),
        ),

        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(width: 12),
            SizedBox(
              width: 36,
              height: 56,
              child: Image.asset(
                'Assets/farm.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              "Kwagala Goat Farm",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'Assets/main1.jpg',
                width: double.infinity,
                height: 190,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Welcome back 👋",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              "Here’s what’s happening on your farm today",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 24),

            // Dashboard Grid
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                DashboardCard(title: "Total Goats", value: "125", icon: Icons.pets),
                DashboardCard(title: "Healthy", value: "118", icon: Icons.favorite),
                DashboardCard(title: "Sick", value: "7", icon: Icons.warning),
                DashboardCard(title: "Sales", value: "UGX 3.2M", icon: Icons.attach_money),
                DashboardCard(title: "Breeding", value: "24", icon: Icons.child_friendly),
                DashboardCard(title: "Expenses", value: "UGX 1.1M", icon: Icons.money_off),
              ],
            ),

            const SizedBox(height: 34),

            const Text(
              "Alerts",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            const AlertCard(
              icon: Icons.warning,
              text: "2 goats need vaccination",
              color: Colors.orange,
            ),

            const AlertCard(
              icon: Icons.info,
              text: "New batch added yesterday",
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}

// =====================
// DASHBOARD CARD
// =====================
class DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const DashboardCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 20,
            spreadRadius: 3,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Colors.orange,
            size: 40,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// =====================
// ALERT CARD
// =====================
class AlertCard extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const AlertCard({
    Key? key,
    required this.icon,
    required this.text,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}