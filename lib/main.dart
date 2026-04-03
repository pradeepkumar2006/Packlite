import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'splash/splash_screen.dart';
import 'core/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const PackLiteApp());
}

class PackLiteApp extends StatelessWidget {
  const PackLiteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PACKLITE',
      theme: PackLiteTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
