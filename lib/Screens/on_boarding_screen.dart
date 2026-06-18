import 'package:flutter/material.dart';
import 'Auth/login_screen.dart';

class OnBoardingScreen extends StatefulWidget {
  /// When true (passed from SplashScreen), images are already cached —
  /// skip the preload wait and show the first screen instantly.
  final bool imagesPreloaded;

  const OnBoardingScreen({Key? key, this.imagesPreloaded = false})
      : super(key: key);

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen>
    with TickerProviderStateMixin {
  int _currentPage = 0;

  // Tracks whether we're ready to show content
  // If images were preloaded by splash, we start as ready immediately.
  late bool _ready;

  // Initial reveal fade (only plays if we had to wait for preload)
  late AnimationController _initFadeCtrl;
  late Animation<double> _initFadeAnim;

  // Per-page text: fade + subtle slide on Next press
  late AnimationController _textCtrl;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;

  final List<Map<String, String>> _pages = [
    {
      'title': 'Welcome to Kwagala Farm',
      'subtitle':
          'Manage goats, track health metrics, feed intervals, and sales all in one place.',
      'image': 'Assets/background1.jpg',
    },
    {
      'title': 'Track Goats Effortlessly',
      'subtitle':
          'Record complete animal details including breed profiles, age, weight updates, and health conditions.',
      'image': 'Assets/background2.jpg',
    },
    {
      'title': 'Smart Farm Management',
      'subtitle':
          'Monitor finances, receive real time health alerts, and maximise your overall farm productivity.',
      'image': 'Assets/background3.jpg',
    },
  ];

  @override
  void initState() {
    super.initState();

    // If splash already preloaded images, skip the wait entirely
    _ready = widget.imagesPreloaded;

    // Initial fade-in controller (used when we had to self-preload)
    _initFadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _initFadeAnim =
        CurvedAnimation(parent: _initFadeCtrl, curve: Curves.easeIn);

    // Text transition controller
    _textCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _textFade = CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut);
    _textSlide =
        Tween<Offset>(begin: const Offset(0.05, 0), end: Offset.zero).animate(
            CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut));

    if (_ready) {
      // Already cached — start fully visible immediately
      _initFadeCtrl.value = 1.0;
      _textCtrl.value = 1.0;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only self-preload if splash didn't already do it
    if (!_ready) _selfPreload();
  }

  Future<void> _selfPreload() async {
    await Future.wait(_pages.map((p) async {
      try {
        await precacheImage(AssetImage(p['image']!), context);
      } catch (_) {}
    }));
    if (mounted) {
      setState(() => _ready = true);
      _initFadeCtrl.forward();
      _textCtrl.value = 1.0;
    }
  }

  @override
  void dispose() {
    _initFadeCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    if (_currentPage < _pages.length - 1) {
      _textCtrl.reset();
      setState(() => _currentPage++);
      _textCtrl.forward();
    } else {
      _toLogin();
    }
  }

  void _toLogin() => Navigator.pushReplacement(
      context, MaterialPageRoute(builder: (_) => const LoginScreen()));

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == _pages.length - 1;

    // Show a matching dark screen while self-preloading
    // (only happens if arrived here without going through SplashScreen)
    if (!_ready) {
      return const Scaffold(backgroundColor: Color(0xFF1B3A1F));
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1B3A1F),
      body: FadeTransition(
        opacity: _initFadeAnim,
        child: Stack(
          fit: StackFit.expand,
          children: [

            // ── Background image — instant swap with AnimatedSwitcher ──
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              switchInCurve: Curves.easeIn,
              switchOutCurve: Curves.easeOut,
              child: Container(
                key: ValueKey(_currentPage),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(_pages[_currentPage]['image']!),
                    fit: BoxFit.cover,
                    // ── Opacity on background image ──────────────────
                    opacity: 0.55,
                  ),
                ),
              ),
            ),

            // Gradient overlay — darkens bottom for text legibility
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.4, 0.75, 1.0],
                  colors: [
                    Colors.black.withOpacity(0.15),
                    Colors.black.withOpacity(0.35),
                    Colors.black.withOpacity(0.55),
                    Colors.black.withOpacity(0.80),
                  ],
                ),
              ),
            ),

            // ── Centred text — fades + slides on each Next press ──────
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    FadeTransition(
                      opacity: _textFade,
                      child: SlideTransition(
                        position: _textSlide,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Title
                            Text(
                              _pages[_currentPage]['title']!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.3,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 18),
                            // Subtitle
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.28),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.12),
                                    width: 1),
                              ),
                              child: Text(
                                _pages[_currentPage]['subtitle']!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFFE2E8F0),
                                  height: 1.6,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Bottom controls ────────────────────────────────────────
            Positioned(
              bottom: 48,
              left: 28,
              right: 28,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Page indicator dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 7,
                        width: _currentPage == i ? 24 : 7,
                        decoration: BoxDecoration(
                          color: _currentPage == i
                              ? Colors.orange.shade600
                              : Colors.white.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  // Skip + Next row
                  Row(
                    children: [
                      if (!isLast)
                        TextButton(
                          onPressed: _toLogin,
                          child: Text(
                            'Skip',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: _next,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade700,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 36, vertical: 14),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isLast ? 'Get Started' : 'Next',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}
