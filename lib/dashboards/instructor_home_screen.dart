import 'package:flutter/material.dart';

class InstructorHomeScreen extends StatelessWidget {
  const InstructorHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            _buildHeader(),
            
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Updated: Horizontal Scrollable Cards
                  _buildHorizontalCards(context),
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 25.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Grid Menu
                        const Text("Main Menu", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 15),
                        _buildMenuGrid(),
                        
                        const SizedBox(height: 25),
                        const Text("Quick Actions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 15),
                        _buildQuickAction(Icons.send, "Post Announcement", "Chat"),
                        _buildQuickAction(Icons.download, "Downloads", "My Files"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)]),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text("Hello, Dr. Alemu", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
              Text("Instructor account", style: TextStyle(color: Colors.blueGrey)),
            ],
          ),
          const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.notifications_none, color: Colors.blue)),
        ],
      ),
    );
  }

  // UPDATED: Horizontal scroll with equal width cards
  Widget _buildHorizontalCards(BuildContext context) {
    double cardWidth = MediaQuery.of(context).size.width * 0.8;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Blue Upcoming Class Card
          _buildBaseCard(
            width: cardWidth,
            gradient: const LinearGradient(colors: [Colors.blue, Colors.blueAccent]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text("Upcoming Class on", style: TextStyle(color: Colors.white70, fontSize: 13)),
                SizedBox(height: 4),
                Text("Mon 8:30", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                Spacer(),
                Text("See More...", style: TextStyle(color: Colors.white60, fontSize: 12)),
              ],
            ),
          ),
          
          const SizedBox(width: 15),

          // Green Upload Card (Equal width)
          _buildBaseCard(
            width: cardWidth,
            color: const Color(0xFF81C784),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("View", style: TextStyle(color: Colors.white, fontSize: 14)),
                    Text("Upload", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
                    Text("Materials", style: TextStyle(color: Colors.white, fontSize: 16)),
                  ],
                ),
                const Icon(Icons.cloud_upload, color: Colors.white, size: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper for consistent card styling
  Widget _buildBaseCard({required double width, Color? color, Gradient? gradient, required Widget child}) {
    return Container(
      width: width,
      height: 140,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: child,
    );
  }

  Widget _buildMenuGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      mainAxisSpacing: 20,
      children: [
        _buildIconBtn(Icons.folder, "My Files"),
        _buildIconBtn(Icons.cloud_upload, "Upload"),
        _buildIconBtn(Icons.book, "Courses"),
        _buildIconBtn(Icons.schedule, "Schedule"),
        _buildIconBtn(Icons.assessment, "Assessments"),
        _buildIconBtn(Icons.group, "Group"),
        _buildIconBtn(Icons.calendar_month, "Calendar"),
        _buildIconBtn(Icons.add_circle_outline, "More"),
      ],
    );
  }

  Widget _buildIconBtn(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
          child: Icon(icon, color: Colors.blue),
        ),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildQuickAction(IconData icon, String title, String sub) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        subtitle: Text(sub, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}