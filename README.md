# RateMyUstaad

An app built using Flutter that allows students to search, rate, and review professors based on teaching quality, clarity, and helpfulness. Designed to help students make informed academic decisions and catered particularly to Pakistani university students.

## Getting Started

Follow these instructions to set up the project for development on your local machine.

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (version 3.0.0 or higher)
- [Dart SDK](https://dart.dev/get-dart) (version 2.17.0 or higher)
- [Firebase account](https://firebase.google.com/)
- [Git](https://git-scm.com/downloads)
- A code editor (like [VS Code](https://code.visualstudio.com/) or [Android Studio](https://developer.android.com/studio))

### Setup Instructions

#### 1. Clone the repository

```bash
git clone https://github.com/yourusername/ratemyustaad-frontend.git
cd ratemyustaad-frontend
```

#### 2. Install dependencies

```bash
flutter pub get
```

#### 3. Firebase Setup

1. Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Add Android and iOS apps to your Firebase project
   - Follow the instructions to download the configuration files:
     - `google-services.json` for Android
     - `GoogleService-Info.plist` for iOS
   - Place these files in their respective locations:
     - Android: `android/app/google-services.json`
     - iOS: `ios/Runner/GoogleService-Info.plist`

3. Install FlutterFire CLI:
```bash
dart pub global activate flutterfire_cli
```

4. Configure Firebase for your Flutter app:
```bash
flutterfire configure --project=your-firebase-project-id
```

5. Enable required Firebase services:
   - Authentication (Email/Password)
   - Cloud Firestore
   - Analytics (optional)

#### 4. Firestore Database Setup

1. Create the following collections in Firestore:
   - `users`
   - `teachers`
   - `reviews`

2. Add necessary security rules for Firestore:
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, create: if request.auth != null;
      allow update, delete: if request.auth != null && request.auth.uid == userId;
    }
    
    match /teachers/{teacherId} {
      allow read: if true;
      allow create, update: if request.auth != null;
      allow delete: if false;
    }
    
    match /reviews/{reviewId} {
      allow read: if true;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && request.auth.uid == resource.data.userId;
    }
  }
}
```

3. Create the following indexes in Firestore:
   - Collection: `teachers`
     - Fields to index: `reviewCount` (Ascending), `averageRating` (Descending), `__name__` (Descending)
     
   - Collection: `reviews`
     - Fields to index: `teacherId` (Ascending), `timestamp` (Descending)
     - Fields to index: `userId` (Ascending), `timestamp` (Descending)

#### 5. Running the app

```bash
flutter run
```

To specify a device:
```bash
flutter run -d <device-id>
```

For release mode:
```bash
flutter run --release
```

### Building for Production

#### Android

```bash
flutter build apk --release
```
The APK file will be available at `build/app/outputs/flutter-apk/app-release.apk`

#### iOS

```bash
flutter build ios --release
```
Then use Xcode to archive and distribute the app

## Features

- Search for professors by name or department
- View professor ratings and reviews
- Submit reviews with ratings for teaching quality, clarity, and helpfulness
- Anonymous review option
- User profile with review history

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
