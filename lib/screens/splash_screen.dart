import 'package:flutter/material.dart';
import '../utils/no_transition_route.dart';
import 'splash_screen_2.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Alignment> _alignmentAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _alignmentAnimation = Tween<Alignment>(
      begin: Alignment.center,
      end: Alignment.centerLeft,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _startAnimation();
  }

  void _startAnimation() async {
    // Start animation: center to bottom-left
    _controller.forward();

    // Wait for animation to complete, then add delay before navigating
    await Future.delayed(const Duration(milliseconds: 800));
    await Future.delayed(const Duration(milliseconds: 500)); // Additional delay

    if (!mounted) return;

    // Navigate to second splash screen with no transition for seamless icon positioning
    Navigator.of(context).pushReplacement(
      NoTransitionRoute(page: const SplashScreen2()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
        child: AnimatedBuilder(
          animation: _alignmentAnimation,
          builder: (context, child) {
            return Align(
              alignment: _alignmentAnimation.value,
              child: Padding(
                padding: const EdgeInsets.only(left: 24),
                child: child,
              ),
            );
          },
          child: Image.asset(
            'assets/icons/Produktivia.png',
            width: 60,
            height: 60,
            fit: BoxFit.contain,
            cacheWidth: 60,
            cacheHeight: 60,
          ),
        ),
      ),
    );
  }
}

