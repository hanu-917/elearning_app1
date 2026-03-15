import 'package:flutter/material.dart';

class StudentInboxScreen extends StatefulWidget {
  const StudentInboxScreen({super.key});

  @override
  State<StudentInboxScreen> createState() => _StudentInboxScreenState();
}

class _StudentInboxScreenState extends State<StudentInboxScreen> {
  bool isAnnounceSelected = true; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC), 
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F7FC),
        elevation: 0,
        centerTitle: false,
        title: const Text("Inbox", style: TextStyle(color: Color(0xFF05398F), fontSize: 24, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Color(0xFF05398F)), 
            onPressed: () {}
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          
          // 1. Custom Toggle Switch (Announcements / Messages)
          _buildToggleSwitch(),
          
          const SizedBox(height: 20),

          // 2. Announcements List (Students usually read more announcements than standard chat)
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildAnnouncementTile("Dr. Alemu", "Midterm Exam Schedule Changed", "CoSc4051", "14:59", Colors.purple),
                _buildAnnouncementTile("Prof. Bekele", "Assignment 2 Uploaded", "CoSc4022", "Yesterday", Colors.orange),
                _buildAnnouncementTile("Registrar Office", "Course add/drop deadline approachin...", "Global", "Yesterday", Colors.blue),
                _buildAnnouncementTile("Dr. Tadesse", "No Class This Friday", "CoSc4111", "Mon", Colors.red),
                _buildAnnouncementTile("Dr. Yonas", "Quiz 1 Results Available", "CoSc4021", "Mon", Colors.green),
              ],
            ),
          ),
        ],
      ),
      // 3. Floating Action Button for New Message
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF09AEF5),
        elevation: 4,
        child: const Icon(Icons.edit_rounded, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildToggleSwitch() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 50,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => isAnnounceSelected = true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isAnnounceSelected ? Colors.white : Colors.transparent, 
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isAnnounceSelected ? [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 4, offset: const Offset(0, 2))] : [],
                ),
                child: Center(
                  child: Text(
                    "Announcements",
                    style: TextStyle(
                      color: isAnnounceSelected ? const Color(0xFF05398F) : Colors.black54,
                      fontWeight: isAnnounceSelected ? FontWeight.bold : FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => isAnnounceSelected = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: !isAnnounceSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: !isAnnounceSelected ? [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 4, offset: const Offset(0, 2))] : [],
                ),
                child: Center(
                  child: Text(
                    "Messages",
                    style: TextStyle(
                      color: !isAnnounceSelected ? const Color(0xFF05398F) : Colors.black54,
                      fontWeight: !isAnnounceSelected ? FontWeight.bold : FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementTile(String sender, String header, String course, String time, Color accentColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.campaign_rounded, color: accentColor, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6)),
                            child: Text(course, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.grey.shade700)),
                          ),
                          Text(time, style: const TextStyle(color: Colors.black38, fontSize: 11)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(header, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87), maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text("Posted by $sender", style: const TextStyle(color: Colors.black45, fontSize: 12, fontWeight: FontWeight.w500)),
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
