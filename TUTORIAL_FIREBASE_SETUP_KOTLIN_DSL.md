# Tutorial Lengkap: Setup Firebase (Kotlin DSL)

## Catatan Penting
Project ini menggunakan **Kotlin DSL** (`.kts`), bukan Groovy (`.gradle`). 
Tutorial ini khusus untuk project dengan Kotlin DSL.

---

## Langkah 1: Setup Firebase Console

### 1.1 Buat/Buka Firebase Project
1. Buka: https://console.firebase.google.com/
2. Login dengan Google
3. Klik **"Add project"** atau pilih project yang ada
4. Ikuti wizard untuk membuat project

### 1.2 Tambahkan Android App
1. Klik ikon **Android** atau **"Add app"**
2. Masukkan **Package name**:
   - Buka: `android/app/build.gradle.kts`
   - Cari: `applicationId = "com.example.uas_pemob"` (atau package name Anda)
   - Copy package name tersebut
3. **App nickname**: "Produktivia" (opsional)
4. Klik **"Register app"**

### 1.3 Download google-services.json
1. Download file `google-services.json`
2. Copy ke folder: `android/app/google-services.json`

### 1.4 Enable Authentication
1. Di Firebase Console: **Authentication** > **Sign-in method**
2. Klik **"Email/Password"**
3. Enable **"Email/Password"**
4. Klik **"Save"**

---

## Langkah 2: Install FlutterFire CLI

### Windows (PowerShell):
```powershell
dart pub global activate flutterfire_cli
```

### Mac/Linux:
```bash
dart pub global activate flutterfire_cli
```

### Verifikasi:
```bash
flutterfire --version
```

---

## Langkah 3: Konfigurasi Firebase

### 3.1 Login ke Firebase
```bash
firebase login
```

### 3.2 Konfigurasi FlutterFire
```bash
flutterfire configure
```

**Pilih:**
- Project Firebase Anda
- Platform: **Android** (spacebar untuk select, Enter untuk continue)

**Output yang diharapkan:**
```
✓ Firebase project selected
✓ Generated lib/firebase_options.dart
✓ Android configuration updated
```

---

## Langkah 4: Update File Android (Kotlin DSL)

### 4.1 Update android/build.gradle.kts

Buka `android/build.gradle.kts` dan pastikan ada:

```kotlin
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.1.0")
        classpath("com.google.gms:google-services:4.4.0") // TAMBAHKAN INI
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.0")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}
```

### 4.2 Update android/app/build.gradle.kts

Buka `android/app/build.gradle.kts` dan:

**Di bagian atas file, tambahkan:**
```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // TAMBAHKAN INI
}
```

**Atau jika menggunakan `apply plugin` (versi lama), tambahkan di bagian bawah:**
```kotlin
apply(plugin = "com.google.gms.google-services")
```

### 4.3 Pastikan google-services.json Ada

File harus ada di: `android/app/google-services.json`

---

## Langkah 5: Update main.dart

Buka `lib/main.dart` dan update menjadi:

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Import file yang di-generate
import 'package:google_fonts/google_fonts.dart';
import 'screens/splash_screen_0.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✓ Firebase initialized successfully');
  } catch (e) {
    debugPrint('✗ Firebase initialization failed: $e');
    debugPrint('Pastikan sudah menjalankan: flutterfire configure');
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
```

---

## Langkah 6: Clean dan Rebuild

```bash
flutter clean
flutter pub get
cd android
./gradlew clean
cd ..
flutter run
```

---

## Langkah 7: Testing

1. **Registrasi:**
   - Buka app
   - Klik "Create an Account"
   - Isi form dengan email yang valid
   - Klik "Create an Account"
   - Akan muncul Email Verification Screen

2. **Verifikasi Email:**
   - Cek email (termasuk spam)
   - Klik link verifikasi di email
   - Kembali ke app
   - Klik "I've Verified My Email"
   - Akan navigate ke Home Screen

3. **Login:**
   - Logout dari app
   - Klik "Log In"
   - Masukkan email dan password
   - Klik "Log In"
   - Jika email sudah verified → masuk ke Home Screen

---

## Troubleshooting

### Error: "google-services.json not found"
- Pastikan file ada di `android/app/google-services.json`
- Download ulang dari Firebase Console

### Error: "Plugin with id 'com.google.gms.google-services' not found"
- Pastikan `classpath("com.google.gms:google-services:4.4.0")` ada di `android/build.gradle.kts`
- Pastikan `id("com.google.gms.google-services")` ada di `android/app/build.gradle.kts`

### Error: "firebase_options.dart not found"
- Jalankan: `flutterfire configure`
- Pastikan file `lib/firebase_options.dart` sudah dibuat

### Error: "Package name mismatch"
- Cek package name di `android/app/build.gradle.kts` (applicationId)
- Pastikan sama dengan yang didaftarkan di Firebase Console

---

## Checklist

- [ ] Firebase project dibuat
- [ ] `google-services.json` di-copy ke `android/app/`
- [ ] `flutterfire configure` sudah dijalankan
- [ ] `firebase_options.dart` sudah dibuat
- [ ] `android/build.gradle.kts` sudah di-update
- [ ] `android/app/build.gradle.kts` sudah di-update
- [ ] `main.dart` sudah di-update
- [ ] Email/Password enabled di Firebase Console
- [ ] Sudah test registrasi dan verifikasi

---

## Selesai! 🎉

Setelah semua langkah selesai, aplikasi Anda sudah terintegrasi dengan Firebase!

