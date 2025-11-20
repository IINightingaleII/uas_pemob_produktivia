# Firebase Email OTP Authentication Setup Guide

## Overview
This app now includes Email OTP verification. After users register with email/password, they'll be asked to verify their email address with a 6-digit OTP code sent to their email.

## Setup Steps

### 1. Configure Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or select an existing one
3. Enable Authentication:
   - Go to **Authentication** > **Sign-in method**
   - Enable **Email/Password** authentication

### 2. Configure Flutter App

Run the following command in your project root:
```bash
flutterfire configure
```

This will:
- Generate `firebase_options.dart` file
- Configure Firebase for your platforms (Android/iOS)

### 3. Android Configuration

#### Update AndroidManifest.xml

Make sure your `android/app/src/main/AndroidManifest.xml` includes internet permission:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

### 4. iOS Configuration (if developing for iOS)

1. In Firebase Console, add an iOS app to your project
2. Download `GoogleService-Info.plist`
3. Add it to `ios/Runner/` in Xcode
4. Update `ios/Runner/Info.plist` with your REVERSED_CLIENT_ID

### 5. Update main.dart

Uncomment the Firebase initialization code in `lib/main.dart`:
```dart
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}
```

### 6. Set Up Email Sending (Required for Production)

**Important:** Currently, the OTP code is generated and stored in Firestore, but you need to implement email sending.

#### Option 1: Firebase Cloud Functions (Recommended)

1. Create a Cloud Function to send emails:
   ```javascript
   const functions = require('firebase-functions');
   const admin = require('firebase-admin');
   const nodemailer = require('nodemailer');
   
   // Configure your email service (Gmail, SendGrid, etc.)
   const transporter = nodemailer.createTransport({
     service: 'gmail',
     auth: {
       user: 'your-email@gmail.com',
       pass: 'your-app-password'
     }
   });
   
   exports.sendEmailOTP = functions.firestore
     .document('email_otps/{email}')
     .onCreate(async (snap, context) => {
       const data = snap.data();
       const email = data.email;
       const otp = data.otp;
       
       const mailOptions = {
         from: 'your-email@gmail.com',
         to: email,
         subject: 'Your Verification Code',
         html: `<h2>Your verification code is: ${otp}</h2>
                <p>This code will expire in 10 minutes.</p>`
       };
       
       return transporter.sendMail(mailOptions);
     });
   ```

2. Deploy the function:
   ```bash
   firebase deploy --only functions
   ```

#### Option 2: Use an Email Service API

You can integrate services like:
- SendGrid
- Mailgun
- AWS SES
- Resend

Update the `sendEmailOTP` method in `auth_service.dart` to call your email service API.

#### For Development/Testing

Currently, the OTP code is logged to the console for testing. Check your debug console or Firestore to see the OTP code.

## How It Works

1. **Registration Flow:**
   - User enters: Name, Email, Password
   - Account is created with email/password
   - 6-digit OTP is generated and stored in Firestore
   - OTP is sent to user's email (via Cloud Functions or email service)
   - User is redirected to OTP verification screen

2. **OTP Verification:**
   - User enters 6-digit code from their email
   - Code is verified against Firestore
   - OTP expires after 10 minutes
   - Once verified, user is redirected to home screen

3. **OTP Storage:**
   - OTPs are stored in Firestore collection `email_otps`
   - Each OTP has an expiration time (10 minutes)
   - OTPs are marked as verified after successful verification
   - Used OTPs cannot be reused

## Customization

### Change OTP Expiration Time

In `lib/services/auth_service.dart`, find the `sendEmailOTP` method and modify:
```dart
'expires_at': Timestamp.fromDate(
  DateTime.now().add(const Duration(minutes: 10)), // Change 10 to your desired minutes
),
```

### Change OTP Length

Currently using 6-digit OTP. To change, modify the `_generateOTP` method in `auth_service.dart`.

## Troubleshooting

### "Firebase is not configured" Error
- Run `flutterfire configure`
- Make sure `firebase_options.dart` exists
- Check that Firebase is properly initialized in `main.dart`

### OTP Not Received
- Check that email sending is properly configured (Cloud Functions or email service)
- Verify email address is correct
- Check spam folder
- For development, check console logs or Firestore for the OTP code
- Ensure Firestore rules allow reading `email_otps` collection

### "OTP has expired" Error
- OTP codes expire after 10 minutes
- Request a new code using "Resend Code" button

### "Session expired" Error
- OTP codes expire after 60 seconds
- User can request a new code using "Resend Code" button

## Security Notes

- OTP codes are stored securely in Firestore
- Codes expire after 10 minutes
- Each OTP can only be used once
- OTPs are automatically cleaned up after expiration (you may want to add a Cloud Function for this)
- Email addresses are validated before sending OTP
- Consider implementing rate limiting to prevent abuse

## Firestore Security Rules

Add these rules to allow OTP operations:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /email_otps/{email} {
      allow read, write: if request.auth != null;
      allow create: if true; // Allow creating OTPs during registration
    }
  }
}
```

## Additional Resources

- [Firebase Cloud Functions Documentation](https://firebase.google.com/docs/functions)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Console](https://console.firebase.google.com/)
- [Nodemailer Documentation](https://nodemailer.com/) (for email sending)

