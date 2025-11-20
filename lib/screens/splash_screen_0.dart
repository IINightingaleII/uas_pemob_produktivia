import 'package:flutter/material.dart';
import '../utils/page_routes.dart';
import 'splash_screen.dart';

class SplashScreen0 extends StatefulWidget {
  const SplashScreen0({super.key});

  @override
  State<SplashScreen0> createState() => _SplashScreen0State();
}

class _SplashScreen0State extends State<SplashScreen0> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  _navigateToNext() async {
    // First splash duration: 1500ms (static display)
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    // Navigate to second splash screen with fast fade transition
    Navigator.of(context).pushReplacement(
      FadePageRoute(page: const SplashScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFDDA0DD), // Light purple background
        ),
        child: Center(
          child: Image.asset(
            'assets/icons/Produktivia.png',
            width: 60,
            height: 60,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

