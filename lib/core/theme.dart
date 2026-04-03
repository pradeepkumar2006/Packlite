import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PackLiteTheme {
  static const Color background = Color(0xFFF5F5F0);
  static const Color primary = Colors.black;
  static const Color cardBorder = Color(0xFFEEEEEE);
  static const Color mutedText = Color(0xFF999999);
  static const Color mutedText2 = Color(0xFFBBBBBB);
  static const Color error = Color(0xFFCC3333);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.white,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.black,
        brightness: Brightness.light,
      ),
      fontFamily: 'Inter', // Defaulting to a modern Sans Serif if Inter is not available
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w900,
        ),
        labelLarge: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w700,
        ),
        bodyMedium: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  static void haptic() {
    HapticFeedback.lightImpact();
  }
}

class Tappable extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;

  const Tappable({super.key, required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        PackLiteTheme.haptic();
        onTap();
      },
      child: child,
    );
  }
}
