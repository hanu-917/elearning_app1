import 'package:flutter/material.dart';

class AboutLmsScreen extends StatelessWidget {
  const AboutLmsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F7FC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF05398F)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "About ELMS",
          style: TextStyle(
            color: Color(0xFF05398F),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ]
              ),
              child: const Icon(Icons.school_rounded, size: 80, color: Color(0xFF09AEF5)),
            ),
            const SizedBox(height: 30),
            const Text(
              "E-Learning Management System",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF05398F)),
            ),
            const SizedBox(height: 10),
            const Text(
              "Version 1.0.0",
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 40),
            const Text(
              "Our E-Learning Management System (ELMS) is designed to provide a seamless and interactive educational experience for students and instructors. "
              "We aim to bridge the gap between traditional learning and modern technology by offering tools for real-time collaboration, course management, and comprehensive assessment.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
            ),
            const SizedBox(height: 40),
            _buildInfoCard("Developed By", "ELMS Development Team"),
            const SizedBox(height: 16),
            _buildInfoCard("Contact Support", "support@elms.edu"),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String subtitle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54)),
          const SizedBox(height: 6),
          Text(subtitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
        ],
      ),
    );
  }
}
