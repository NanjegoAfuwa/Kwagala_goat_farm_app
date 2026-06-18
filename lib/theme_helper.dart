import 'package:flutter/material.dart';

/// Theme helper for consistent dark/light mode colors across all screens
class AppTheme {
  static bool isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  // ─── Background Colors ───────────────────────────────────────────────
  static Color bg(BuildContext context) {
    return isDark(context) ? const Color(0xFF0F0F0F) : const Color(0xFFF8F9FA);
  }

  static Color bg2(BuildContext context) {
    return isDark(context) ? const Color(0xFF1A1A1A) : const Color(0xFFF0F4F0);
  }

  // ─── Card/Surface Colors ────────────────────────────────────────────
  static Color card(BuildContext context) {
    return isDark(context) ? const Color(0xFF1A1A1A) : Colors.white;
  }

  // ─── Text Colors ────────────────────────────────────────────────────
  static Color textDark(BuildContext context) {
    return isDark(context) ? Colors.white : const Color(0xFF0F172A);
  }

  static Color textMid(BuildContext context) {
    return isDark(context) ? Colors.white60 : const Color(0xFF475569);
  }

  static Color textLight(BuildContext context) {
    return isDark(context) ? Colors.white54 : const Color(0xFF94A3B8);
  }

  // ─── Input Field Colors ─────────────────────────────────────────────
  static Color inputFill(BuildContext context) {
    return isDark(context) ? const Color(0xFF1A1A1A) : Colors.white;
  }

  static Color inputBorder(BuildContext context) {
    return isDark(context) ? Colors.white12 : const Color(0xFFE2E8F0);
  }

  static Color inputText(BuildContext context) {
    return isDark(context) ? Colors.white : Colors.black;
  }

  // ─── Border/Divider Colors ──────────────────────────────────────────
  static Color border(BuildContext context) {
    return isDark(context) ? Colors.white.withOpacity(0.12) : const Color(0xFFE2E8F0);
  }

  static Color divider(BuildContext context) {
    return isDark(context) ? Colors.white.withOpacity(0.08) : const Color(0xFFF1F5F9);
  }

  // ─── Brand Colors (same in light/dark) ───────────────────────────────
  static const Color green = Color(0xFF2E7D32);
  static const Color orange = Color(0xFFF57C00);
  static const Color red = Color(0xFFDC2626);
  static const Color blue = Color(0xFF1D4ED8);

  // ─── Dropdown Colors ────────────────────────────────────────────────
  static Color dropdownBg(BuildContext context) {
    return isDark(context) ? const Color(0xFF1A1A1A) : Colors.white;
  }

  static Color dropdownText(BuildContext context) {
    return isDark(context) ? Colors.white : const Color(0xFF0F172A);
  }

  // ─── Helper: Transparent tint for containers ─────────────────────────
  static Color accentTint(BuildContext context) {
    return isDark(context) ? Colors.green.withOpacity(0.15) : Colors.green.shade50;
  }

  static Color orangeTint(BuildContext context) {
    return isDark(context) ? Colors.orange.withOpacity(0.15) : const Color(0xFFFFF7ED);
  }

  static Color purpleTint(BuildContext context) {
    return isDark(context) ? Colors.purple.withOpacity(0.15) : const Color(0xFFF5F3FF);
  }

  static Color redTint(BuildContext context) {
    return isDark(context) ? Colors.red.withOpacity(0.15) : Colors.red.shade50;
  }
}
