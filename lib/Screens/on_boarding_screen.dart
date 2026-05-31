import 'package:flutter/material.dart';
import 'Auth/login_screen.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({Key? key}) : super(key: key);

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      "title": "Welcome to Kwagala Farm",
      "subtitle": "Manage goats, track health metric analytics, feed intervals, and sales easily.",
      "image": "Assets/background1.jpg",
    },
    {
      "title": "Track Goats Effortlessly",
      "subtitle": "Record complete animal details including precise breed profiles, age, weight updates, and health conditions.",
      "image": "Assets/background2.jpg",
    },
    {
      "title": "Smart Farm Management",
      "subtitle": "Monitor financial transactions, receive prompt health alerts, and maximize your overall farm productivity.",
      "image": "Assets/background3.jpg",
    },
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isLastPage = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    _pages[index]["image"]!,
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                    errorBuilder: (context, error, stackTrace) => Container(color: Colors.black),
                  ),
                  Container(
                    color: Colors.black.withOpacity(0.65),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            _pages[index]["title"]!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _pages[index]["subtitle"]!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFFE2E8F0),
                              height: 1.5,
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
          Positioned(
            bottom: 50,
            left: 24,
            right: 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 6,
                      width: _currentPage == index ? 20 : 6,
                      decoration: BoxDecoration(
                        color: _currentPage == index ? Colors.orange.shade700 : Colors.white38,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Align(
                  alignment: isLastPage ? Alignment.center : Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      if (!isLastPage) {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade700,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
                      elevation: 0,
                    ),
                    child: Text(
                      isLastPage ? "Get Started" : "Next",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
