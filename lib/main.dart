import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Import file yang di-generate
import 'package:google_fonts/google_fonts.dart';
import 'package:timezone/timezone.dart' as tz;
import 'screens/splash_screen_0.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase dengan options dari firebase_options.dart
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✓ Firebase initialized successfully');
  } catch (e) {
    print('✗ Firebase initialization failed: $e');
    // App akan tetap jalan, tapi auth tidak akan berfungsi
  }
  
  // Initialize Notification Service
  try {
    await NotificationService().initialize();
    print('✓ Notification service initialized successfully');
    
    // AUTO TEST: Show immediate notification
    print('\n🧪 AUTO TEST: Showing immediate notification in 2 seconds...');
    Future.delayed(const Duration(seconds: 2), () async {
      try {
        await NotificationService().showTestNotification();
      } catch (e) {
        print('Test notification error: $e');
      }
    });
    
    // AUTO TEST: Schedule 3 sequential notifications to prove scheduling works!
    print('🧪 AUTO TEST: Scheduling 3 sequential test notifications...');
    print('   📅 Test 1: 30 seconds from now');
    print('   📅 Test 2: 1 minute from now');
    print('   📅 Test 3: 2 minutes from now');
    
    Future.delayed(const Duration(seconds: 3), () async {
      try {
        final notifService = NotificationService();
        final now = tz.TZDateTime.now(tz.local);
        
        // Test 1: 30 seconds
        final time1 = now.add(const Duration(seconds: 30));
        await notifService.scheduleTestNotification(
          id: 777771,
          title: '🧪 TEST #1',
          body: 'Scheduled for 30 seconds - Time: ${time1.hour}:${time1.minute}:${time1.second}',
          scheduledTime: time1,
        );
        
        // Test 2: 1 minute
        final time2 = now.add(const Duration(minutes: 1));
        await notifService.scheduleTestNotification(
          id: 777772,
          title: '🧪 TEST #2',
          body: 'Scheduled for 1 minute - Time: ${time2.hour}:${time2.minute}:${time2.second}',
          scheduledTime: time2,
        );
        
        // Test 3: 2 minutes
        final time3 = now.add(const Duration(minutes: 2));
        await notifService.scheduleTestNotification(
          id: 777773,
          title: '🧪 TEST #3',
          body: 'Scheduled for 2 minutes - Time: ${time3.hour}:${time3.minute}:${time3.second}',
          scheduledTime: time3,
        );
        
        print('✅ All 3 test notifications scheduled!');
        print('   Watch for them at:');
        print('   - ${time1.hour}:${time1.minute}:${time1.second}');
        print('   - ${time2.hour}:${time2.minute}:${time2.second}');
        print('   - ${time3.hour}:${time3.minute}:${time3.second}');
      } catch (e) {
        print('Sequential test notification error: $e');
      }
    });
    
  } catch (e) {
    print('✗ Notification service initialization failed: $e');
    // App akan tetap jalan, tapi notifikasi tidak akan berfungsi
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
        textTheme: GoogleFonts.interTextTheme(),
      ),
      home: const SplashScreen0(),
    );
  }
}
