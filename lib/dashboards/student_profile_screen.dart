import 'package:flutter/material.dart';

class StudentProfileScreen extends StatelessWidget {
  const StudentProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Pure white background to match reference
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Massive Blue Header Block matching reference image
            Container(
              padding: const EdgeInsets.only(top: 60, bottom: 40),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF3B5BFF), Color(0xFF1E3A8A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  // Top bar mimicking the back button & settings but using our notification icon
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(Icons.arrow_back, color: Colors.transparent), // Layout spacing
                        const Text("Profile", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const Icon(Icons.notifications_none, color: Colors.white), 
                      ],
                    ),
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
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "CS Department • Year 2",
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "ID: 2024001A",
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  const SizedBox(height: 48),
                  // Embedded Stats (GPA and Attendance) mimicking Followers/Following layout
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: const [
                          Text("3.6", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text("GPA", style: TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                      Container(
                        height: 30,
                        width: 1,
                        color: Colors.white30,
                      ),
                      Column(
                        children: const [
                          Text("87%", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text("Attendance", style: TextStyle(color: Colors.white70, fontSize: 12)),
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
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.error_outline, color: Colors.red, size: 20),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Low attendance alert. Review your schedule.",
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Performance Insight
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8.0, left: 4.0),
                    child: Text("Performance Insight", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black45)),
                  ),
                  _buildListRow(Icons.check_circle_outline, "Strong subject", "Software Engineering"),
                  _buildListRow(Icons.error_outline, "Weak subject", "Mathematics"),
                  _buildListRow(Icons.trending_flat, "Overall trend", "Stable"),
                  
                  const SizedBox(height: 24),
                  
                  // Settings
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8.0, left: 4.0),
                    child: Text("Settings", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black45)),
                  ),
                  _buildListRow(Icons.library_books_outlined, "Academic Record", ""),
                  _buildListRow(Icons.offline_bolt_outlined, "Offline Content", ""),
                  _buildToggleRow(Icons.nights_stay_outlined, "Study Mode (Dark Theme)", false), // Toggled!

                  const SizedBox(height: 24),
                  
                  // Support
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8.0, left: 4.0),
                    child: Text("Support", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black45)),
                  ),
                  _buildListRow(Icons.mail_outline, "Contact Department", "admin@csdept.edu"),
                  
                  const SizedBox(height: 32),
                  
                  // Dedicated Log Out Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.red.shade200, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {},
                      child: const Text(
                        "Log Out",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // Method mimics the clean minimalist list row structure from the image
  Widget _buildListRow(IconData icon, String title, String subtitle) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.black54, size: 20),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          subtitle: subtitle.isNotEmpty 
            ? Text(
                subtitle,
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              )
            : null,
          trailing: subtitle.isEmpty ? const Icon(Icons.chevron_right, color: Colors.black26, size: 20) : null,
          onTap: () {},
        ),
        const Divider(height: 1, indent: 64, color: Colors.black12),
      ],
    );
  }

  // New Toggle Method specifically constructed for tracking study mode
  Widget _buildToggleRow(IconData icon, String title, bool value) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.black54, size: 20),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          trailing: Switch(
            value: value,
            onChanged: (val) {},
            activeColor: const Color(0xFF3B5BFF),
          ),
        ),
        const Divider(height: 1, indent: 64, color: Colors.black12),
      ],
    );
  }
}
