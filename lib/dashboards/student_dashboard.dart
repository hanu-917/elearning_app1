import 'package:flutter/material.dart';
import 'student_home_screen.dart';
import 'student_courses_screen.dart';
import 'student_inbox_screen.dart';
import 'student_downloads_screen.dart';
import 'student_profile_screen.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});
  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _index = 0;
  
  final List<Widget> _screens = [
    const StudentHomeScreen(),
    const StudentCoursesScreen(),
    const StudentInboxScreen(),
    const StudentDownloadsScreen(),
    const StudentProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_index],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: BottomNavigationBar(
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          currentIndex: _index,
          selectedItemColor: const Color(0xFF09AEF5),
          unselectedItemColor: Colors.grey.shade400,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
          onTap: (i) => setState(() => _index = i),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.book_outlined), activeIcon: Icon(Icons.book), label: 'Courses'),
            BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), activeIcon: Icon(Icons.chat_bubble), label: 'Inbox'),
            BottomNavigationBarItem(icon: Icon(Icons.download_for_offline_outlined), activeIcon: Icon(Icons.download_for_offline_outlined), label: 'Downloads'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}