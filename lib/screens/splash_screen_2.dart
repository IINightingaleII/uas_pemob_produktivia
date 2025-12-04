import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/dummy_auth_service.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class SplashScreen2 extends StatefulWidget {
  const SplashScreen2({super.key});

  @override
  State<SplashScreen2> createState() => _SplashScreen2State();
}

class _SplashScreen2State extends State<SplashScreen2>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  bool _showText = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));

    _startAnimation();
  }

  void _startAnimation() async {
    // Wait 5ms delay before starting animation
    await Future.delayed(const Duration(milliseconds: 5));
    
    if (!mounted) return;
    
    setState(() {
      _showText = true;
    });
    
    _controller.forward();
    
    // Wait for animation to complete, then add delay before navigating
    await Future.delayed(const Duration(milliseconds: 400));
    await Future.delayed(const Duration(milliseconds: 500)); // Additional delay
    
    if (!mounted) return;
    
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    // Check if user is already logged in
    final authService = DummyAuthService();
    final currentUser = authService.currentUser;

    if (currentUser != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
      return;
    }

    // Navigate to login screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
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
        child: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 24),
            child: Row(
              children: [
                // Icon without translucent box - stays at same position as SplashScreen
                Image.asset(
                  'assets/icons/Produktivia.png',
                  width: 60,
                  height: 60,
                  fit: BoxFit.contain,
                ),
                // Text that fades in
                if (_showText)
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Text(
                        'PRODUKTIVIA',
                        style: GoogleFonts.darkerGrotesque(
                          color: Colors.white,
                          fontSize: 42,
                          fontWeight: FontWeight.normal,
                          letterSpacing: 3.0,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

