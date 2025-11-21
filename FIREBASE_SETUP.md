# Firebase Setup Guide

This app uses Firebase for authentication and data storage. Follow these steps to set up Firebase for your project.

## ⚠️ Important Note

The app currently includes a **placeholder Firebase configuration** (`lib/firebase_options.dart`) that allows the app to run without errors. However, **Firebase features will not work** until you configure it properly.

**To enable Firebase features:**
1. Follow the setup steps below
2. Run `flutterfire configure` to generate proper Firebase options
3. This will replace the placeholder configuration with your actual Firebase project settings

## Prerequisites

1. A Firebase account (sign up at https://firebase.google.com/)
2. FlutterFire CLI installed globally:
   ```bash
   dart pub global activate flutterfire_cli
   ```

## Setup Steps

### 1. Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter project name (e.g., "MediRide")
4. Follow the setup wizard
5. Enable Google Analytics (optional)

### 2. Add Firebase to Your Flutter App

#### For Android:
1. In Firebase Console, click "Add app" → Android
2. Register app with package name: `com.example.mediride` (or your package name)
3. Download `google-services.json`
4. Place it in `android/app/` directory

#### For iOS:
1. In Firebase Console, click "Add app" → iOS
2. Register app with bundle ID: `com.example.mediride` (or your bundle ID)
3. Download `GoogleService-Info.plist`
4. Place it in `ios/Runner/` directory

### 3. Configure Firebase Authentication

1. In Firebase Console, go to **Authentication** → **Sign-in method**
2. Enable **Email/Password** authentication
3. Enable **Google** authentication:
   - Click on "Google" provider
   - Toggle "Enable" switch
   - Enter your project support email
   - Click "Save"
4. Save changes

**Note:** For Google Sign-In to work on web, you may need to add authorized domains in Firebase Console → Authentication → Settings → Authorized domains.

### 4. Configure Cloud Firestore

1. In Firebase Console, go to **Firestore Database**
2. Click "Create database"
3. Start in **test mode** (for development)
4. Choose a location for your database
5. Click "Enable"

### 5. Generate Firebase Configuration

Run the FlutterFire CLI to generate `firebase_options.dart`:

```bash
flutterfire configure
```

This will:
- Detect your Firebase projects
- Generate `lib/firebase_options.dart`
- Configure your app for Firebase

### 6. Security Rules (Important!)

Update your Firestore security rules in Firebase Console:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Users can only read/write their own trips
    match /trips/{tripId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
  }
}
```

## Testing

1. Run the app: `flutter run`
2. Try signing up with a new email
3. Check Firebase Console → Authentication to see the new user
4. Check Firestore Database to see user data and trips

## Troubleshooting

### "Firebase not initialized" error
- Make sure `firebase_options.dart` exists in `lib/`
- Run `flutterfire configure` again

### Authentication errors
- Verify Email/Password is enabled in Firebase Console
- Check that `google-services.json` (Android) or `GoogleService-Info.plist` (iOS) is in the correct location

### Firestore permission errors
- Check your security rules in Firebase Console
- Ensure you're authenticated before accessing Firestore

## Production Considerations

Before deploying to production:

1. **Update Firestore Rules**: Use production-ready security rules
2. **Enable App Check**: Add App Check for additional security
3. **Set up Indexes**: Create composite indexes for complex queries
4. **Monitor Usage**: Set up Firebase monitoring and alerts
5. **Backup Data**: Set up automated backups

## Support

For Firebase-specific issues, refer to:
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Console](https://console.firebase.google.com/)

