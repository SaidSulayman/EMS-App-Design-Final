# EMS App Design Final
click here. https://ems-app-design-final.vercel.app/

This repository contains the Flutter EMS (Emergency Medical Services) app design and source for the final project.

## Overview
- Flutter application with Android, iOS, web, macOS, Linux, and Windows targets.
- Contains Firebase configuration and services under `lib/`.

## Quick start
1. Install Flutter: https://flutter.dev/docs/get-started/install
2. From the project root, get packages:

```powershell
flutter pub get
```

3. Run on a device or emulator:

```powershell
flutter run
```

4. Build for release (example Android):

```powershell
flutter build apk --release
```

## Notes about repository state
- A `.gitignore` is present and common generated files (e.g. `node_modules`, `build`, `.dart_tool`, `.metadata`) are ignored.
- If you previously cloned this repo before the cleanup commit, you may see large generated files in history; consider recloning after pulling the latest branch if you want the cleaned state locally.

## Contributing
- Open a branch for your work and submit a PR to `main` or `chats` as appropriate.

## License
Add your license information here if desired.
# MediRide - Emergency Medical Services Flutter App

**Full app Idea https://gamma.app/docs/SDG-3-Emergency-Care-Innovation-Saving-Lives-with-Smart-EMS-Apps-un32o5y4w3271qx**

A fully-functional Flutter application for emergency medical services with an Uber-like user experience. This app allows patients to request ambulances, track them in real-time, and rate their service.

## Features

### 🔐 Authentication
- Login and signup forms with validation
- Persistent user sessions using SharedPreferences
- Social login UI (Google integration ready)
- User profile management

### 🚑 Emergency Request System
- 6 types of emergencies:
  - Cardiac Emergency
  - Respiratory Distress
  - Trauma/Injury
  - Stroke Symptoms
  - Allergic Reaction
  - Other Emergency
- Emergency type selection with detailed descriptions
- Ambulance matching simulation
- Real-time status updates

### 🗺️ Real-Time Tracking
- Interactive map using flutter_map and OpenStreetMap
- GPS location tracking with geolocator
- User and ambulance position markers
- Distance and ETA calculations
- Live ambulance movement simulation
- Driver information card with contact option

### ⭐ Rating & Feedback
- 5-star rating system after service completion
- Optional written feedback
- Beautiful completion screen with animations

### 📱 Trip History
- Complete list of past emergency requests
- Detailed trip information including:
  - Emergency type
  - Driver and vehicle details
  - Distance and duration
  - Date and time
  - Rating and feedback
- Empty state when no history exists

### 🎨 UI/UX Features
- Material Design 3 with custom theming
- Light and dark mode support
- Smooth animations and transitions
- Responsive layout for all screen sizes
- Professional medical theme with red accent colors
- Intuitive navigation

## Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Android Studio / Xcode for mobile development
- A physical device or emulator

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd mediride
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
# For development
flutter run

# For release build
flutter run --release
```

### Platform-Specific Setup

#### Android
Add location permissions to `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest>
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    <uses-permission android:name="android.permission.INTERNET" />
    
    <application>
        ...
    </application>
</manifest>
```

#### iOS
Add location usage descriptions to `ios/Runner/Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs access to location for ambulance tracking</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>This app needs access to location for ambulance tracking</string>
```

## Project Structure

```
lib/
├── main.dart                    # App entry point with theme configuration
├── models/                      # Data models
│   ├── user_model.dart         # User data model
│   ├── emergency_model.dart    # Emergency types enum and extensions
│   ├── driver_model.dart       # Driver/paramedic model
│   └── trip_model.dart         # Trip history model
├── providers/                   # State management (Provider pattern)
│   ├── theme_provider.dart     # Theme switching logic
│   ├── auth_provider.dart      # Authentication state
│   └── emergency_provider.dart # Emergency request workflow
├── screens/                     # Full-page screens
│   ├── auth_screen.dart        # Login/Signup screen
│   └── home_screen.dart        # Main app navigation
└── widgets/                     # Reusable UI components
    ├── emergency_selector.dart # Emergency type selection
    ├── tracking_view.dart      # Real-time tracking view
    ├── rating_view.dart        # Service rating screen
    └── trip_history_view.dart  # Trip history list
```

## Dependencies

### State Management
- `provider: ^6.1.1` - State management solution

### Maps & Location
- `google_maps_flutter: ^2.5.0` - Google Maps integration
- `flutter_map: ^6.1.0` - OpenStreetMap integration
- `latlong2: ^0.9.0` - Latitude/longitude utilities
- `geolocator: ^10.1.0` - GPS location services
- `geocoding: ^2.1.1` - Address geocoding

### UI Components
- `flutter_rating_bar: ^4.0.1` - Star rating widget
- `intl: ^0.18.1` - Internationalization and date formatting

### Storage & Network
- `shared_preferences: ^2.2.2` - Local data persistence
- `http: ^1.1.0` - HTTP requests (ready for API integration)

## Architecture

The app uses the **Provider** pattern for state management with two main providers:

1. **AuthProvider** - Handles user authentication and session
2. **EmergencyProvider** - Manages emergency request workflow

### App States
- `home` - Main screen with emergency type selector
- `selecting` - Emergency type selection in progress
- `requesting` - Finding nearest ambulance
- `tracking` - Real-time ambulance tracking
- `completed` - Service completed, awaiting rating
- `history` - Viewing past trips

## Customization

### Emergency Types
Add or modify emergency types in `lib/models/emergency_model.dart`

### Mock Data
Replace mock data with real API calls in the providers:
- `AuthProvider.login()` - Integrate authentication API
- `EmergencyProvider.selectEmergency()` - Connect to ambulance dispatch API

## Future Enhancements

- [ ] Real-time chat with driver
- [ ] Multiple payment methods
- [ ] Medical insurance integration
- [ ] Emergency contacts notification
- [ ] Medical history storage
- [ ] Multi-language support
- [ ] Push notifications
- [ ] Driver/paramedic app version
- [ ] Admin dashboard

## Production Considerations

### Security
- Implement proper authentication with JWT or OAuth
- Encrypt sensitive data in SharedPreferences
- Use HTTPS for all API calls
- Implement certificate pinning

### Backend Integration
- Replace mock data with real API endpoints
- Implement WebSocket for real-time updates
- Add proper error handling and retry logic
- Implement offline mode support

### Performance
- Optimize map rendering for low-end devices
- Implement image caching
- Add loading states and skeleton screens
- Optimize bundle size

### Legal & Compliance
- Add proper medical disclaimers
- Implement HIPAA compliance if handling medical data
- Add terms of service and privacy policy
- Obtain necessary medical service certifications

## Important Notes

⚠️ **This is a demonstration app with simulated data**

- All ambulance dispatch is simulated
- Location tracking uses mock coordinates
- Payment processing is not implemented
- For actual emergencies, always call 911 or your local emergency number

## License

This project is created for demonstration purposes.

## Support

For issues and questions, please create an issue in the repository.

---

**Built with Flutter** ❤️
#   E M S - A p p - 
 
 #   E M S - A p p - 
 
 #   E M S - A p p - D e s i g n - 1 - 
 
 #   E M S - A p p - D e s i g n - F i n a l 
 
 #   E M S - A p p - D e s i g n - 1 - 
 
 #   E M S - A p p - D e s i g n - F i n a l
