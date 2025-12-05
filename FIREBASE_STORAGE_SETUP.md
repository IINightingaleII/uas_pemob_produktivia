# Cara Mengaktifkan Firebase Storage

Error "Firebase Storage bucket is not configured" terjadi karena Firebase Storage belum diaktifkan di Firebase Console. Ikuti langkah-langkah berikut:

## Langkah 1: Buka Firebase Console

1. Buka browser dan kunjungi: https://console.firebase.google.com/
2. Login dengan akun Google Anda
3. Pilih project **produ-b6f42**

## Langkah 2: Aktifkan Firebase Storage

1. Di menu kiri, klik **Storage** (atau **Build** → **Storage**)
2. Jika belum pernah mengaktifkan Storage, Anda akan melihat tombol **"Get Started"**
3. Klik **"Get Started"**
4. Pilih mode Storage:
   - **Production mode** (disarankan untuk production)
   - **Test mode** (untuk testing, lebih permisif)
5. Pilih lokasi Storage (pilih yang terdekat dengan Anda, misalnya: **asia-southeast2** untuk Indonesia)
6. Klik **"Done"**

## Langkah 3: Konfigurasi Storage Rules

Setelah Storage aktif, Anda perlu mengatur Storage Rules:

1. Di halaman Storage, klik tab **"Rules"**
2. Hapus rules default yang ada
3. Salin dan tempel rules berikut:

### Rules untuk Production (Disarankan):

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Profile images - hanya user yang login bisa upload/read foto mereka sendiri
    match /profile_images/{fileName} {
      // User bisa read semua foto profil (untuk tampilan)
      allow read: if request.auth != null;
      // User hanya bisa write foto mereka sendiri (fileName harus sama dengan uid.jpg)
      allow write: if request.auth != null && 
                      fileName == request.auth.uid + '.jpg';
    }
    
    // Default: deny all other access
    match /{allPaths=**} {
      allow read, write: if false;
    }
  }
}
```

### Rules untuk Testing (Sementara):

Jika Anda ingin testing cepat, gunakan rules ini (TIDAK DISARANKAN untuk production):

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

4. Klik **"Publish"** untuk menyimpan rules

## Langkah 4: Verifikasi

Setelah rules disimpan, coba upload foto profil lagi di aplikasi. Error seharusnya sudah hilang.

## Penjelasan Rules

- **`/profile_images/{userId}.jpg`**: Path untuk foto profil user
  - **`allow read`**: Semua user yang login bisa melihat foto profil
  - **`allow write`**: Hanya user yang login bisa upload foto mereka sendiri (userId harus sama dengan uid)

- **`/{allPaths=**}`**: Semua path lainnya
  - **`allow read, write: if false`**: Tidak ada akses untuk path lainnya (security)

## Troubleshooting

### Error masih muncul setelah mengaktifkan Storage?

1. **Tunggu beberapa menit**: Setelah mengaktifkan Storage, tunggu 2-3 menit agar perubahan diterapkan
2. **Restart aplikasi**: Tutup dan buka kembali aplikasi Flutter
3. **Hot restart**: Di Flutter, tekan `R` (capital R) untuk hot restart
4. **Cek Storage Rules**: Pastikan rules sudah di-publish dengan benar

### Error "permission-denied"?

- Pastikan Storage Rules sudah dikonfigurasi dengan benar
- Pastikan user sudah login
- Pastikan userId di path sesuai dengan uid user yang login

### Error "bucket-not-found"?

- Pastikan Storage sudah diaktifkan di Firebase Console
- Pastikan `storageBucket` di `firebase_options.dart` sudah benar
- Cek di Firebase Console → Project Settings → General → Your apps → Android app

## Catatan Penting

⚠️ **Jangan gunakan test mode rules di production!** Rules test mode terlalu permisif dan tidak aman untuk aplikasi production.

✅ **Gunakan production mode rules** yang membatasi akses hanya untuk user yang login dan hanya untuk data mereka sendiri.

