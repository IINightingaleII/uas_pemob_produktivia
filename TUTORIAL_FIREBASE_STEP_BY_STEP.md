# 📚 Tutorial Step-by-Step: Setup Firebase Authentication

## 🎯 Tujuan
Mengintegrasikan Firebase Authentication dengan Email Verification ke aplikasi Produktivia.

---

## 📋 STEP 1: Persiapan Firebase Console

### 1.1 Buka Firebase Console
1. Buka browser: https://console.firebase.google.com/
2. Login dengan akun Google Anda

### 1.2 Buat Project Baru
1. Klik **"Add project"** (atau pilih project yang sudah ada)
2. Masukkan nama project: **"Produktivia"** (atau nama lain)
3. Klik **"Continue"**
4. **Opsional**: Enable Google Analytics (bisa skip)
5. Klik **"Create project"**
6. Tunggu sampai selesai (sekitar 1-2 menit)
7. Klik **"Continue"**

### 1.3 Tambahkan Android App
1. Di halaman project, klik ikon **Android** (ikon Android hijau)
2. **Package name**: Masukkan `com.example.uas_pemob`
   - (Ini adalah package name dari project Anda)
3. **App nickname**: "Produktivia" (opsional)
4. **Debug signing certificate SHA-1**: **SKIP** untuk sekarang
5. Klik **"Register app"**

### 1.4 Download google-services.json
1. Setelah register, akan muncul tombol **"Download google-services.json"**
2. **Klik tombol tersebut** untuk download
3. **Copy file** `google-services.json` yang sudah didownload
4. **Paste ke folder**: `android/app/`
   - Jadi file harus ada di: `android/app/google-services.json`

### 1.5 Enable Email/Password Authentication
1. Di sidebar kiri, klik **"Authentication"**
2. Klik tab **"Sign-in method"**
3. Klik **"Email/Password"**
4. **Enable** toggle untuk "Email/Password" (ON)
5. **JANGAN** enable "Email link (passwordless sign-in)"
6. Klik **"Save"**

✅ **Checklist Step 1:**
- [ ] Firebase project sudah dibuat
- [ ] Android app sudah ditambahkan
- [ ] `google-services.json` sudah di-download dan di-copy ke `android/app/`
- [ ] Email/Password authentication sudah enabled

---

## 📋 STEP 2: Install FlutterFire CLI

### 2.1 Buka Terminal/Command Prompt
Buka terminal di folder project Anda:
```
C:\Users\Legion\StudioProjects\uas_pemob
```

### 2.2 Install FlutterFire CLI

**Windows (PowerShell):**
```powershell
dart pub global activate flutterfire_cli
```

**Mac/Linux:**
```bash
dart pub global activate flutterfire_cli
```

### 2.3 Verifikasi Install
```bash
flutterfire --version
```

Jika muncul versi (contoh: `flutterfire_cli 0.x.x`), berarti berhasil!

✅ **Checklist Step 2:**
- [ ] FlutterFire CLI sudah terinstall
- [ ] Command `flutterfire --version` berhasil

---

## 📋 STEP 3: Konfigurasi Firebase di Project

### 3.1 Login ke Firebase
Di terminal, jalankan:
```bash
firebase login
```

Ini akan membuka browser untuk login. Setelah login, kembali ke terminal.

### 3.2 Jalankan FlutterFire Configure
```bash
flutterfire configure
```

**Proses yang terjadi:**
1. FlutterFire akan menampilkan daftar project Firebase
2. **Pilih project** yang tadi dibuat (gunakan arrow keys ↑↓, lalu Enter)
3. FlutterFire akan menampilkan platform (Android, iOS, Web)
4. **Pilih Android** (gunakan spacebar untuk select, lalu Enter)
5. Tunggu sampai selesai

**Output yang diharapkan:**
```
✓ Firebase project 'Produktivia' selected
✓ Generated configuration file lib/firebase_options.dart successfully
✓ Android configuration updated successfully
```

