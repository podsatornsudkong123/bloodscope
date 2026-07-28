import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primary = Color(0xFF2BA89C);
  static const Color primaryDark = Color(0xFF1F8A80);
  static const Color primaryLight = Color(0xFFE8F5F3);
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color normal = Color(0xFF2BA89C);
  static const Color abnormal = Color(0xFFE57373);
  // สีเตือน/ข้อควรระวัง สำหรับ callout ใต้ขั้นตอนการใช้งาน
  static const Color warning = Color(0xFFF5A623);
  static const Color warningLight = Color(0xFFFDF4E3);
}

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
      ),
      textTheme: GoogleFonts.promptTextTheme(),
    );
  }
}