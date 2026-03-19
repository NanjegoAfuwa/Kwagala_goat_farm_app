import 'package:flutter/material.dart';
import 'Auth/login_screen.dart';

class OnBoardingScreen extends StatefulWidget {
  @override
  _OnBoardingScreenState createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  PageController _controller = PageController();
  int currentPage = 0;

  // Adjustable opacity for full-screen overlay
  final double overlayOpacity = 0.3; // 0 = fully transparent, 1 = fully opaque

  List<Map<String, String>> pages = [
    {
      "title": "Welcome to Kwagala Farm",
      "subtitle": "Manage goats, track health, feeding and sales easily.",
      "background": "Assets/background1.jpg",
    },
    {
      "title": "Track Goats Effortlessly",
      "subtitle": "Record goat details including breed, age, weight & health.",
      "background": "Assets/background2.jpg",
    },
    {
      "title": "Smart Farm Management",
      "subtitle": "Monitor sales, health alerts and improve farm productivity.",
      "background": "Assets/background3.jpg",
    },
  ];

  @override
  void initState() {
    super.initState();

    // Preload images so they appear together with text
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (var page in pages) {
        precacheImage(
          AssetImage(page["background"]!),
          context,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Full-screen PageView
          PageView.builder(
            controller: _controller,
            physics: const NeverScrollableScrollPhysics(), // disable swipe
            itemCount: pages.length,
            onPageChanged: (index) {
              setState(() {
                currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  // Background image
                  SizedBox.expand(
                    child: Image.asset(
                      pages[index]["background"]!,
                      fit: BoxFit.cover,
                    ),
                  ),

                  // Semi-transparent overlay
                  Container(
                    color: Colors.black.withOpacity(overlayOpacity),
                  ),

                  // Centered text
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            pages[index]["title"]!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            pages[index]["subtitle"]!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // Skip button (top-right, bold white)
          if (currentPage != pages.length - 1)
            Positioned(
              top: 50,
              right: 20,
              child: GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => LoginScreen()),
                  );
                },
                child: const Text(
                  "Skip",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          // Dot indicators (centered above buttons)
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

          // Next button (bottom-right)
          if (currentPage != pages.length - 1)
            Positioned(
              bottom: 30,
              right: 20,
              child: ElevatedButton(
                onPressed: () {
                  _controller.nextPage(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Next",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),

          // Get Started button (bottom-center)
          if (currentPage == pages.length - 1)
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => LoginScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Get Started",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Dot widget
  Widget buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 5),
      height: 10,
      width: currentPage == index ? 25 : 10,
      decoration: BoxDecoration(
        color: currentPage == index ? Colors.orange : Colors.grey,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}