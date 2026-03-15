import 'package:flutter/material.dart';

class InstructorInboxScreen extends StatefulWidget {
  const InstructorInboxScreen({super.key});

  @override
  State<InstructorInboxScreen> createState() => _InstructorInboxScreenState();
}

class _InstructorInboxScreenState extends State<InstructorInboxScreen> {
  bool isChatSelected = true; // State for the Chat/Announce toggle

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Icon(Icons.arrow_back, color: Colors.black),
        title: const Text("Courses", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.search, color: Colors.black), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          
          // 1. Custom Toggle Switch (Chat / Announce)
          _buildToggleSwitch(),
          
          const SizedBox(height: 20),

          // 2. Chat List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              children: [
                _buildChatTile("Natasha", "Hi, Good Evening Bro!", "03", "14:59"),
                _buildChatTile("Alex", "I Just Finished It..!", "02", "06:35"),
                _buildChatTile("John", "How are you?", "", "08:10"),
                _buildChatTile("Mia", "OMG, This is Amazing..", "05", "21:07"),
                _buildChatTile("Maria", "Wow, This is Really Epic", "", "09:15"),
                _buildChatTile("Tiya", "Hi, Good Evening Bro!", "03", "14:59"),
                _buildChatTile("Manisha", "I Just Finished It..!", "02", "06:35"),
              ],
            ),
          ),
        ],
      ),
      // 3. Floating Action Button for New Message
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFFE3F2FD),
        child: const Icon(Icons.campaign, color: Color(0xFF1976D2), size: 30),
      ),
    );
  }

  Widget _buildToggleSwitch() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => isChatSelected = true),
              child: Container(
                decoration: BoxDecoration(
                  color: isChatSelected ? const Color(0xFF1B5E20) : Colors.transparent, // Dark Green
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(
                  child: Text(
                    "Chat",
                    style: TextStyle(
                      color: isChatSelected ? Colors.white : Colors.black54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => isChatSelected = false),
              child: Container(
                decoration: BoxDecoration(
                  color: !isChatSelected ? const Color(0xFFE3F2FD) : Colors.transparent, // Light Blue
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(
                  child: Text(
                    "Announce",
                    style: TextStyle(
                      color: !isChatSelected ? const Color(0xFF1976D2) : Colors.black54,
                      fontWeight: FontWeight.bold,
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

  Widget _buildChatTile(String name, String message, String count, String time) {
    return ListTile(
      leading: const CircleAvatar(
        radius: 25,
        backgroundColor: Colors.black, // Matching the solid black profiles in screenshot
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(message, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (count.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
              child: Text(count, style: const TextStyle(color: Colors.white, fontSize: 10)),
            ),
          const SizedBox(height: 5),
          Text(time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}