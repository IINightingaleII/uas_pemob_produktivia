import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/splash_screen_0.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase (optional - app will still run if Firebase isn't configured)
  // Note: After running 'flutterfire configure', uncomment the lines below
  // and import: import 'firebase_options.dart';
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  try {
    await Firebase.initializeApp();
  } catch (e) {
    // Firebase not configured yet - app will still run but auth won't work
    debugPrint('Firebase not initialized: $e');
    debugPrint('To enable authentication, run: flutterfire configure');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Produktivia',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        // Apply Inter font to all text styles
        textTheme: GoogleFonts.interTextTheme(),
      ),
      home: const SplashScreen0(),
    );
  }
}
