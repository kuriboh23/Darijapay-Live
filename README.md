# DarijaPay Live

A Flutter application designed for seamless payment processing, built with Firebase for a robust and scalable backend.

---

## ✨ Features

*   **User Authentication**: Secure sign-up and sign-in functionality using Firebase Authentication.
*   **Real-time Database**: Cloud Firestore for storing and syncing data across clients in real-time.
*   **Cross-Platform**: A single codebase for both Android and iOS.
*   **Internationalization**: Ready for localization to support multiple languages.

## 🛠️ Tech Stack

*   **Framework**: [Flutter](https://flutter.dev/)
*   **Language**: [Dart](https://dart.dev/)
*   **Backend**:
    *   [Firebase Authentication](https://firebase.google.com/docs/auth)
    *   [Cloud Firestore](https://firebase.google.com/docs/firestore)
*   **State Management**: (To be added)
*   **Linting**: [flutter_lints](https://pub.dev/packages/flutter_lints)

## 🚀 Getting Started

Follow these instructions to get a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

You need to have the Flutter SDK installed on your machine. For instructions, see the [official Flutter documentation](https://flutter.dev/docs/get-started/install).

### 1. Clone the Repository

```bash
git clone https://github.com/<your-username>/darijapay_live.git
cd darijapay_live
```

### 2. Install Dependencies

Run the following command to fetch all the required packages.

```bash
flutter pub get
```

### 3. Firebase Setup

This project uses Firebase. You will need to set up your own Firebase project to run the application.

1.  Go to the [Firebase Console](https://console.firebase.google.com/) and create a new project.
2.  Follow the instructions to add an Android and/or iOS app to your Firebase project.
3.  **For Android**: Download the `google-services.json` file and place it in the `android/app/` directory.
4.  **For iOS**: Download the `GoogleService-Info.plist` file and open `ios/Runner.xcworkspace` in Xcode. Drag the downloaded file into the `Runner` subfolder.

For more details, refer to the Add Firebase to your Flutter app documentation.

### 4. Run the Application

Connect a device or start an emulator, then run the following command:

```bash
flutter run
```