### 3.3 Verifikasi File yang Dibuat
Pastikan file berikut ada:
- ✅ `lib/firebase_options.dart` (file baru, di-generate otomatis)
- ✅ `android/app/google-services.json` (sudah di-copy sebelumnya)

✅ **Checklist Step 3:**
- [ ] `firebase login` berhasil
- [ ] `flutterfire configure` berhasil
- [ ] File `lib/firebase_options.dart` sudah dibuat
- [ ] File `android/app/google-services.json` sudah ada

---

## 📋 STEP 4: Update File Android (Kotlin DSL)

### 4.1 Update android/settings.gradle.kts

Buka file `android/settings.gradle.kts` dan cari bagian `pluginManagement`:

**Tambahkan di bagian `pluginManagement` > `repositories`:**
```kotlin
pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}
```

**Tambahkan di bagian `pluginManagement` > `plugins`:**
```kotlin
plugins {
    id("com.google.gms.google-services") version "4.4.0" apply false
}
```

### 4.2 Update android/app/build.gradle.kts

Buka file `android/app/build.gradle.kts` dan:

**Di bagian `plugins`, tambahkan:**
```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // TAMBAHKAN BARIS INI
}
```

**File lengkapnya akan seperti ini:**
```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // BARIS INI
}

android {
    // ... rest of the file
}
```

✅ **Checklist Step 4:**
- [ ] `android/settings.gradle.kts` sudah di-update
- [ ] `android/app/build.gradle.kts` sudah di-update dengan plugin Google Services

---

## 📋 STEP 5: Update main.dart

### 5.1 Buka lib/main.dart

### 5.2 Update Import
**Ubah dari:**
```dart
import 'package:firebase_core/firebase_core.dart';
```

**Menjadi:**
```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // TAMBAHKAN BARIS INI
```

### 5.3 Update Firebase Initialization
**Ubah dari:**
```dart
try {
    await Firebase.initializeApp();
} catch (e) {
    debugPrint('Firebase not initialized: $e');
}
```

**Menjadi:**
```dart
try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✓ Firebase initialized successfully');
} catch (e) {
    debugPrint('✗ Firebase initialization failed: $e');
    debugPrint('Pastikan sudah menjalankan: flutterfire configure');
}
```

**File `main.dart` lengkap:**
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

✅ **Checklist Step 5:**
- [ ] Import `firebase_options.dart` sudah ditambahkan
- [ ] Firebase initialization sudah di-update dengan `DefaultFirebaseOptions.currentPlatform`

---

## 📋 STEP 6: Clean dan Rebuild Project

### 6.1 Clean Project
```bash
flutter clean
```

### 6.2 Get Dependencies
```bash
flutter pub get
```

### 6.3 Clean Android Build
```bash
cd android
./gradlew clean
cd ..
```

### 6.4 Run App
```bash
flutter run
```

✅ **Checklist Step 6:**
- [ ] `flutter clean` berhasil
- [ ] `flutter pub get` berhasil
- [ ] `./gradlew clean` berhasil
- [ ] App bisa di-run tanpa error

---

## 📋 STEP 7: Testing

### 7.1 Test Registrasi
1. **Buka app** di emulator/device
2. **Navigasi ke Onboarding Screen** (Create Account)
3. **Isi form:**
   - Name: Test User
   - Email: **gunakan email yang benar-benar bisa diakses**
   - Password: minimal 6 karakter (contoh: `123456`)
   - Confirm Password: sama dengan password
4. **Klik "Create an Account"**
5. **Tunggu beberapa detik**
6. **Akan muncul Email Verification Screen** ✅

### 7.2 Test Email Verification
1. **Cek email Anda** (termasuk folder spam)
2. **Cari email dari Firebase** (subject: "Verify your email")
3. **Klik link verifikasi** di email
4. **Browser akan membuka** dan menampilkan "Email verified"
5. **Kembali ke app**
6. **Klik tombol "I've Verified My Email"**
7. **Akan navigate ke Home Screen** ✅

