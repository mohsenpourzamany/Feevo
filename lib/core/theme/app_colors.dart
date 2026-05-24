import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary
  static const Color purple = Color(0xFF7C3AED);
  static const Color purple2 = Color(0xFF9D5CF6);
  static const Color purple3 = Color(0xFFC4B5FD);

  // Accent
  static const Color cyan = Color(0xFF06B6D4);
  static const Color cyan2 = Color(0xFF22D3EE);
  static const Color cyan3 = Color(0xFFA5F3FC);

  // Background
  static const Color bg = Color(0xFF06060F);
  static const Color bg2 = Color(0xFF0A0A18);
  static const Color bg3 = Color(0xFF0F0F22);

  // Surface
  static const Color surface = Color(0x0DFFFFFF); // 5% white
  static const Color surface2 = Color(0x14FFFFFF); // 8% white

  // Border
  static const Color border = Color(0x12FFFFFF); // 7% white
  static const Color border2 = Color(0x667C3AED); // 40% purple

  // Text
  static const Color textPrimary = Color(0xFFEEEEFF);
  static const Color textSecond = Color(0xFF9896B8);
  static const Color textThird = Color(0xFF4A4868);

  // Status
  static const Color error = Color(0xFFF87171);
  static const Color errorBg = Color(0x1AEF4444);
  static const Color success = Color(0xFF4ADE80);
  static const Color successBg = Color(0x1A22C55E);
  static const Color warning = Color(0xFFFCD34D);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [purple, cyan],
  );

  static const LinearGradient purpleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [purple, purple2],
  );

  static const LinearGradient textGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), purple3, cyan2],
    stops: [0.1, 0.5, 0.9],
  );

  static const LinearGradient bgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF08061A), bg],
  );
}
