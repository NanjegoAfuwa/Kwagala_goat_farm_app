import 'package:flutter/material.dart';
import 'on_boarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _hasPreloadedImages = false;

  @override
  void initState() {
    super.initState();
    _initializeSplash();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasPreloadedImages) {
      _hasPreloadedImages = true;
      _preloadOnboardingImages();
    }
  }

  Future<void> _initializeSplash() async {
    try {
      await Future.delayed(const Duration(seconds: 3));
    } catch (_) {
      // ignore
    }
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnBoardingScreen()),
      );
    }
  }

  Future<void> _preloadOnboardingImages() async {
    const images = [
      'Assets/background1.jpg',
      'Assets/background2.jpg',
      'Assets/background3.jpg',
    ];
    for (final image in images) {
      try {
        await precacheImage(AssetImage(image), context);
      } catch (_) {
        // Ignore missing asset if it fails, we still navigate after splash.
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryGreen = Colors.green.shade700;

    return Scaffold(
      backgroundColor: primaryGreen,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Clean circular branding asset wrapper
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    "Assets/farm.png",
                    height: 80,
                    width: 80,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.gite_rounded, size: 60, color: primaryGreen),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Kwagala Goat Farm",
                  style: TextStyle(
                    fontSize: 26,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Precision Livestock Management",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.green.shade100,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.orange.shade400),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}