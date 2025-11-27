import 'package:flutter/material.dart';
import 'Screens/splash_screen.dart';
import 'Screens/goat_records.dart';
import 'Screens/add_goat.dart';
import 'Screens/Auth/login_screen.dart';
import 'Screens/Auth/register.dart';
import 'Screens/Auth/forgot_password.dart';

void main() {
  runApp(KwagalaFarmApp());
}

class KwagalaFarmApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Kwagala Goat Farm",
      theme: ThemeData(primarySwatch: Colors.green),

      home: SplashScreen(),

      routes: {
        '/goats': (context) => GoatRecords(),
        '/add-goat': (context) => AddGoatScreen(),
      },
    );
  }
}
