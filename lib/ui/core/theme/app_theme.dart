import 'package:flutter/material.dart';

/// iOS-styled colors and system typography/gradients
class AppColors {
  // Day / Light weather gradients
  static const List<Color> sunnyGradient = [
    Color(0xFF3A88E9),
    Color(0xFF67B0F0),
    Color(0xFF90CCF4),
  ];

  static const List<Color> cloudyGradient = [
    Color(0xFF5B6E80),
    Color(0xFF7E92A5),
    Color(0xFFA5B8C8),
  ];

  static const List<Color> rainyGradient = [
    Color(0xFF3D5166),
    Color(0xFF556F8A),
    Color(0xFF7691AD),
  ];

  static const List<Color> stormyGradient = [
    Color(0xFF2C3240),
    Color(0xFF454B5E),
    Color(0xFF61687E),
  ];

  static const List<Color> snowyGradient = [
    Color(0xFF7B94A8),
    Color(0xFF9CB5C7),
    Color(0xFFC0D5E3),
  ];

  // Night / Dark theme gradients
  static const List<Color> darkSunnyGradient = [
    Color(0xFF0B1426),
    Color(0xFF14243B),
    Color(0xFF1F3552),
  ];

  static const List<Color> darkCloudyGradient = [
    Color(0xFF161B22),
    Color(0xFF212936),
    Color(0xFF303A4B),
  ];

  static const List<Color> darkRainyGradient = [
    Color(0xFF111C28),
    Color(0xFF1C2C3D),
    Color(0xFF2B3F54),
  ];

  static const List<Color> darkStormyGradient = [
    Color(0xFF0C0E14),
    Color(0xFF171A24),
    Color(0xFF262A38),
  ];

  static const List<Color> darkSnowyGradient = [
    Color(0xFF141E28),
    Color(0xFF212E3C),
    Color(0xFF334354),
  ];

  // Default Night Gradient
  static const List<Color> nightGradient = darkSunnyGradient;

  // iOS Glassmorphism Card styling
  static Color glassCardBg = Colors.black.withValues(alpha: 0.18);
  static Color glassBorder = Colors.white.withValues(alpha: 0.18);
}

class AppTheme {
  static ThemeData get lightTheme => _buildIosTheme(Brightness.light);
  static ThemeData get darkTheme => _buildIosTheme(Brightness.dark);

  static ThemeData _buildIosTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: isDark ? const Color(0xFF080D14) : const Color(0xFF3A88E9),
      fontFamily: 'SF Pro Display',
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF3A88E9),
        brightness: brightness,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: -0.3,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDark
            ? Colors.black.withValues(alpha: 0.75)
            : const Color(0xFF1A3353).withValues(alpha: 0.65),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white.withValues(alpha: 0.5),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }

  /// Calculates dynamic background gradient taking into account Weather condition and ThemeMode
  static List<Color> getWeatherGradient(String weatherMain, bool isDay, {bool forceDark = false, bool forceLight = false}) {
    final condition = weatherMain.toLowerCase();
    final effectiveIsDark = forceDark ? true : (forceLight ? false : !isDay);

    if (effectiveIsDark) {
      return switch (condition) {
        'clear' => AppColors.darkSunnyGradient,
        'clouds' => AppColors.darkCloudyGradient,
        'rain' || 'drizzle' => AppColors.darkRainyGradient,
        'snow' => AppColors.darkSnowyGradient,
        'thunderstorm' => AppColors.darkStormyGradient,
        _ => AppColors.darkSunnyGradient,
      };
    } else {
      return switch (condition) {
        'clear' => AppColors.sunnyGradient,
        'clouds' => AppColors.cloudyGradient,
        'rain' || 'drizzle' => AppColors.rainyGradient,
        'snow' => AppColors.snowyGradient,
        'thunderstorm' => AppColors.stormyGradient,
        _ => AppColors.sunnyGradient,
      };
    }
  }
}
