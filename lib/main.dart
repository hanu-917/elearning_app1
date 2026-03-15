import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth/welcome_screen.dart';
import 'dashboards/instructor_dashboard.dart';
import 'dashboards/student_dashboard.dart';

void main() {
  runApp(const ELearningApp());
}

class ELearningApp extends StatelessWidget {
  const ELearningApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ELMS Project',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // Set the AuthWrapper as the home to handle persistent login
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  String? _token;
  String? _role;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  // Logic to read from device storage
  Future<void> _checkLoginStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    
    // Slight delay to ensure smooth transition or to show a splash logo
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _token = prefs.getString('auth_token');
      _role = prefs.getString('user_role');
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 1. Show a loading spinner while checking storage
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // 2. If no token is found, send them to the Welcome/Login flow
    if (_token == null) {
      return const WelcomeScreen();
    }

    // 3. If token exists, redirect based on their saved role
    if (_role == 'instructor') {
      return const InstructorDashboard();
    } else if (_role == 'student') {
      return const StudentDashboard();
    }

    // Fallback to welcome if something is malformed
    return const WelcomeScreen();
  }
}