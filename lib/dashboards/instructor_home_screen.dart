import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InstructorHomeScreen extends StatefulWidget {
  const InstructorHomeScreen({super.key});

  @override
  State<InstructorHomeScreen> createState() => _InstructorHomeScreenState();
}

class _InstructorHomeScreenState extends State<InstructorHomeScreen> {
  String _title = 'Professor';
  String _firstName = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _title = prefs.getString('title') ?? 'Professor';
      if (_title.isEmpty) _title = 'Professor';
      if (_title == 'None') _title = '';
      _firstName = prefs.getString('first_name') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC), // Professional light grayish blue background
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section with our primary gradient
            _buildHeader(),
            
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Horizontal Scrollable Cards
                  _buildHorizontalCards(context),
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 25.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Grid Menu
                        const Text("Main Menu", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF05398F))),
                        const SizedBox(height: 15),
                        _buildMenuGrid(),
                        
                        const SizedBox(height: 25),
                        const Text("Quick Actions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF05398F))),
                        const SizedBox(height: 15),
                        _buildQuickAction(Icons.send_rounded, "Post Announcement", "Notify all students"),
                        _buildQuickAction(Icons.download_rounded, "Downloads", "Access offline materials"),
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
      padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 35),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF09AEF5), Color(0xFF05398F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30), 
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
           BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Hello, $_title $_firstName".trim(), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.5)),
                const SizedBox(height: 4),
                const Text("Welcome to BDU ELMS", style: TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
               color: Colors.white24,
               shape: BoxShape.circle,
            ),
            child: const CircleAvatar(
              backgroundColor: Colors.white, 
              radius: 22,
              child: Icon(Icons.notifications_none_rounded, color: Color(0xFF05398F), size: 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalCards(BuildContext context) {
    double cardWidth = MediaQuery.of(context).size.width * 0.75;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Blue Upcoming Class Card
          _buildBaseCard(
            width: cardWidth,
            gradient: const LinearGradient(
              colors: [Color(0xFF42A5F5), Color(0xFF1976D2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text("Upcoming Class", style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
                    Icon(Icons.video_call_rounded, color: Colors.white70, size: 20),
                  ],
                ),
                const SizedBox(height: 12),
                const Text("Mon 8:30 AM", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                const Spacer(),
                const Text("Computer Science 101", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                const Text("Tap to view details ›", style: TextStyle(color: Colors.white60, fontSize: 12)),
              ],
            ),
          ),
          
          const SizedBox(width: 15),

          // Action Card for materials
          _buildBaseCard(
            width: cardWidth,
            gradient: const LinearGradient(
              colors: [Color(0xFF26A69A), Color(0xFF00695C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("Quick Action", style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
                    SizedBox(height: 8),
                    Text("Upload", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
                    Text("Materials", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.cloud_upload_rounded, color: Colors.white, size: 36),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBaseCard({required double width, Gradient? gradient, required Widget child}) {
    return Container(
      width: width,
      height: 150,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
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
      mainAxisSpacing: 25,
      crossAxisSpacing: 10,
      children: [
        _buildIconBtn(Icons.folder_shared_rounded, "Materials", const Color(0xFFFFF3E0), Colors.orange),
        _buildIconBtn(Icons.cloud_upload_rounded, "Upload", const Color(0xFFE3F2FD), Colors.blue),
        _buildIconBtn(Icons.book_rounded, "Courses", const Color(0xFFE8F5E9), Colors.green),
        _buildIconBtn(Icons.schedule_rounded, "Schedule", const Color(0xFFF3E5F5), Colors.purple),
        _buildIconBtn(Icons.assessment_rounded, "Grades", const Color(0xFFFFEBEE), Colors.red),
        _buildIconBtn(Icons.groups_rounded, "Groups", const Color(0xFFE0F7FA), Colors.cyan),
        _buildIconBtn(Icons.calendar_month_rounded, "Calendar", const Color(0xFFFFFDE7), Colors.amber),
        _buildIconBtn(Icons.more_horiz_rounded, "More", Colors.grey.shade200, Colors.grey.shade700),
      ],
    );
  }

  Widget _buildIconBtn(IconData icon, String label, Color bgColor, Color iconColor) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 55,
          width: 55,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04), 
                blurRadius: 10,
                offset: const Offset(0, 4)
              )
            ]
          ),
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label, 
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildQuickAction(IconData icon, String title, String sub) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ]
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: const Color(0xFF09AEF5), size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
                      const SizedBox(height: 4),
                      Text(sub, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Colors.black26),
              ],
            ),
          ),
        ),
      ),
    );
  }
}