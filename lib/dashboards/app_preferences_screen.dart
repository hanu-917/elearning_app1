import 'package:flutter/material.dart';
import 'student_profile_downloads_screen.dart';

class AppPreferencesScreen extends StatefulWidget {
  const AppPreferencesScreen({super.key});

  @override
  State<AppPreferencesScreen> createState() => _AppPreferencesScreenState();
}

class _AppPreferencesScreenState extends State<AppPreferencesScreen> {
  String _fontSize = 'Medium';
  String _layoutView = 'Grid';
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: const Text('App Preferences', style: TextStyle(color: Color(0xFF05398F), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF05398F)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Theme Mode
            const Text("Appearance", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            _buildPreferenceCard(
              child: SwitchListTile(
                secondary: Icon(Icons.dark_mode_rounded, color: Colors.indigo.shade700),
                title: const Text("Dark Theme", style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text("Enable dark interface"),
                value: _darkMode,
                activeColor: const Color(0xFF09AEF5),
                onChanged: (val) => setState(() => _darkMode = val),
              ),
            ),

            const SizedBox(height: 30),
            
            // Font Size
            const Text("Typography", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            _buildPreferenceCard(
              child: Column(
                children: [
                  const ListTile(
                    leading: Icon(Icons.text_fields_rounded, color: Colors.purple),
                    title: Text("Font Size", style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text("Adjust text clarity"),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: ['Small', 'Medium', 'Large'].map((size) {
                        bool isSelected = _fontSize == size;
                        return ChoiceChip(
                          label: Text(size),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) setState(() => _fontSize = size);
                          },
                          selectedColor: const Color(0xFF09AEF5).withOpacity(0.2),
                          labelStyle: TextStyle(
                            color: isSelected ? const Color(0xFF09AEF5) : Colors.black87,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Layout
            const Text("Layout Design", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Row(
              children: [
                _buildLayoutOption('Grid', Icons.grid_view_rounded),
                const SizedBox(width: 16),
                _buildLayoutOption('List', Icons.view_list_rounded),
              ],
            ),
            
            const SizedBox(height: 30),

            // Downloads & Storage
            const Text("Offline Media", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            _buildPreferenceCard(
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.download_for_offline_rounded, color: Colors.amber),
                ),
                title: const Text("Download Settings", style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text("Manage offline storage and limits"),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.black26),
                onTap: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => const StudentProfileDownloadsScreen())
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferenceCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))
        ],
      ),
      child: child,
    );
  }

  Widget _buildLayoutOption(String layoutName, IconData icon) {
    bool isSelected = _layoutView == layoutName;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _layoutView = layoutName),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF09AEF5).withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? const Color(0xFF09AEF5) : Colors.grey.shade200,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? const Color(0xFF09AEF5) : Colors.grey, size: 36),
              const SizedBox(height: 8),
              Text(
                layoutName, 
                style: TextStyle(
                  color: isSelected ? const Color(0xFF09AEF5) : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
                )
              ),
            ],
          ),
        ),
      ),
    );
  }
}
