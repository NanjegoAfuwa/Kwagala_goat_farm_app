import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Screens/splash_screen.dart';
import 'Screens/goat_records.dart';
import 'Screens/add_goat.dart';
import 'Screens/analytics_screen.dart';
import 'Screens/settings_screen.dart';
import 'Screens/Auth/login_screen.dart';
import 'Screens/Auth/register_screen.dart';
import 'Screens/Auth/forgot_password_screen.dart';
import 'Widgets/bottom_nav.dart';

/// Global theme mode — toggling dark mode updates every screen instantly
final ValueNotifier<ThemeMode> appThemeNotifier =
    ValueNotifier(ThemeMode.light);

/// Global text scale — changing font size updates every screen instantly
final ValueNotifier<double> appTextScaleNotifier = ValueNotifier(1.0);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  // Restore dark mode
  final isDark = prefs.getBool('dark_mode') ?? false;
  appThemeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;

  // Restore text scale
  final savedScale = prefs.getString('text_scale') ?? 'Normal (100%)';
  appTextScaleNotifier.value = scaleFromLabel(savedScale);

  runApp(const KwagalaFarmApp());
}

double scaleFromLabel(String label) {
  if (label.contains('85'))  return 0.85;
  if (label.contains('115')) return 1.15;
  if (label.contains('130')) return 1.30;
  return 1.0;
}

class KwagalaFarmApp extends StatelessWidget {
  const KwagalaFarmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeNotifier,
      builder: (_, themeMode, __) =>
          ValueListenableBuilder<double>(
            valueListenable: appTextScaleNotifier,
            builder: (_, scale, __) => MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Kwagala Goat Farm',

              // Apply text scale factor to the entire app
              builder: (ctx, child) => MediaQuery(
                data: MediaQuery.of(ctx)
                    .copyWith(textScaler: TextScaler.linear(scale)),
                child: child!,
              ),

              // ── Light theme ──────────────────────────────────────────
              theme: ThemeData(
                brightness: Brightness.light,
                colorScheme: ColorScheme.fromSeed(
                    seedColor: const Color(0xFF2E7D32)),
                scaffoldBackgroundColor: const Color(0xFFF8F9FA),
                cardColor: Colors.white,
                dividerColor: const Color(0xFFE2E8F0),
                useMaterial3: false,
              ),

              // ── Dark theme ───────────────────────────────────────────
              darkTheme: ThemeData(
                brightness: Brightness.dark,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: const Color(0xFF4CAF50),
                  brightness: Brightness.dark,
                ),
                scaffoldBackgroundColor: const Color(0xFF0F0F0F),
                canvasColor: const Color(0xFF121212),
                cardColor: const Color(0xFF1A1A1A),
                dialogBackgroundColor: const Color(0xFF1A1A1A),
                bottomSheetTheme: const BottomSheetThemeData(
                  backgroundColor: Color(0xFF121212),
                ),
                dividerColor: Colors.white12,
                appBarTheme: const AppBarTheme(
                  backgroundColor: Color(0xFF1B5E20),
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
                inputDecorationTheme: InputDecorationTheme(
                  filled: true,
                  fillColor: const Color(0xFF1A1A1A),
                  hintStyle: const TextStyle(color: Colors.white54),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.white12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.white12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Color(0xFF4CAF50), width: 1.5),
                  ),
                ),
                dropdownMenuTheme: const DropdownMenuThemeData(),
                textTheme: Typography.whiteMountainView,
                useMaterial3: false,
              ),

              themeMode: themeMode,
              home: const SplashScreen(),
              routes: {
                '/home':            (_) => const BottomNav(),
                '/goats':           (_) => const GoatsScreen(),
                '/add-goat':        (_) => const AddGoatScreen(),
                '/analytics':       (_) => const AnalyticsScreen(),
                '/settings':        (_) => const SettingsScreen(),
                '/login':           (_) => const LoginScreen(),
                '/register':        (_) => const RegisterScreen(),
                '/forgot-password': (_) => const ForgotPasswordScreen(),
              },
            ),
          ),
    );
  }
}
