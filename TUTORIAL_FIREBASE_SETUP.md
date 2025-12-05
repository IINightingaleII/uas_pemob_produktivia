# Tutorial Lengkap: Setup Firebase Authentication dengan Email Verification

## 📋 Daftar Isi
1. [Persiapan](#1-persiapan)
2. [Setup Firebase Console](#2-setup-firebase-console)
3. [Install FlutterFire CLI](#3-install-flutterfire-cli)
4. [Konfigurasi Firebase di Project](#4-konfigurasi-firebase-di-project)
5. [Update Kode](#5-update-kode)
6. [Testing](#6-testing)
7. [Troubleshooting](#7-troubleshooting)

---

## 1. Persiapan

### Yang Dibutuhkan:
- ✅ Akun Google (untuk Firebase Console)
- ✅ Flutter SDK sudah terinstall
- ✅ Project Flutter sudah dibuat
- ✅ Android Studio / VS Code
- ✅ Koneksi Internet

### Cek Versi Flutter:
```bash
flutter --version
```
Pastikan Flutter versi 3.0 atau lebih baru.

---

## 2. Setup Firebase Console

### Langkah 2.1: Buat/Buka Firebase Project

1. Buka browser dan kunjungi: https://console.firebase.google.com/
2. Login dengan akun Google Anda
3. Klik **"Add project"** atau pilih project yang sudah ada
4. Jika membuat project baru:
   - Masukkan nama project (contoh: "Produktivia")
   - Klik **"Continue"**
   - Pilih **"Enable Google Analytics"** (opsional, bisa skip)
   - Klik **"Create project"**
   - Tunggu sampai project dibuat (sekitar 1-2 menit)
   - Klik **"Continue"**

### Langkah 2.2: Tambahkan Android App ke Firebase

1. Di Firebase Console, klik ikon **Android** (ikon Android hijau) atau **"Add app"**
2. Masukkan **Android package name**:
   - Buka file: `android/app/build.gradle`
   - Cari baris `applicationId` (biasanya seperti: `com.example.uas_pemob`)
   - Copy package name tersebut
   - Paste ke Firebase Console
3. **App nickname** (opsional): "Produktivia Android"
4. **Debug signing certificate SHA-1** (opsional untuk sekarang, bisa skip)
5. Klik **"Register app"**

### Langkah 2.3: Download google-services.json

1. Setelah register app, Firebase akan memberikan file `google-services.json`
2. **Download file tersebut**
3. Copy file `google-services.json` ke folder:
   ```
   android/app/
   ```
   Jadi strukturnya menjadi:
   ```
   android/app/google-services.json
   ```

### Langkah 2.4: Enable Authentication

1. Di Firebase Console, klik menu **"Authentication"** di sidebar kiri
2. Klik tab **"Sign-in method"**
3. Klik **"Email/Password"**
4. Enable **"Email/Password"** (toggle ON)
5. **JANGAN** enable "Email link (passwordless sign-in)" untuk sekarang
6. Klik **"Save"**

### Langkah 2.5: (Opsional) Customize Email Template

1. Masih di **Authentication** > **Templates**
2. Klik **"Email address verification"**
3. Anda bisa customize:
   - Subject: "Verify your email for Produktivia"
   - Email body: Sesuaikan dengan kebutuhan
4. Klik **"Save"**

---

## 3. Install FlutterFire CLI

### Langkah 3.1: Install FlutterFire CLI

Buka terminal/command prompt di folder project Anda, lalu jalankan:

**Windows (PowerShell):**
```powershell
dart pub global activate flutterfire_cli
```

**Mac/Linux:**
```bash
dart pub global activate flutterfire_cli
```

### Langkah 3.2: Pastikan PATH Sudah Benar

**Windows:**
Pastikan folder ini ada di PATH:
```
C:\Users\<YourUsername>\AppData\Local\Pub\Cache\bin
```

**Mac/Linux:**
Pastikan folder ini ada di PATH:
```
~/.pub-cache/bin
```

### Langkah 3.3: Verifikasi Install

Jalankan:
```bash
flutterfire --version
```

Jika muncul versi, berarti sudah berhasil!

---

## 4. Konfigurasi Firebase di Project

### Langkah 4.1: Login ke Firebase

Jalankan di terminal (di folder project):
```bash
firebase login
```

Ini akan membuka browser untuk login. Setelah login, kembali ke terminal.

### Langkah 4.2: Konfigurasi FlutterFire

Jalankan:
```bash
flutterfire configure
```

**Proses yang akan terjadi:**
1. FlutterFire akan menampilkan daftar project Firebase Anda
2. Pilih project yang tadi dibuat (gunakan arrow keys, lalu Enter)
3. FlutterFire akan menampilkan platform yang tersedia (Android, iOS, Web)
4. Pilih **Android** (gunakan spacebar untuk select, lalu Enter)
5. FlutterFire akan:
   - Generate file `lib/firebase_options.dart`
   - Update file Android jika diperlukan
   - Konfigurasi selesai!

**Output yang diharapkan:**
```
✓ Firebase project 'your-project-name' selected
✓ Generated configuration file lib/firebase_options.dart successfully
✓ Android configuration updated successfully
```

### Langkah 4.3: Verifikasi File yang Dibuat

Pastikan file berikut ada:
- ✅ `lib/firebase_options.dart` (file baru)
- ✅ `android/app/google-services.json` (sudah di-copy sebelumnya)

---

## 5. Update Kode

### Langkah 5.1: Update main.dart

Buka file `lib/main.dart` dan update menjadi:

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Import file yang di-generate
import 'package:google_fonts/google_fonts.dart';
import 'screens/splash_screen_0.dart';

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

### Langkah 5.2: Update android/app/build.gradle

Buka file `android/app/build.gradle` dan pastikan ada:

**Di bagian atas file (dalam `buildscript`):**
```gradle
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:7.3.0'
        classpath 'com.google.gms:google-services:4.3.15' // Tambahkan ini
        // ... dependencies lainnya
    }
}
```

**Di bagian bawah file (setelah `dependencies`):**
```gradle
apply plugin: 'com.google.gms.google-services' // Tambahkan ini di baris terakhir
```

### Langkah 5.3: Update android/build.gradle

Buka file `android/build.gradle` dan pastikan ada:

```gradle
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:7.3.0'
        classpath 'com.google.gms:google-services:4.3.15'
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}
```

### Langkah 5.4: Update android/app/src/main/AndroidManifest.xml

Pastikan ada permission internet:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET"/>
    
    <application
        android:label="uas_pemob"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        <!-- ... -->
    </application>
</manifest>
```

---

## 6. Testing

### Langkah 6.1: Clean dan Rebuild Project

```bash
flutter clean
flutter pub get
```

### Langkah 6.2: Run App

```bash
flutter run
```

### Langkah 6.3: Test Flow Registrasi

1. **Buka app** → Akan muncul splash screen
2. **Klik "Create an Account"** atau navigasi ke onboarding screen
3. **Isi form registrasi:**
   - Name: Test User
   - Email: **gunakan email yang benar-benar bisa diakses** (contoh: email Anda sendiri)
   - Password: minimal 6 karakter
   - Confirm Password: sama dengan password
4. **Klik "Create an Account"**
5. **Tunggu beberapa detik** → Akan muncul Email Verification Screen
6. **Cek email Anda** (termasuk spam folder)
7. **Klik link verifikasi** di email
8. **Kembali ke app** → Klik tombol **"I've Verified My Email"**
9. **Jika berhasil** → Akan navigate ke Home Screen

### Langkah 6.4: Test Flow Login

1. **Logout** dari app (jika sudah login)
2. **Klik "Log In"**
3. **Masukkan email dan password** yang tadi didaftarkan
4. **Klik "Log In"**
5. **Jika email sudah verified** → Akan masuk ke Home Screen
6. **Jika email belum verified** → Akan muncul error message

---

## 7. Troubleshooting

### Error: "Firebase not initialized"

**Solusi:**
1. Pastikan `firebase_options.dart` sudah ada
2. Pastikan import `firebase_options.dart` di `main.dart`
3. Pastikan `DefaultFirebaseOptions.currentPlatform` digunakan
4. Run `flutter clean` dan `flutter pub get`

### Error: "google-services.json not found"

**Solusi:**
1. Pastikan file `google-services.json` ada di `android/app/`
2. Download ulang dari Firebase Console jika perlu
3. Pastikan package name di `google-services.json` sama dengan di `build.gradle`

### Error: "Email verification not working"

**Solusi:**
1. Cek email spam folder
2. Pastikan Email/Password enabled di Firebase Console
3. Cek Firebase Console > Authentication > Users untuk melihat status user
4. Coba resend verification email dari app

### Error: "Login failed - email not verified"

**Ini normal!** User harus verify email dulu sebelum bisa login.

**Solusi:**
1. Pastikan user sudah klik link verifikasi di email
2. Klik "I've Verified My Email" di Email Verification Screen
3. Atau resend verification email jika link expired

### Error: "Gradle build failed"

**Solusi:**
1. Pastikan `google-services` plugin sudah ditambahkan di `build.gradle`
2. Pastikan versi Google Services compatible:
   ```gradle
   classpath 'com.google.gms:google-services:4.3.15'
   ```
3. Run:
   ```bash
   cd android
   ./gradlew clean
   cd ..
   flutter clean
   flutter pub get
   ```

### Error: "Package name mismatch"

**Solusi:**
1. Cek package name di `android/app/build.gradle` (applicationId)
2. Pastikan sama dengan yang didaftarkan di Firebase Console
3. Jika berbeda, update di Firebase Console atau update di build.gradle

---

## 8. Checklist Final

Sebelum deploy, pastikan:

- [ ] Firebase project sudah dibuat
- [ ] `google-services.json` sudah di-copy ke `android/app/`
- [ ] `firebase_options.dart` sudah di-generate
- [ ] `main.dart` sudah di-update dengan Firebase initialization
- [ ] `build.gradle` sudah di-update dengan Google Services plugin
- [ ] Email/Password authentication sudah enabled di Firebase Console
- [ ] Sudah test registrasi dan verifikasi email
- [ ] Sudah test login dengan email verified
- [ ] Tidak ada error di console saat run app

---

## 9. Tips Tambahan

### Development vs Production

**Development:**
- Bisa menggunakan email apapun untuk testing
- Email verification link akan dikirim ke email tersebut

**Production:**
- Pastikan email template sudah di-customize
- Monitor usage di Firebase Console
- Setup billing jika diperlukan (ada free tier)

### Security Best Practices

1. **Jangan hardcode** API keys di kode
2. **Gunakan** Firebase Security Rules untuk Firestore
3. **Enable** App Check untuk production (opsional)
4. **Monitor** suspicious activity di Firebase Console

### Debugging

**Cek logs:**
```bash
flutter run --verbose
```

**Cek Firebase Console:**
- Authentication > Users: Lihat semua user yang terdaftar
- Authentication > Sign-in method: Cek konfigurasi
- Project Settings: Cek package name dan SHA-1

---

## 10. Bantuan Lebih Lanjut

Jika masih ada masalah:

1. **Cek dokumentasi resmi:**
   - https://firebase.google.com/docs/flutter/setup
   - https://firebase.google.com/docs/auth/flutter/start

2. **Cek error message** di terminal/console
3. **Cek Firebase Console** untuk melihat status
4. **Cek file konfigurasi** (google-services.json, firebase_options.dart)

---

## ✅ Selesai!

Setelah semua langkah di atas selesai, aplikasi Anda sudah terintegrasi dengan Firebase Authentication dan siap digunakan!

**Next Steps:**
- Test semua flow (registrasi, verifikasi, login)
- Customize email template jika perlu
- Setup Firestore untuk menyimpan data user (jika diperlukan)

