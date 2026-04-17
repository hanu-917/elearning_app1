import 'package:flutter/material.dart';
import 'student_settings_screen.dart';

class StudentProfileScreen extends StatelessWidget {
  const StudentProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Top Gradient Section matches the dashboard image
          Container(
            padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 40),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF6A85E6),
                  Color(0xFF8FB0FF),
                  Color(0xFFF5F7FA), // Matches Scaffold background exactly
                ],
                stops: [0.0, 0.6, 1.0],
              ),
            ),
            child: Column(
              children: [
                // Top bar with Settings Icon Button
                Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(Icons.arrow_back, color: Colors.transparent), // Layout spacing
                        const Text("Profile", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.settings_outlined, color: Colors.white),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const StudentSettingsScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                  const SizedBox(height: 32),
                  // Prominent Circular Avatar
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const CircleAvatar(
                      radius: 46,
                      backgroundColor: Color(0xFFE2E8F0),
                      child: Icon(Icons.person, size: 50, color: Color(0xFF94A3B8)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Hani",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E2843),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "CS Department • Year 2",
                    style: TextStyle(fontSize: 14, color: Color(0xFF4A5568)),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "ID: 2024001A",
                    style: TextStyle(fontSize: 14, color: Color(0xFF4A5568)),
                  ),
                  const SizedBox(height: 48),
                  // Embedded Stats (GPA and Attendance) mimicking Followers/Following layout
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: const [
                          Text("3.6", style: TextStyle(color: Color(0xFF1E2843), fontSize: 20, fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text("GPA", style: TextStyle(color: Color(0xFF4A5568), fontSize: 12)),
                        ],
                      ),
                      Container(
                        height: 30,
                        width: 1,
                        color: Colors.black12,
                      ),
                      Column(
                        children: const [
                          Text("87%", style: TextStyle(color: Color(0xFF1E2843), fontSize: 20, fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text("Attendance", style: TextStyle(color: Color(0xFF4A5568), fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Minimal White Body (No Cards)
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Attendance Alert
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.red.shade100),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        )
                      ],
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.error_outline, color: Colors.red, size: 20),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Low attendance alert. Review your schedule.",
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),

            // Wrap all inner elements inside White Cards
            SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- Group 1: Performance Insight ---
                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 8),
                    child: Text("Performance Insight", style: TextStyle(color: Color(0xFF4A5568), fontSize: 13, fontWeight: FontWeight.bold)),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildListItem(Icons.check_circle_outline, "Strong subject", "Software Engineering"),
                        _buildListItem(Icons.error_outline, "Weak subject", "Mathematics"),
                        _buildListItem(Icons.trending_flat, "Overall trend", "Stable", isLast: true),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // --- Group 2: Settings & Support ---
                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 8),
                    child: Text("Settings & Support", style: TextStyle(color: Color(0xFF4A5568), fontSize: 13, fontWeight: FontWeight.bold)),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildListItem(Icons.lock_outline, "Privacy & Security", ""),
                        _buildListItem(Icons.language_outlined, "Language Preferences", ""),
                        _buildToggleItem(Icons.nights_stay_outlined, "Study Mode (Dark Theme)", false),
                        _buildListItem(Icons.help_outline, "Help Center & FAQs", ""),
                        _buildListItem(Icons.mail_outline, "Contact Department", "admin@csdept.edu"),
                        _buildListItem(Icons.report_problem_outlined, "Report an Issue", "", isLast: true),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Dedicated Log Out Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {},
                      child: const Text(
                        "Log Out",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
        ],
      ),
    );
  }

  // Dashboard-styled list item without standard gray dividers
  Widget _buildListItem(IconData icon, String title, String subtitle, {bool isLast = false, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap ?? () {},
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF6A85E6).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF6A85E6), size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E2843),
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF4A5568)),
                    ),
                  ],
                ],
              ),
            ),
            if (subtitle.isEmpty) 
               const Icon(Icons.arrow_forward_ios_rounded, color: Colors.black26, size: 16),
          ],
        ),
      ),
    );
  }

  // Dashboard-styled toggle row
  Widget _buildToggleItem(IconData icon, String title, bool value, {bool isLast = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF6A85E6).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF6A85E6), size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E2843),
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: (val) {},
            activeColor: const Color(0xFF3B5BFF),
          ),
        ],
      ),
    );
  }
}
