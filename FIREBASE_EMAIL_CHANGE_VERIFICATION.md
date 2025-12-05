# Konfigurasi Email Verification untuk Change Email

Jika email verifikasi tidak dikirim saat mengganti email di Change Profile, ikuti langkah-langkah berikut:

## 1. Periksa Email Template di Firebase Console

1. Buka **Firebase Console**: https://console.firebase.google.com/
2. Pilih project **produ-b6f42**
3. Klik **Authentication** di menu kiri
4. Klik tab **Templates** (atau **Email templates**)
5. Pastikan template berikut aktif:
   - **Email address change** (untuk `verifyBeforeUpdateEmail`)
   - **Email verification** (untuk verifikasi email baru)

## 2. Konfigurasi Email Template untuk Email Change

1. Di halaman **Templates**, cari template **"Email address change"**
2. Klik template tersebut untuk mengedit
3. Pastikan:
   - **Subject**: Sesuaikan dengan kebutuhan (contoh: "Verify your new email address")
   - **Body**: Pastikan link verifikasi ada di template
   - **Action URL**: Pastikan URL mengarah ke aplikasi atau web app Anda

## 3. Aktifkan Email Provider

1. Di Firebase Console → **Authentication** → **Settings**
2. Klik tab **Authorized domains**
3. Pastikan domain email Anda diizinkan (untuk development, `localhost` biasanya sudah diizinkan)

## 4. Periksa Email Provider Settings

1. Di Firebase Console → **Authentication** → **Settings**
2. Klik tab **Users**
3. Pastikan **Email/Password** provider aktif

## 5. Testing Email Verification

Setelah mengubah email di Change Profile:

1. **Cek inbox email baru** (bukan email lama)
2. **Cek folder Spam/Junk** - email verifikasi kadang masuk ke spam
3. **Tunggu beberapa menit** - email mungkin butuh waktu untuk sampai
4. **Cek email provider** - beberapa provider (seperti Gmail) mungkin delay

## 6. Troubleshooting

### Email tidak diterima?

1. **Cek Firebase Console → Authentication → Users**
   - Cari user Anda
   - Lihat apakah email sudah berubah atau masih pending

2. **Cek Logs di Firebase Console**
   - Buka **Firebase Console → Functions → Logs** (jika menggunakan Cloud Functions)
   - Atau cek log aplikasi untuk error messages

3. **Cek Email Template Configuration**
   - Pastikan template "Email address change" aktif
   - Pastikan action URL benar

4. **Cek Rate Limiting**
   - Firebase membatasi jumlah email yang dikirim
   - Jika terlalu banyak request, tunggu beberapa menit

### Error "requires-recent-login"?

Jika mendapat error ini:
1. User perlu **sign out** dan **sign in** lagi
2. Atau implementasikan **re-authentication** sebelum change email

### Email dikirim ke email lama?

- `verifyBeforeUpdateEmail` seharusnya mengirim email ke **email baru**
- Jika masih dikirim ke email lama, kemungkinan ada bug di Firebase atau konfigurasi salah
- Cek di Firebase Console apakah email benar-benar berubah

## 7. Manual Verification (Alternatif)

Jika email verifikasi tidak bekerja, Anda bisa verifikasi manual:

1. Buka **Firebase Console → Authentication → Users**
2. Cari user yang ingin diverifikasi
3. Klik user tersebut
4. Di bagian **Email**, klik **Verify** (jika tersedia)

**Catatan**: Manual verification hanya untuk testing. Di production, user harus verifikasi sendiri melalui email.

## 8. Best Practices

1. **Selalu cek error message** - Aplikasi sekarang akan menampilkan error yang jelas jika gagal
2. **Berikan feedback ke user** - Aplikasi akan memberitahu user untuk cek email baru
3. **Handle error dengan baik** - Jangan biarkan user bingung jika ada error

## 9. Kode yang Diperbaiki

Aplikasi sekarang:
- ✅ Menangani error dengan benar (tidak diabaikan)
- ✅ Memberikan pesan error yang jelas
- ✅ Memberitahu user untuk cek email baru (bukan email lama)
- ✅ Memberitahu user untuk cek folder spam

## 10. Verifikasi Email Template Format

Template email change biasanya memiliki format seperti ini:

```
Subject: Verify your new email address

Hi,

You requested to change your email address to: [NEW_EMAIL]

Please click the link below to verify your new email address:
[VERIFICATION_LINK]

If you didn't request this change, please ignore this email.

Thanks,
Your App Team
```

Pastikan template di Firebase Console memiliki format yang benar dengan link verifikasi.

