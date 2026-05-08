import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() => _isLoading = true);
    try {
      final notifications = await _apiService.getNotifications();
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'chat': return Icons.chat_bubble_outline_rounded;
      case 'announcement': return Icons.campaign_outlined;
      case 'material': return Icons.folder_shared_outlined;
      case 'task': return Icons.assignment_outlined;
      case 'system': return Icons.notifications_none_rounded;
      default: return Icons.notifications_outlined;
    }
  }

  Color _getColor(String type) {
    switch (type) {
      case 'chat': return Colors.blue;
      case 'announcement': return Colors.orange;
      case 'material': return Colors.green;
      case 'task': return Colors.purple;
      case 'system': return Colors.redAccent;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        title: const Text("Notifications", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF05398F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchNotifications,
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.notifications_none_rounded, size: 80, color: Colors.grey.shade300),
                    const SizedBox(height: 15),
                    Text("No notifications yet", style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  final n = _notifications[index];
                  final DateTime date = DateTime.parse(n['created_at']);
                  final String formattedDate = DateFormat('MMM d, h:mm a').format(date);
                  final isRead = n['is_read'] == true;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: isRead ? Colors.white.withOpacity(0.8) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _getColor(n['type'] ?? '').withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(_getIcon(n['type'] ?? ''), color: _getColor(n['type'] ?? ''), size: 24),
                      ),
                      title: Text(
                        n['title'] ?? 'Notification',
                        style: TextStyle(
                          fontWeight: isRead ? FontWeight.w600 : FontWeight.bold,
                          fontSize: 16,
                          color: isRead ? Colors.black54 : Colors.black87,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(n['content'] ?? '', style: TextStyle(color: isRead ? Colors.grey : Colors.black54)),
                          const SizedBox(height: 6),
                          Text(formattedDate, style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
                        ],
                      ),
                      onTap: () async {
                        if (!isRead) {
                          try {
                            await _apiService.markNotificationAsRead(n['id']);
                            setState(() {
                              n['is_read'] = true;
                            });
                          } catch (e) {
                            debugPrint("Failed to mark as read: $e");
                          }
                        }
                      },
                    ),
                  );
                },
              ),
      ),
    );
  }
}
