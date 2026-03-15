import 'package:flutter/material.dart';

class StudentCoursesScreen extends StatelessWidget {
  const StudentCoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC), // Match home screen background
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F7FC),
        elevation: 0,
        centerTitle: false,
        title: const Text("Enrolled Courses", style: TextStyle(color: Color(0xFF05398F), fontSize: 24, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Color(0xFF05398F)), 
            onPressed: () {}
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Sleek Category Grid (Materials, Assessments, etc.)
            _buildCategoryGrid(),
            
            const SizedBox(height: 35),
            
            // 2. Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Spring 2026 Semester",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                TextButton(
                  onPressed: () {}, 
                  child: const Text("Past", style: TextStyle(color: Color(0xFF09AEF5), fontWeight: FontWeight.bold))
                )
              ],
            ),
            const SizedBox(height: 10),
            
            // 3. List of Courses
            _buildCourseItem("Computer Security", "CoSc4051", "Dr. Alemu", "CS", Colors.blue, 0.65),
            _buildCourseItem("Compiler Design", "CoSc4022", "Prof. Bekele", "CD", Colors.purple, 0.40),
            _buildCourseItem("Complexity Theory", "CoSc4021", "Dr. Yonas", "CT", Colors.orange, 0.82),
            _buildCourseItem("Research Methods", "CoSc4111", "Dr. Tadesse", "RM", Colors.green, 0.15),
            
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: 1.4,
      children: [
        _buildCategoryTile("Modules", Icons.library_books_rounded, const Color(0xFF09AEF5), const Color(0xFF05398F)),
        _buildCategoryTile("Assignments", Icons.assignment_rounded, const Color(0xFF66BB6A), const Color(0xFF2E7D32)),
        _buildCategoryTile("Results", Icons.fact_check_rounded, const Color(0xFFFFCA28), const Color(0xFFFF8F00)),
        _buildCategoryTile("Peers", Icons.people_alt_rounded, const Color(0xFFAB47BC), const Color(0xFF6A1B9A)),
      ],
    );
  }

  Widget _buildCategoryTile(String title, IconData icon, Color gradientStart, Color gradientEnd) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [gradientStart, gradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradientEnd.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -15,
            bottom: -15,
            child: Icon(icon, size: 90, color: Colors.white.withOpacity(0.15)),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(12)
                  ),
                  child: Icon(icon, size: 24, color: Colors.white),
                ),
                const Spacer(),
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseItem(String title, String code, String instructor, String initials, Color avatarColor, double progress) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Circular leading with initials
                Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    color: avatarColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      initials, 
                      style: TextStyle(color: avatarColor, fontWeight: FontWeight.bold, fontSize: 18)
                    )
                  ),
                ),
                const SizedBox(width: 16),
                // Course Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
                      const SizedBox(height: 4),
                      Text("$code • $instructor", style: const TextStyle(color: Colors.black54, fontSize: 13, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      // Progress Bar
                      Row(
                        children: [
                          Expanded(
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation<Color>(avatarColor),
                              borderRadius: BorderRadius.circular(5),
                              minHeight: 6,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text("${(progress*100).toInt()}%", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black45)),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
