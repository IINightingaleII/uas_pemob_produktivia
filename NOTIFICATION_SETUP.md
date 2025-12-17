# Setup Notifikasi untuk Task

Dokumen ini menjelaskan sistem notifikasi yang telah diimplementasikan untuk task reminders.

## Fitur Notifikasi

### 1. **Automatic Scheduling**
- Notifikasi otomatis di-schedule saat task ditambahkan
- Notifikasi di-update saat task di-edit
- Notifikasi di-cancel saat task dihapus atau diselesaikan

### 2. **Smart Notification Time**
- Menggunakan `alarmTime` jika tersedia
- Fallback ke `time` jika `alarmTime` tidak ada
- Tidak akan schedule notifikasi untuk waktu di masa lalu

### 3. **Task Completion Handling**
- Notifikasi otomatis di-cancel saat task diselesaikan
- Notifikasi di-schedule kembali saat task di-uncomplete

## Package yang Digunakan

1. **flutter_local_notifications** (^17.2.3)
   - Untuk local notifications di Android dan iOS

2. **timezone** (^0.9.4)
   - Untuk timezone-aware scheduling
   - Menggunakan timezone 'Asia/Jakarta' (bisa disesuaikan)

## Konfigurasi Android

### AndroidManifest.xml
Permission berikut sudah ditambahkan:
```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.USE_EXACT_ALARM"/>
```

### Android 13+ (API 33+)
- Permission `POST_NOTIFICATIONS` akan diminta otomatis saat app pertama kali dibuka
- User perlu mengizinkan notifikasi untuk fitur ini bekerja

## Cara Kerja

### 1. **Saat Task Ditambahkan**
```dart
// Di TaskService.addTask()
await _notificationService.scheduleTaskNotification(task);
```

### 2. **Saat Task Di-update**
```dart
// Di TaskService.updateTask()
await _notificationService.updateTaskNotification(task);
// - Cancel notifikasi lama
// - Schedule notifikasi baru (jika task belum selesai)
```

### 3. **Saat Task Dihapus**
```dart
// Di TaskService.deleteTask()
await _notificationService.cancelTaskNotification(taskId);
```

### 4. **Saat Task Diselesaikan/Uncomplete**
```dart
// Di TaskService.toggleTaskCompletion()
if (completed) {
  await _notificationService.cancelTaskNotification(task.id);
} else {
  await _notificationService.scheduleTaskNotification(task);
}
```

### 5. **Saat App Dibuka**
```dart
// Di HomeScreen.initState()
// Schedule semua notifikasi untuk tasks yang aktif
notificationService.scheduleAllTaskNotifications(tasks);
```

## Format Notifikasi

- **Title**: Nama task
- **Body**: "Task scheduled at [HH:mm]"
- **Sound**: Enabled
- **Vibration**: Enabled
- **Priority**: High

## Timezone

Default timezone: **Asia/Jakarta**

Untuk mengubah timezone, edit di `lib/services/notification_service.dart`:
```dart
tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
```

## Testing

### 1. **Test Notifikasi**
1. Tambahkan task dengan tanggal dan waktu di masa depan
2. Tunggu sampai waktu notifikasi
3. Notifikasi seharusnya muncul

### 2. **Test Cancel Notifikasi**
1. Tambahkan task dengan notifikasi
2. Hapus atau selesaikan task
3. Notifikasi seharusnya di-cancel

### 3. **Test Update Notifikasi**
1. Tambahkan task dengan notifikasi
2. Edit waktu task
3. Notifikasi lama di-cancel, notifikasi baru di-schedule

## Troubleshooting

### Notifikasi tidak muncul?

1. **Cek Permission**
   - Pastikan permission notifikasi sudah diberikan
   - Untuk Android 13+, cek di Settings → Apps → Produktivia → Notifications

2. **Cek Waktu**
   - Pastikan waktu notifikasi di masa depan
   - Notifikasi tidak akan di-schedule untuk waktu di masa lalu

3. **Cek Task Status**
   - Pastikan task belum selesai (`isCompleted = false`)
   - Pastikan task memiliki `date` yang valid

4. **Cek Logs**
   - Cek console untuk error messages
   - Pastikan NotificationService sudah di-initialize

### Notifikasi muncul tapi tidak tepat waktu?

1. **Cek Timezone**
   - Pastikan timezone sudah benar
   - Default: Asia/Jakarta

2. **Cek Device Time**
   - Pastikan waktu device sudah benar
   - Notifikasi menggunakan waktu device

### Notifikasi tidak di-cancel?

1. **Cek Task ID**
   - Pastikan task ID konsisten
   - Notification ID menggunakan hash dari task ID

2. **Cek Logs**
   - Cek console untuk error messages
   - Pastikan cancelTaskNotification dipanggil

## Best Practices

1. **Initialize di Main**
   - NotificationService di-initialize di `main()` sebelum `runApp()`

2. **Schedule di HomeScreen**
   - Schedule semua notifikasi saat tasks di-load di HomeScreen

3. **Update saat Task Berubah**
   - Selalu update notifikasi saat task di-edit atau dihapus

4. **Handle Errors**
   - Semua operasi notifikasi memiliki error handling
   - App tidak akan crash jika notifikasi gagal

## Catatan Penting

- ⚠️ **Android 13+**: User harus memberikan permission notifikasi
- ⚠️ **Battery Optimization**: Beberapa device mungkin membatasi exact alarms
- ⚠️ **Timezone**: Pastikan timezone device sudah benar
- ✅ **Auto-sync**: Notifikasi otomatis sync dengan tasks dari Firestore

