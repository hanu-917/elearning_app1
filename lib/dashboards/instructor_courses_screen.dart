import 'package:flutter/material.dart';

class InstructorCoursesScreen extends StatelessWidget {
  const InstructorCoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {}, // Handle back navigation
        ),
        title: const Text("Courses", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.search, color: Colors.black), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Category Grid (Materials, Assessments, etc.)
            _buildCategoryGrid(),
            
            const SizedBox(height: 30),
            
            // 2. Section Header
            const Text(
              "Assigned courses",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey),
            ),
            const SizedBox(height: 15),
            
            // 3. List of Courses
            _buildCourseItem("Computer Security", "CoSc4051", "CS"),
            _buildCourseItem("Compiler Design", "CoSc4022", "CD"),
            _buildCourseItem("Complexity Theory", "CoSc4021", "CT"),
            _buildCourseItem("Research Methods in Comp...", "CoSc4111", "RM"),
            
            const SizedBox(height: 20),
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
      childAspectRatio: 1.5, // Makes them rectangular like the screenshot
      children: [
        _buildCategoryTile("Materials", Icons.layers, const Color(0xFF90CAF9)), // Light Blue
        _buildCategoryTile("Assessments", Icons.description, const Color(0xFFA5D6A7)), // Light Green
        _buildCategoryTile("Grade", Icons.bar_chart, const Color(0xFFB2EBF2)), // Cyan
        _buildCategoryTile("Groups", Icons.groups, const Color(0xFF9FA8DA)), // Soft Purple
      ],
    );
  }

  Widget _buildCategoryTile(String title, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          // Background Icon (Partially visible)
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(icon, size: 80, color: Colors.white.withOpacity(0.3)),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: Icon(icon, size: 20, color: color),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseItem(String title, String code, String leadingText) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Circular leading with initials
          CircleAvatar(
            backgroundColor: Colors.grey[100],
            child: Text(leadingText, style: const TextStyle(color: Colors.blueGrey, fontSize: 12)),
          ),
          const SizedBox(width: 15),
          // Course Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(code, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.more_vert, color: Colors.grey),
        ],
      ),
    );
  }
}