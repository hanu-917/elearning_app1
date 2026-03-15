import 'package:flutter/material.dart';

class InstructorFilesScreen extends StatefulWidget {
  const InstructorFilesScreen({super.key});

  @override
  State<InstructorFilesScreen> createState() => _InstructorFilesScreenState();
}

class _InstructorFilesScreenState extends State<InstructorFilesScreen> {
  bool isLocalSelected = true; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC), // Professional light grayish blue background
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F7FC),
        elevation: 0,
        centerTitle: false,
        title: const Text(
          "My Files", 
          style: TextStyle(color: Color(0xFF05398F), fontSize: 24, fontWeight: FontWeight.bold)
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Search Bar
            _buildSearchBar(),

            // 2. Storage Toggle (Local / Cloud)
            _buildStorageToggle(),
            
            // 3. Recent Files Section (Horizontal Carousel)
            _buildRecentFilesSection(context),
            
            const SizedBox(height: 10),

            // 4. Folder Hierarchy View (Fixed Border Logic)
            _buildFolderHierarchyView(),
            
            const SizedBox(height: 100), 
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF09AEF5),
        elevation: 4,
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
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
        child: TextField(
          decoration: InputDecoration(
            hintText: "Search your files...",
            hintStyle: const TextStyle(color: Colors.black38),
            prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF05398F)),
            filled: true,
            fillColor: Colors.transparent,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStorageToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      height: 50,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _toggleItem("Local Storage", isLocalSelected, () => setState(() => isLocalSelected = true)),
          _toggleItem("Cloud Storage", !isLocalSelected, () => setState(() => isLocalSelected = false)),
        ],
      ),
    );
  }

  Widget _toggleItem(String title, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 4, offset: const Offset(0, 2))] : [],
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? const Color(0xFF05398F) : Colors.black54,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentFilesSection(BuildContext context) {
    double itemWidth = MediaQuery.of(context).size.width * 0.28;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("Recent Files", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
              Icon(Icons.keyboard_arrow_up_rounded, color: Colors.black45), 
            ],
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(left: 20, bottom: 20),
          child: Row(
            children: [
              _buildRecentFileItem("Lecture_2.pdf", Icons.picture_as_pdf_rounded, "2 hrs ago", itemWidth, Colors.red),
              _buildRecentFileItem("History_5.mp4", Icons.videocam_rounded, "7 hrs ago", itemWidth, Colors.blue),
              _buildRecentFileItem("Lecture_1.pdf", Icons.picture_as_pdf_rounded, "This week", itemWidth, Colors.red),
              _buildRecentFileItem("Code_zip.zip", Icons.folder_zip_rounded, "This week", itemWidth, Colors.orange),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentFileItem(String name, IconData icon, String time, double width, Color iconColor) {
    return Container(
      width: width,
      margin: const EdgeInsets.only(right: 15),
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
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(height: 12),
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87), overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(time, style: const TextStyle(color: Colors.black45, fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildFolderHierarchyView() {
    return Column(
      children: [
        Container(
          height: 60,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2FD),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: const [
              Icon(Icons.home_rounded, color: Color(0xFF05398F), size: 22),
              SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded, color: Colors.black38, size: 20),
              SizedBox(width: 8),
              Text("Main Storage", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF05398F))),
              Spacer(),
              Icon(Icons.more_horiz_rounded, color: Colors.black54),
            ],
          ),
        ),
        
        const SizedBox(height: 15),
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              _buildImageFolderTile("Books", "1 Apr 2025", "12:08 pm", "7 items"),
              _buildImageFolderTile("Documents", "8 Feb 2025", "9:29 pm", "3 items"),
              _buildImageFolderTile("Downloads", "1 Apr 2025", "12:08 pm", "2 items"),
              _buildImageFolderTile("Assessments", "15 Apr 2025", "2:15 pm", "1 item"),
              _buildImageFileTile("Lecture 5 Notes.docx", "6 Jan 2025", "10:04 am", "23.01 KB"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageFolderTile(String name, String date, String time, String itemCount) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ]
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.folder_rounded, color: Color(0xFF09AEF5), size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
                const SizedBox(height: 4),
                Text("$date • $time", style: const TextStyle(color: Colors.black45, fontSize: 12, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          Text(itemCount, style: const TextStyle(color: Colors.black38, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildImageFileTile(String name, String date, String time, String size) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ]
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE8EAF6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.description_rounded, color: Color(0xFF3F51B5), size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87), overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text("$date • $time", style: const TextStyle(color: Colors.black45, fontSize: 12, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          Text(size, style: const TextStyle(color: Colors.black38, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}