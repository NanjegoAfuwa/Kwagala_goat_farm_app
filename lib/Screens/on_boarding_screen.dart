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
      "image": "assets/background1.jpg",
    },
    {
      "title": "Track Goats Effortlessly",
      "subtitle": "Record complete animal details including precise breed profiles, age, weight updates, and health conditions.",
      "image": "assets/background2.jpg",
    },
    {
      "title": "Smart Farm Management",
      "subtitle": "Monitor financial transactions, receive prompt health alerts, and maximize your overall farm productivity.",
      "image": "assets/background3.jpg",
    },
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ⚡ PRELOAD PIPELINE: Forces system cache to grab asset photos ahead of time 
    // so background pictures and words load exactly together without any blank frames.
    for (var page in _pages) {
      precacheImage(AssetImage(page["image"]!), context);
    }
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
      body: Stack(
        children: [
          // 1. BACKDROP IMAGE CONTEXT ROUTER
          PageView.builder(
            controller: _controller,
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
                    // FIX: Container changed to SizedBox.shrink to correctly compile under 'const' parameters
                    errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                  ),
                  // High contrast text protective dark screen filter
                  Container(
                    color: Colors.black.withOpacity(0.65),
                  ),
                ],
              );
            },
          ),

          // 2. PERFECTLY CENTERED WORDS LAYER
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Column(
                  key: ValueKey<int>(_currentPage),
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      _pages[_currentPage]["title"]!,
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
                      _pages[_currentPage]["subtitle"]!,
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
          ),

          // 3. NAVIGATION CONTROLS & DYNAMIC POSITION BUTTON DECK
          Positioned(
            bottom: 50,
            left: 24,
            right: 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ALWAYS CENTERED STEP INDICATOR DOTS
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

                // DYNAMIC ACTION BUTTON ALIGNMENT DECK
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