# Library Management System - Frontend

A Flutter-based mobile and web application for managing library operations with separate interfaces for librarians and students.

## 📋 Table of Contents
- [Overview](#overview)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [How to Run](#how-to-run)
- [Project Structure](#project-structure)
- [API Integration](#api-integration)

## 🎯 Overview

This is the frontend application for the Library Management System (LMS) built with Flutter. It provides a cross-platform solution that works on Android, iOS, Web, and Desktop platforms. The application features role-based access control with dedicated dashboards for librarians and students.

## ✨ Features

### Authentication
- User registration with role selection
- Secure login with JWT authentication
- Token-based session management
- Profile management

### Librarian Features
- **Dashboard**: Overview of library statistics
- **Add Book**: Add new books to the library inventory
- **Manage Books**: View, edit, and delete existing books
- **Issue Book**: Issue books to students
- **View Issued Books**: Track all book issues and returns

### Student Features
- **Dashboard**: Personalized student dashboard
- **View Books**: Browse available books in the library
- **My Issued Books**: View currently issued books and history

## 🛠 Tech Stack

- **Framework**: Flutter 3.0+
- **Language**: Dart
- **State Management**: StatefulWidget
- **HTTP Client**: http package (^1.2.0)
- **Authentication**: JWT tokens with jwt_decode (^0.3.1)
- **Local Storage**: shared_preferences (^2.2.2)
- **UI**: Material Design

## 📦 Prerequisites

Before running this application, ensure you have:

1. **Flutter SDK** (3.0.0 or higher)
   - Download from: https://flutter.dev/docs/get-started/install

2. **Dart SDK** (comes with Flutter)

3. **IDE** (one of the following):
   - Visual Studio Code with Flutter extension
   - Android Studio with Flutter plugin
   - IntelliJ IDEA with Flutter plugin

4. **Platform-specific requirements**:
   - For Android: Android Studio and Android SDK
   - For iOS: Xcode (macOS only)
   - For Web: Chrome browser
   - For Desktop: Platform-specific toolchains

5. **Backend Server**: Ensure the backend server is running on `http://localhost:3000`

## 🚀 Installation

1. **Clone the repository**:
   ```bash
   cd /Users/ankitalokhande/Desktop/lms_ankita_44/lms_ankita_44/frontend
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Verify Flutter installation**:
   ```bash
   flutter doctor
   ```
   This command checks your environment and displays a report of the status of your Flutter installation.

## ▶️ How to Run

### Check Available Devices
First, check which devices are available:
```bash
flutter devices
```

### Run on Chrome (Web)
```bash
flutter run -d chrome
```

### Run on macOS (Desktop)
```bash
flutter run -d macos
```

### Run on Android Emulator
1. Start an Android emulator from Android Studio
2. Run:
   ```bash
   flutter run
   ```

### Run on iOS Simulator (macOS only)
1. Start an iOS simulator
2. Run:
   ```bash
   flutter run
   ```

### Run on Physical Device
1. Connect your device via USB
2. Enable USB debugging (Android) or trust the computer (iOS)
3. Run:
   ```bash
   flutter run
   ```

### Development with Hot Reload
Once the app is running, you can use:
- Press `r` to hot reload
- Press `R` to hot restart
- Press `q` to quit

### Build for Production

**Web**:
```bash
flutter build web
```

**Android APK**:
```bash
flutter build apk
```

**iOS**:
```bash
flutter build ios
```

**macOS**:
```bash
flutter build macos
```

## 📁 Project Structure

```
frontend/
├── lib/
│   ├── main.dart                    # Application entry point
│   ├── models/                      # Data models
│   │   ├── book.dart
│   │   ├── user.dart
│   │   └── issueBook.js
│   ├── screens/                     # UI screens
│   │   ├── splash_screen.dart
│   │   ├── login.dart
│   │   ├── register.dart
│   │   ├── profile.dart
│   │   ├── librarian/              # Librarian screens
│   │   │   ├── librarian_dashboard.dart
│   │   │   ├── add_book.dart
│   │   │   ├── manage_books.dart
│   │   │   ├── issue_book.dart
│   │   │   └── view_issued_books.dart
│   │   └── student/                # Student screens
│   │       ├── student_dashboard.dart
│   │       ├── view_books.dart
│   │       └── my_issued_books.dart
│   ├── services/                    # API services
│   │   ├── auth_service.dart
│   │   ├── book_service.dart
│   │   ├── issue_book_service.dart
│   │   └── user_service.dart
│   ├── utils/                       # Utility functions
│   │   └── auth_helper.dart
│   └── widgets/                     # Reusable widgets
│       └── book_card.dart
├── pubspec.yaml                     # Dependencies
└── README.md                        # This file
```

## 🔌 API Integration

The application connects to a Node.js backend server. Ensure the backend is running before starting the frontend.

**Default Backend URL**: `http://localhost:3000`

### API Endpoints Used:
- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login
- `GET /api/books` - Get all books
- `POST /api/books` - Add a new book (Librarian only)
- `PUT /api/books/:id` - Update a book (Librarian only)
- `DELETE /api/books/:id` - Delete a book (Librarian only)
- `POST /api/issue-books` - Issue a book (Librarian only)
- `GET /api/issue-books` - Get all issued books
- `GET /api/users/profile` - Get user profile

## 🔐 Authentication

The app uses JWT (JSON Web Tokens) for authentication:
1. User logs in with credentials
2. Backend returns a JWT token
3. Token is stored locally using SharedPreferences
4. Token is sent with each API request in the Authorization header
5. Token is decoded to retrieve user information (role, ID, etc.)

## 🎨 UI/UX

- Material Design principles
- Role-based navigation
- Responsive layouts
- Loading states and error handling
- Form validation

## 📱 Supported Platforms

- ✅ Android
- ✅ iOS
- ✅ Web (Chrome)
- ✅ macOS
- ✅ Windows
- ✅ Linux

## 🐛 Troubleshooting

### Issue: Flutter command not found
**Solution**: Add Flutter to your PATH or restart your terminal after installation

### Issue: Unable to connect to backend
**Solution**: Ensure the backend server is running on `http://localhost:3000`

### Issue: Build errors after pulling changes
**Solution**:
```bash
flutter clean
flutter pub get
flutter run
```

### Issue: Hot reload not working
**Solution**: Try hot restart (Press `R`) or fully restart the app

## 📄 License

This project is part of the LMS Ankita 44 application.

## 👤 Author

Ankita Lokhande

---

For backend documentation, see `/backend/README.md`
