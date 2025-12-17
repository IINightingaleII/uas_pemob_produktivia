# 🚀 Quick Start: Firebase Setup (5 Menit)

## Langkah Cepat

### 1️⃣ Firebase Console (2 menit)
1. Buka: https://console.firebase.google.com/
2. Buat project baru atau pilih yang ada
3. Klik ikon **Android** → Masukkan package name: `com.example.uas_pemob`
4. Download `google-services.json` → Copy ke `android/app/`
5. **Authentication** > **Sign-in method** > Enable **Email/Password**

### 2️⃣ Install & Configure (2 menit)
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Login ke Firebase
firebase login

# Konfigurasi project
flutterfire configure
# Pilih project → Pilih Android → Enter
```

### 3️⃣ Update Kode (1 menit)

**File: `lib/main.dart`**
- Uncomment import: `import 'firebase_options.dart';`
- Uncomment Firebase initialization dengan `DefaultFirebaseOptions.currentPlatform`

**File: `android/settings.gradle.kts`**
- Sudah di-update otomatis ✅

**File: `android/app/build.gradle.kts`**
- Sudah di-update otomatis ✅

### 4️⃣ Run
```bash
flutter clean
flutter pub get
flutter run
```

### 5️⃣ Test
1. Registrasi dengan email valid
2. Cek email untuk verifikasi
3. Klik link verifikasi
4. Klik "I've Verified My Email" di app
5. Login dengan email yang sudah verified

---

## ✅ Selesai!

Lihat `TUTORIAL_FIREBASE_STEP_BY_STEP.md` untuk tutorial lengkap.

