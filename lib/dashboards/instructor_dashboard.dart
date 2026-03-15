import 'package:flutter/material.dart';
import 'instructor_home_screen.dart'; // We will create this next
import 'instructor_courses_screen.dart';
import 'instructor_inbox_screen.dart';
import 'instructor_files_screen.dart';
import 'instructor_profile_screen.dart';

class InstructorDashboard extends StatefulWidget {
  const InstructorDashboard({super.key});
  @override
  State<InstructorDashboard> createState() => _InstructorDashboardState();
}

class _InstructorDashboardState extends State<InstructorDashboard> {
  int _index = 0;
  
  // Replace the text list with actual Screen Widgets
  final List<Widget> _screens = [
    const InstructorHomeScreen(),
    const InstructorCoursesScreen(),
    const InstructorInboxScreen(),
    const InstructorFilesScreen(),
    const InstructorProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_index],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _index,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'HOME'),
          BottomNavigationBarItem(icon: Icon(Icons.book_outlined), activeIcon: Icon(Icons.book), label: 'COURSES'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_outlined), activeIcon: Icon(Icons.chat), label: 'INBOX'),
          BottomNavigationBarItem(icon: Icon(Icons.folder_outlined), activeIcon: Icon(Icons.folder), label: 'MY FILES'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'PROFILE'),
        ],
      ),
    );
  }
}