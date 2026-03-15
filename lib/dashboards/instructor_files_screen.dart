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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "My Files", 
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)
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
        backgroundColor: const Color(0xFF1976D2),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Search your files...",
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildStorageToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      height: 45,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
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
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)] : [],
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentFilesSection(BuildContext context) {
    double itemWidth = MediaQuery.of(context).size.width * 0.25;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("Recent Files", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Icon(Icons.arrow_drop_up, color: Colors.blueGrey), 
            ],
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(left: 20),
          child: Row(
            children: [
              _buildRecentFileItem("Lect..._2.pdf", Icons.insert_drive_file, "2 hrs ago", itemWidth),
              _buildRecentFileItem("His..._5.mp4", Icons.videocam_outlined, "7 hrs ago", itemWidth),
              _buildRecentFileItem("Lect..._1.pdf", Icons.insert_drive_file, "This week", itemWidth),
              _buildRecentFileItem("Lect..._3.pdf", Icons.insert_drive_file, "This week", itemWidth),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentFileItem(String name, IconData icon, String time, double width) {
    return Container(
      width: width,
      margin: const EdgeInsets.only(right: 15),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                )
              ],
            ),
            child: Icon(icon, color: Colors.blueGrey.shade300, size: 30),
          ),
          const SizedBox(height: 8),
          Text(time, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
          Text(name, style: const TextStyle(color: Colors.grey, fontSize: 10), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildFolderHierarchyView() {
    return Column(
      children: [
        Container(
          height: 60,
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2FD).withOpacity(0.5), 
            border: Border(
              top: BorderSide(color: Colors.grey.shade200), 
              bottom: BorderSide(color: Colors.grey.shade200),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: const [
              Icon(Icons.home_outlined, color: Colors.blueGrey),
              Icon(Icons.chevron_right, color: Colors.grey, size: 20),
              Text("Main Storage", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
              Spacer(),
              Icon(Icons.more_vert, color: Colors.grey),
            ],
          ),
        ),
        
        _buildImageFolderTile("Books", "1 Apr 2025", "12:08 pm", "7 items"),
        _buildImageFolderTile("Documents", "8 Feb", "9:29 pm", "3 items"),
        _buildImageFolderTile("Download", "1 Apr 2025", "12:08 pm", "2 items"),
        _buildImageFolderTile("Folder 1", "1 Apr 2025", "12:08 pm", "1 item"),
        _buildImageFileTile("Lecture 5 Data Pr...asurement.docx", "6 Jan 2025", "10:04 am", "23.01 KB"),
      ],
    );
  }

  Widget _buildImageFolderTile(String name, String date, String time, String itemCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          Icon(Icons.folder, color: Colors.grey.shade400, size: 35),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text("$date • $time", style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
          Text(itemCount, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildImageFileTile(String name, String date, String time, String size) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[100], 
              borderRadius: BorderRadius.circular(10)
            ),
            child: Icon(Icons.insert_drive_file, color: Colors.grey.shade400),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text("$date • $time", style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
          Text(size, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        ],
      ),
    );
  }
}