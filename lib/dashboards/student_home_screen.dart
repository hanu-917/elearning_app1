import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'system_messages_screen.dart';
import 'student_menu_screen.dart';
import 'student_courses_screen.dart';
import '../services/api_service.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  String _title = '';
  String _firstName = 'Student';
  final ApiService _apiService = ApiService();
  bool _isScheduleLoading = true;
  bool _isTasksLoading = true;
  List<Map<String, dynamic>> _todaySchedule = [];
  List<dynamic> _pendingTasks = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchTodaySchedule();
    _fetchPendingTasks();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _title = prefs.getString('title') ?? '';
      if (_title == 'None') _title = '';
      _firstName = prefs.getString('first_name') ?? 'Student';
    });
  }

  Future<void> _fetchTodaySchedule() async {
    if (!mounted) return;
    setState(() => _isScheduleLoading = true);
    try {
      final courses = await _apiService.getStudentCourses();
      final schedules = await _apiService.getMySchedules();

      _processTodaySchedule(courses, schedules);
    } catch (e) {
      debugPrint("Error fetching schedule: $e");
    } finally {
      if (mounted) setState(() => _isScheduleLoading = false);
    }
  }

  Future<void> _fetchPendingTasks() async {
    if (!mounted) return;
    setState(() => _isTasksLoading = true);
    try {
      final tasks = await _apiService.getStudentAssignments();
      if (mounted) {
        setState(() {
          _pendingTasks = tasks;
        });
      }
    } catch (e) {
      debugPrint("Error fetching tasks: $e");
    } finally {
      if (mounted) setState(() => _isTasksLoading = false);
    }
  }

  String _getDueString(String dueDateStr) {
    try {
      final dueDate = DateTime.parse(dueDateStr);
      final now = DateTime.now();
      final difference = dueDate.difference(now);

      if (difference.isNegative) return "Overdue";

      if (difference.inHours < 24) {
        if (difference.inHours == 0) return "Due in ${difference.inMinutes} mins";
        return "Due in ${difference.inHours} hrs";
      }

      if (difference.inDays < 7) {
        return "Due ${DateFormat('EEEE').format(dueDate)}";
      }

      return "Due ${DateFormat('MMM d').format(dueDate)}";
    } catch (e) {
      return "Due $dueDateStr";
    }
  }

  bool _isUrgent(String dueDateStr) {
    try {
      final dueDate = DateTime.parse(dueDateStr);
      final now = DateTime.now();
      final difference = dueDate.difference(now);
      return difference.inHours < 24 && !difference.isNegative;
    } catch (e) {
      return false;
    }
  }

  void _processTodaySchedule(List<dynamic> courses, List<dynamic> schedules) {
    // ... existing _processTodaySchedule implementation ...
    // (I'll keep the original content here)
    final Set<String> myCourseIdentifiers = {};
    for (var course in courses) {
      if (course['title'] != null) myCourseIdentifiers.add(course['title'].toString().toLowerCase());
      if (course['course_code'] != null) myCourseIdentifiers.add(course['course_code'].toString().toLowerCase());
    }

    final int todayIdx = DateTime.now().weekday - 1; // 0 = Monday, ..., 6 = Sunday
    
    List<Map<String, dynamic>> todayClasses = [];
    
    final slotTimes = [
      "08:00 AM - 09:45 AM",
      "09:50 AM - 12:20 PM",
      "01:35 PM - 03:20 PM",
      "03:25 PM - 06:05 PM"
    ];
    final List<Color> colors = [Colors.purple, Colors.green, Colors.orange, Colors.blue, Colors.red, Colors.teal];

    for (var schedule in schedules) {
      if (schedule['file_path'] == 'DIGITAL_ENTRY') {
        final content = schedule['content'] as Map<String, dynamic>?;
        if (content != null) {
          content.forEach((key, value) {
            // Key format is "slotIdx-dayIdx"
            final parts = key.split('-');
            if (parts.length == 2) {
              try {
                int slotIdx = int.parse(parts[0]);
                int dayIdx = int.parse(parts[1]);
                
                String courseName = value.toString().trim();
                String courseTitleOnly = courseName.split('|')[0].split('-')[0].trim().toLowerCase();
                
                bool isMyCourse = myCourseIdentifiers.contains(courseName.toLowerCase()) || 
                                 myCourseIdentifiers.contains(courseTitleOnly);
                
                // Final fallback: check if any of our identifiers is a substring of the schedule entry
                if (!isMyCourse) {
                  isMyCourse = myCourseIdentifiers.any((id) => 
                    id.length > 3 && (courseName.toLowerCase().contains(id) || id.contains(courseName.toLowerCase()))
                  );
                }

                if (dayIdx == todayIdx && isMyCourse) {
                  todayClasses.add({
                    'course': courseName,
                    'time': slotTimes[slotIdx % slotTimes.length],
                    'slotIdx': slotIdx,
                    'color': colors[todayClasses.length % colors.length]
                  });
                }
              } catch (e) {
                // Ignore parse errors for malformed keys
              }
            }
          });
        }
      }
    }

    // Sort by time (slotIdx)
    todayClasses.sort((a, b) => a['slotIdx'].compareTo(b['slotIdx']));

    if (mounted) {
      setState(() {
        _todaySchedule = todayClasses;
      });
    }
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
                        
                        const SizedBox(height: 30),
                        const Text("Today's Schedule", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF05398F))),
                        const SizedBox(height: 15),
                        if (_isScheduleLoading)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: CircularProgressIndicator(strokeWidth: 3),
                            ),
                          )
                        else if (_todaySchedule.isEmpty)
                          _buildEmptySchedule()
                        else
                          ..._todaySchedule.map((s) => _buildScheduleTask(s['course'], s['time'], s['color'])),

                        const SizedBox(height: 30),
                        const Text("Pending Tasks", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF05398F))),
                        const SizedBox(height: 15),
                        if (_isTasksLoading)
                          const Center(
                             child: Padding(
                               padding: EdgeInsets.all(20.0),
                               child: CircularProgressIndicator(strokeWidth: 3),
                             ),
                           )
                        else if (_pendingTasks.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16)
                            ),
                            child: const Center(child: Text("No assignments found", style: TextStyle(color: Colors.grey))),
                          )
                        else
                          ..._pendingTasks.take(5).map((task) {
                            final bool urgent = _isUrgent(task['due_date'].toString());
                            return _buildTaskItem(
                              task['title'].toString(),
                              _getDueString(task['due_date'].toString()),
                              urgent ? Colors.orange : Colors.blue,
                              urgent
                            );
                          }),
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
                Text("Hi, ${_title.isNotEmpty ? '$_title ' : ''}$_firstName".trim(), 
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.5),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 4),
                const Text("Let's start learning!", style: TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SystemMessagesScreen()));
            },
            child: Container(
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
          ),

        ],
      ),
    );
  }

  Widget _buildHorizontalCards(BuildContext context) {
    double cardWidth = MediaQuery.of(context).size.width - 40; // Full width with 20 padding on each side

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: _buildBaseCard(
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
                Text("Continue Learning", style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
                Icon(Icons.play_circle_fill_rounded, color: Colors.white70, size: 20),
              ],
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("Ch 3: Firewalls", 
                        style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8),
                      Text("Computer Security", 
                        style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 60,
                  width: 60,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: 0.65,
                        strokeWidth: 6,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                      const Center(
                        child: Text("65%", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
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
        _buildIconBtn(Icons.folder_shared_rounded, "Materials", const Color(0xFFFFF3E0), Colors.orange, onTap: () {
          // Future: Navigate to StudentMaterials
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Materials section coming soon!")));
        }),
        _buildIconBtn(Icons.assignment_rounded, "Tasks", const Color(0xFFE3F2FD), Colors.blue, onTap: () {
           // Future: Navigate to All Tasks
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("All tasks section coming soon!")));
        }),
        _buildIconBtn(Icons.groups_rounded, "Groups", const Color(0xFFE0F7FA), Colors.cyan, onTap: () {
          // Future: Navigate to StudentGroups
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Groups section coming soon!")));
        }),
        _buildIconBtn(Icons.more_horiz_rounded, "More", Colors.grey.shade200, Colors.grey.shade700, onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const StudentMenuScreen()));
        }),
      ],
    );
  }

  Widget _buildIconBtn(IconData icon, String label, Color bgColor, Color iconColor, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
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
      ),
    );
  }

  Widget _buildTaskItem(String title, String dueTime, Color accent, bool isUrgent) {
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
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.assignment_late_rounded, color: accent, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isUrgent ? Colors.red.shade50 : accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10)
                        ),
                        child: Text(dueTime, style: TextStyle(color: isUrgent ? Colors.red : accent, fontSize: 10, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                ),
                if (isUrgent)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
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

  Widget _buildScheduleTask(String title, String timeDetails, Color accent) {
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
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.access_time_filled_rounded, color: accent, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
                      const SizedBox(height: 4),
                      Text(timeDetails, style: const TextStyle(color: Colors.black54, fontSize: 13, fontWeight: FontWeight.w600)),
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

  Widget _buildEmptySchedule() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.event_available_rounded, size: 40, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            DateTime.now().weekday > 5 ? "Happy Weekend! No classes today." : "No classes scheduled for today.",
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
