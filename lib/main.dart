import 'package:flutter/material.dart';
import 'Screens/splash_screen.dart';
import 'Screens/goat_records.dart';
import 'Screens/add_goat.dart';
import 'Screens/analytics_screen.dart';
import 'Screens/settings_screen.dart';
import 'Screens/Auth/login_screen.dart';
import 'Screens/Auth/register.dart';
import 'Screens/Auth/forgot_password.dart';
import 'Widgets/bottom_nav.dart';

void main() {
  runApp(const KwagalaFarmApp());
}

class KwagalaFarmApp extends StatelessWidget {
  const KwagalaFarmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Kwagala Goat Farm",
      theme: ThemeData(primarySwatch: Colors.green),

      // Removed const
      home: SplashScreen(),

      routes: {
        '/home': (context) => BottomNav(),
        '/goats': (context) => GoatsScreen(),
        '/add-goat': (context) => AddGoatScreen(),
        '/analytics': (context) => AnalyticsScreen(),
        '/settings': (context) => SettingsScreen(),
      },
    );
  }
}