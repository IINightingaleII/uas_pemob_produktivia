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

  Future<void> _navigateToNext() async {
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
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 1.0],
            colors: [
              Color(0xFF9183DE), // Stop 0% with 100% opacity
              Color(0xFFA094E3), // Stop 100% with 100% opacity
            ],
          ),
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

