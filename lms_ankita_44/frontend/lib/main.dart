import 'package:flutter/material.dart';

import 'screens/login.dart';
import 'screens/register.dart';
import 'screens/profile.dart';
import 'screens/splash_screen.dart';
import 'screens/student/student_dashboard.dart';
import 'screens/librarian/librarian_dashboard.dart';
import 'screens/librarian/add_book.dart';
import 'screens/librarian/manage_books.dart';
import 'models/user.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Library Management System',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (_) => const SplashScreen(),
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/profile': (_) => const ProfileScreen(),
        '/librarian_dashboard': (_) => const LibrarianDashboard(),
        '/add_book': (_) => const AddBookScreen(),
        '/manage_books': (_) => const ManageBooksScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/student_dashboard') {
          final user = settings.arguments as User;
          return MaterialPageRoute(
            builder: (_) => StudentDashboard(user: user),
          );
        }
        return null;
      },
    );
  }
}