### 7.3 Test Login
1. **Logout** dari app (jika sudah login)
2. **Klik "Log In"**
3. **Masukkan email dan password** yang tadi didaftarkan
4. **Klik "Log In"**
5. **Jika email sudah verified** → Akan masuk ke Home Screen ✅
6. **Jika email belum verified** → Akan muncul error message

✅ **Checklist Step 7:**
- [ ] Registrasi berhasil
- [ ] Email verification diterima
- [ ] Link verifikasi berfungsi
- [ ] Login berhasil setelah verifikasi

---

## 🐛 Troubleshooting

### Error: "firebase_options.dart not found"
**Solusi:**
1. Pastikan sudah menjalankan `flutterfire configure`
2. Cek apakah file `lib/firebase_options.dart` ada
3. Jika tidak ada, jalankan lagi: `flutterfire configure`

### Error: "google-services.json not found"
**Solusi:**
1. Pastikan file ada di `android/app/google-services.json`
2. Download ulang dari Firebase Console jika perlu
3. Pastikan package name di `google-services.json` sama dengan di `build.gradle.kts`

### Error: "Plugin with id 'com.google.gms.google-services' not found"
**Solusi:**
1. Pastikan di `android/settings.gradle.kts` ada:
   ```kotlin
   plugins {
       id("com.google.gms.google-services") version "4.4.0" apply false
   }
   ```
2. Pastikan di `android/app/build.gradle.kts` ada:
   ```kotlin
   plugins {
       id("com.google.gms.google-services")
   }
   ```

### Error: "Email verification not working"
**Solusi:**
1. Cek email spam folder
2. Pastikan Email/Password enabled di Firebase Console
3. Cek Firebase Console > Authentication > Users untuk melihat status
4. Coba resend verification email dari app

### Error: "Login failed - email not verified"
**Ini normal!** User harus verify email dulu.

**Solusi:**
1. Pastikan user sudah klik link verifikasi di email
2. Klik "I've Verified My Email" di Email Verification Screen
3. Atau resend verification email jika link expired

---

## ✅ Final Checklist

Sebelum selesai, pastikan semua sudah dilakukan:

- [ ] Firebase project dibuat
- [ ] Android app ditambahkan ke Firebase
- [ ] `google-services.json` di-copy ke `android/app/`
- [ ] Email/Password enabled di Firebase Console
- [ ] FlutterFire CLI terinstall
- [ ] `flutterfire configure` sudah dijalankan
- [ ] `firebase_options.dart` sudah dibuat
- [ ] `android/settings.gradle.kts` sudah di-update
- [ ] `android/app/build.gradle.kts` sudah di-update
- [ ] `main.dart` sudah di-update
- [ ] Project sudah di-clean dan rebuild
- [ ] App bisa di-run tanpa error
- [ ] Registrasi berhasil
- [ ] Email verification berfungsi
- [ ] Login berfungsi

---

## 🎉 Selesai!

Jika semua checklist sudah ✅, berarti Firebase Authentication sudah berhasil diintegrasikan!

**Next Steps:**
- Test semua flow (registrasi, verifikasi, login)
- Customize email template di Firebase Console jika perlu
- Monitor usage di Firebase Console

---

## 📞 Bantuan

Jika masih ada masalah:
1. Cek error message di terminal/console
2. Cek Firebase Console untuk melihat status
3. Pastikan semua file konfigurasi sudah benar
4. Coba clean dan rebuild lagi

**File yang penting:**
- `lib/firebase_options.dart` (harus ada)
- `android/app/google-services.json` (harus ada)
- `android/app/build.gradle.kts` (harus ada plugin Google Services)
- `lib/main.dart` (harus import firebase_options)

