import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../dashboards/instructor_dashboard.dart';
import '../dashboards/student_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _rememberMe = true; // State for the Remember Me checkbox

  void _handleLogin() async {
    // 1. Basic validation
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final result = await ApiService().login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      // 2. FIXED: Map 'accessToken' to match your authService.js response
      final String? token = result['accessToken'];
      final userData = result['user'];

      if (token == null || userData == null) {
        throw Exception("Invalid server response: Missing token or user data");
      }

      final String role = (userData['role'] ?? 'student').toString().toLowerCase();

      // 3. PERSISTENCE: Only save if 'Remember Me' is checked
      if (_rememberMe) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        await prefs.setString('user_role', role);
      }

      // 4. Navigation
      if (!mounted) return;
      
      if (role == 'instructor') {
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (context) => const InstructorDashboard()),
        );
      } else {
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (context) => const StudentDashboard()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      // Displays the specific error from your backend (e.g., "User not found")
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Login", style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Logo Placeholder
              const Icon(Icons.school, size: 80, color: Colors.blue), 
              const SizedBox(height: 40),
              
              // Email Field
              TextField(
                controller: _emailController, 
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 20),
              
              // Password Field
              TextField(
                controller: _passwordController, 
                obscureText: true, 
                decoration: InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.lock_outline),
                ),
              ),
              
              // Remember Me Checkbox
              Row(
                children: [
                  Checkbox(
                    value: _rememberMe,
                    onChanged: (value) => setState(() => _rememberMe = value!),
                    activeColor: Colors.blue,
                  ),
                  const Text("Remember Me", style: TextStyle(color: Colors.grey)),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Login Button
              _isLoading 
                ? const CircularProgressIndicator() 
                : SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _handleLogin, 
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        "LOGIN", 
                        style: TextStyle(
                          fontSize: 16, 
                          fontWeight: FontWeight.bold, 
                          color: Colors.white
                        ),
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}