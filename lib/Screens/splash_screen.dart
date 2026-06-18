import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'on_boarding_screen.dart';
import '../Widgets/bottom_nav.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _fadeCtrl.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Preload ALL onboarding + app images here, while splash is visible.
    // By the time the 1200ms is up they are already in the GPU cache.
    for (final img in [
      'Assets/background1.jpg',
      'Assets/background2.jpg',
      'Assets/background3.jpg',
      'Assets/main1.jpg',
      'Assets/farm.png',
    ]) {
      precacheImage(AssetImage(img), context).catchError((_) {});
    }
    _init();
  }

  Future<void> _init() async {
    // Wait for splash to be visible AND images to be preloaded.
    // We run both in parallel — whichever takes longer wins.
    await Future.wait([
      Future.delayed(const Duration(milliseconds: 300)),
      _preloadImages(),
    ]);

    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        // Pass a flag so onboarding knows images are already cached
        pageBuilder: (_, __, ___) => token != null && token.isNotEmpty
            ? const BottomNav()
            : const OnBoardingScreen(imagesPreloaded: true),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  Future<void> _preloadImages() async {
    if (!mounted) return;
    await Future.wait([
      'Assets/background1.jpg',
      'Assets/background2.jpg',
      'Assets/background3.jpg',
      'Assets/main1.jpg',
    ].map((img) => precacheImage(AssetImage(img), context).catchError((_) {})));
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B3A1F),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 24,
                        offset: const Offset(0, 8))
                  ],
                ),
                child: Image.asset(
                  'Assets/farm.png',
                  height: 72, width: 72,
                  errorBuilder: (_, __, ___) => Icon(
                      Icons.agriculture_rounded,
                      size: 56, color: Colors.green.shade700),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Kwagala Goat Farm',
                style: TextStyle(
                    fontSize: 26,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5),
              ),
              const SizedBox(height: 8),
              Text(
                'Precision Livestock Management',
                style: TextStyle(
                    fontSize: 13,
                    color: Colors.green.shade200,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: 22, height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation(Colors.orange.shade400)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
