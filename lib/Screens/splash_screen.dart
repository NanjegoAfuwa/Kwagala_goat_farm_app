import 'package:flutter/material.dart';
import 'Auth/login_screen.dart';
import 'on_boarding_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToLogin();
  }

  _navigateToLogin() async {
    // Wait for 3 seconds
    await Future.delayed(Duration(seconds: 3));

    // Navigate to on boarding screen
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OnBoardingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[700],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // ✅ Farm Logo instead of icon
            Image.asset(
              "assets/farm.png",
              height: 100,
            ),

            SizedBox(height: 20),

            Text(
              "Kwagala Goat Farm",
              style: TextStyle(
                fontSize: 28,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 10),

            Text(
              "Quality Goat Farming",
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),

            SizedBox(height: 30),

            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}