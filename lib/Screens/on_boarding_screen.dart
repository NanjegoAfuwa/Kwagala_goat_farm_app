import 'package:flutter/material.dart';
import 'Auth/login_screen.dart';
import 'Auth/register.dart';
import 'Auth/forgot_password.dart';

class OnBoardingScreen extends StatefulWidget {
  @override
  _OnBoardingScreenState createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  PageController _controller = PageController();
  int currentPage = 0;

  List<Map<String, String>> pages = [
    {
      "title": "Welcome to Kwagala Farm",
      "subtitle": "Manage goats, track health, feeding and sales easily.",
      "icon": "🐐",
    },
    {
      "title": "Track Goats Effortlessly",
      "subtitle": "Record goat details including breed, age, weight & health.",
      "icon": "📋",
    },
    {
      "title": "Smart Farm Management",
      "subtitle": "Monitor sales, health alerts and improve farm productivity.",
      "icon": "📊",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// --- PAGES ---
          PageView.builder(
            controller: _controller,
            itemCount: pages.length,
            onPageChanged: (index) {
              setState(() {
                currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      pages[index]["icon"]!,
                      style: TextStyle(fontSize: 90),
                    ),
                    SizedBox(height: 40),

                    Text(
                      pages[index]["title"]!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 20),

                    Text(
                      pages[index]["subtitle"]!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          /// --- SKIP BUTTON ---
          Positioned(
            right: 20,
            top: 50,
            child: GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                );
              },
              child: Text(
                "Skip",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          /// --- DOT INDICATORS ---
          Positioned(
            bottom: 90,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                pages.length,
                (index) => buildDot(index),
              ),
            ),
          ),

          /// --- NEXT / GET STARTED BUTTON ---
          Positioned(
            bottom: 30,
            right: 20,
            child: ElevatedButton(
              onPressed: () {
                if (currentPage == pages.length - 1) {
                  // LAST PAGE → GO TO LOGIN
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => LoginScreen()),
                  );
                } else {
                  // GO TO NEXT PAGE
                  _controller.nextPage(
                    duration: Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                currentPage == pages.length - 1
                    ? "Get Started"
                    : "Next",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// --- DOT WIDGET ---
  Widget buildDot(int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      margin: EdgeInsets.symmetric(horizontal: 5),
      height: 10,
      width: currentPage == index ? 25 : 10,
      decoration: BoxDecoration(
        color: currentPage == index ? Colors.green : Colors.grey,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
