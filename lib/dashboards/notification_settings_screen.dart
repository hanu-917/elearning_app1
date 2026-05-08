import 'package:flutter/material.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _isSilent = false;
  List<String> _silentExceptions = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(color: Color(0xFF05398F), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF05398F)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Management",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 20),
            
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.notifications_off_rounded, color: Colors.redAccent, size: 22),
                    ),
                    title: const Text("Silent Mode", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    subtitle: const Text("Mute notifications during classes"),
                    value: _isSilent,
                    activeColor: const Color(0xFF09AEF5),
                    onChanged: (val) => setState(() => _isSilent = val),
                  ),
                  if (_isSilent) ...[
                    const Divider(height: 1),
                    const Padding(
                      padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
                      child: Text(
                        "ALLOW EXCEPTIONS FOR:",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey, letterSpacing: 1.1),
                      ),
                    ),
                    ...['Chats', 'Announcements', 'System', 'All'].map((option) {
                      return CheckboxListTile(
                        title: Text(option, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                        value: _silentExceptions.contains(option),
                        activeColor: const Color(0xFF09AEF5),
                        onChanged: (bool? checked) {
                          setState(() {
                            if (checked == true) {
                              if (option == 'All') {
                                _silentExceptions = ['All'];
                              } else {
                                _silentExceptions.remove('All');
                                _silentExceptions.add(option);
                              }
                            } else {
                              _silentExceptions.remove(option);
                            }
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                      );
                    }).toList(),
                    const SizedBox(height: 10),
                  ]
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            const Text(
              "System Notifications",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 15),
            _buildNotificationOption("Email Notifications", true),
            _buildNotificationOption("SMS Alerts", false),
            _buildNotificationOption("Urgent Announcements", true),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationOption(String title, bool initialValue) {
    bool val = initialValue;
    return StatefulBuilder(
      builder: (context, setInternalState) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: SwitchListTile(
            title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            value: val,
            activeColor: const Color(0xFF09AEF5),
            onChanged: (v) => setInternalState(() => val = v),
          ),
        );
      }
    );
  }
}
