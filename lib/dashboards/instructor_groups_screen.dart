import 'package:flutter/material.dart';
import '../services/api_service.dart';

class InstructorGroupsScreen extends StatefulWidget {
  const InstructorGroupsScreen({super.key});

  @override
  State<InstructorGroupsScreen> createState() => _InstructorGroupsScreenState();
}

class _InstructorGroupsScreenState extends State<InstructorGroupsScreen> {
  final ApiService _apiService = ApiService();
  
  List<dynamic> _courses = [];
  List<dynamic> _groups = [];
  List<dynamic> _targets = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Fetch courses and targets in parallel
      final results = await Future.wait([
        _apiService.getInstructorCourses().timeout(const Duration(seconds: 10)),
        _apiService.getInstructorTargets().timeout(const Duration(seconds: 10)),
      ]);

      final courses = results[0] as List<dynamic>;
      final targets = results[1] as List<dynamic>;
      
      // Fetch groups for all courses in parallel with individual timeouts
      final groupFutures = courses.map((course) => 
        _apiService.getGroups(course['id'].toString())
          .timeout(const Duration(seconds: 7))
          .catchError((e) => []) // If one course fails, just return empty list for it
      );
      
      final groupResults = await Future.wait(groupFutures);
      
      List<dynamic> allGroups = [];
      for (int i = 0; i < courses.length; i++) {
        final courseGroups = groupResults[i];
        if (courseGroups is List && courseGroups.isNotEmpty) {
          allGroups.add({
            "course_id": courses[i]['id'],
            "course_title": courses[i]['title'] ?? courses[i]['course_code'] ?? "Course",
            "course_code": courses[i]['course_code'] ?? "",
            "groups": courseGroups,
          });
        }
      }

      if (mounted) {
        setState(() {
          _courses = courses;
          _targets = targets;
          _groups = allGroups;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().contains('TimeoutException') 
              ? "Request timed out. Please check your connection."
              : e.toString().replaceAll('Exception: ', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showCreateGroupBottomSheet() {
    String? selectedCourseId;
    String? selectedDepartmentId;
    String? selectedSection;
    String? groupName;
    int groupSize = 5;
    String groupingMethod = 'Random';
    List<dynamic> currentCourseStats = [];
    bool isFetchingStats = false;
    
    final List<String> methods = ['Random', 'Alphabetic', 'GPA Top Distributed'];
    final TextEditingController nameController = TextEditingController();
    final TextEditingController sizeController = TextEditingController(text: '5');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            // Find current department to get its sections
            final currentDept = selectedDepartmentId != null 
              ? _targets.firstWhere((t) => t["id"] == selectedDepartmentId, orElse: () => null) 
              : null;
            final List<String> availableSections = currentDept != null 
              ? List<String>.from(currentDept["sections"] ?? []) 
              : [];

            // Calculate the exact count for selected dept and section
            int currentSegmentCount = 0;
            if (selectedDepartmentId != null && selectedSection != null) {
              final stat = currentCourseStats.firstWhere(
                (s) => s["department_id"] == selectedDepartmentId && s["section"] == selectedSection,
                orElse: () => null
              );
              if (stat != null) {
                currentSegmentCount = stat["student_count"] ?? 0;
              }
            }

            return Container(
              padding: EdgeInsets.only(
                top: 20, 
                left: 20, 
                right: 20, 
                bottom: MediaQuery.of(context).viewInsets.bottom + 30
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 50,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Form New Groups",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF05398F)),
                    ),
                    const SizedBox(height: 20),
                    
                    const Text("Group Title", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: "e.g., Final Project Teams",
                        filled: true,
                        fillColor: const Color(0xFFF4F7FC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                      onChanged: (val) => groupName = val,
                    ),
                    const SizedBox(height: 20),

                    const Text("Select Course", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F7FC),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          hint: const Text("Choose Course"),
                          value: selectedCourseId,
                          items: _courses.map((course) {
                            return DropdownMenuItem<String>(
                              value: course["id"],
                              child: Text("${course['title']}"),
                            );
                          }).toList(),
                          onChanged: (val) async {
                            if (val != null) {
                              setSheetState(() {
                                isFetchingStats = true;
                                selectedCourseId = val;
                                selectedDepartmentId = null;
                                selectedSection = null;
                                currentCourseStats = [];
                              });
                              
                              try {
                                final stats = await _apiService.getCourseEnrollmentStats(val);
                                setSheetState(() {
                                  currentCourseStats = stats;
                                  isFetchingStats = false;
                                });
                              } catch (e) {
                                setSheetState(() => isFetchingStats = false);
                              }
                            }
                          },
                        ),
                      ),
                    ),

                    if (isFetchingStats) ...[
                      const SizedBox(height: 10),
                      const Center(child: LinearProgressIndicator(minHeight: 2)),
                    ],

                    if (selectedCourseId != null) ...[
                      const SizedBox(height: 20),
                      const Text("Select Department", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F7FC),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            hint: const Text("Choose Department"),
                            value: selectedDepartmentId,
                            items: _targets.map((dept) {
                              return DropdownMenuItem<String>(
                                value: dept["id"],
                                child: Text("${dept['name']}"),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setSheetState(() {
                                selectedDepartmentId = val;
                                selectedSection = null; // Reset section
                              });
                            },
                          ),
                        ),
                      ),
                    ],

                    if (selectedDepartmentId != null) ...[
                      const SizedBox(height: 20),
                      const Text("Select Section", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F7FC),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            hint: const Text("Choose Section"),
                            value: selectedSection,
                            items: availableSections.map((sec) {
                              return DropdownMenuItem<String>(
                                value: sec,
                                child: Text(sec),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setSheetState(() {
                                selectedSection = val;
                              });
                            },
                          ),
                        ),
                      ),
                      
                      if (selectedSection != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE3F2FD),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.people_alt_rounded, color: Color(0xFF09AEF5), size: 20),
                              const SizedBox(width: 10),
                              const Text(
                                "Students in Section:", 
                                style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)
                              ),
                              const Spacer(),
                              Text(
                                "$currentSegmentCount",
                                style: const TextStyle(color: Color(0xFF05398F), fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Students Per Group", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 13)),
                              const SizedBox(height: 8),
                              TextField(
                                controller: sizeController,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: const Color(0xFFF4F7FC),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                  contentPadding: EdgeInsets.zero,
                                  prefixIcon: IconButton(
                                    icon: const Icon(Icons.remove_rounded, color: Color(0xFF05398F), size: 20),
                                    onPressed: () {
                                      if (groupSize > 1) {
                                        setSheetState(() {
                                          groupSize--;
                                          sizeController.text = groupSize.toString();
                                        });
                                      }
                                    },
                                    splashRadius: 20,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: const Icon(Icons.add_rounded, color: Color(0xFF05398F), size: 20),
                                    onPressed: () {
                                      setSheetState(() {
                                        groupSize++;
                                        sizeController.text = groupSize.toString();
                                      });
                                    },
                                    splashRadius: 20,
                                  ),
                                ),
                                onChanged: (val) {
                                  if (int.tryParse(val) != null) {
                                    setSheetState(() {
                                      groupSize = int.parse(val);
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Grouping Method", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 13)),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF4F7FC),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    isExpanded: true,
                                    value: groupingMethod,
                                    items: methods.map((m) {
                                      return DropdownMenuItem<String>(value: m, child: Text(m, style: const TextStyle(fontSize: 14)));
                                    }).toList(),
                                    onChanged: (val) {
                                      if (val != null) {
                                        setSheetState(() => groupingMethod = val);
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 35),
                    
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: (selectedCourseId != null && selectedDepartmentId != null && selectedSection != null && groupName != null && groupName!.isNotEmpty && groupSize > 0) 
                          ? () {
                              int totalStudents = currentSegmentCount;
                              int remainder = totalStudents % groupSize;

                              if (remainder != 0) {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text("Uneven Distribution"),
                                    content: Text("The group size does not evenly divide $totalStudents students. One group will have $remainder students. Proceed?"),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(ctx);
                                          Navigator.pop(context);
                                          _finalizeGroupCreation(groupName!, selectedCourseId!, groupSize, groupingMethod, departmentId: selectedDepartmentId, section: selectedSection);
                                        },
                                        child: const Text("Continue"),
                                      ),
                                    ],
                                  ),
                                );
                              } else {
                                Navigator.pop(context); // Close sheet
                                _finalizeGroupCreation(groupName!, selectedCourseId!, groupSize, groupingMethod, departmentId: selectedDepartmentId, section: selectedSection);
                              }
                          } : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF09AEF5),
                          disabledBackgroundColor: Colors.black12,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: (selectedCourseId != null && selectedDepartmentId != null && selectedSection != null && groupName != null && groupName!.isNotEmpty && groupSize > 0) ? 4 : 0,
                        ),
                        child: const Text("Generate Groups", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        );
      }
    );
  }

  void _finalizeGroupCreation(String title, dynamic course, int size, String method, {String? departmentId, String? section}) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Generating groups..."), behavior: SnackBarBehavior.floating));
      
      await _apiService.generateGroups(course['id'], size, departmentId: departmentId, section: section);
      
      _fetchData(); // Reload everything
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Successfully formed groups!"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        )
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F7FC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF05398F), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Manage Groups", 
          style: TextStyle(color: Color(0xFF05398F), fontSize: 22, fontWeight: FontWeight.bold)
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search_rounded, color: Color(0xFF05398F)), onPressed: () {}),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _error != null
          ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Active Course Groups",
                    style: TextStyle(fontSize: 16, color: Colors.black54, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 15),

                  ..._groups.map((groupSet) => _buildGroupSetTile(groupSet)).toList(),
                  
                  if (_groups.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 40.0),
                        child: Text("No groups formed yet.", style: TextStyle(color: Colors.black38)),
                      )
                    ),

                  const SizedBox(height: 100), // padding for FAB
                ],
              ),
            ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "form_groups_btn",
            onPressed: _showCreateGroupBottomSheet,
            backgroundColor: const Color(0xFF09AEF5),
            elevation: 4,
            child: const Icon(Icons.groups_rounded, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupSetTile(Map<String, dynamic> groupSet) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFAB47BC).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.book_rounded, color: Color(0xFFAB47BC), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      groupSet["course_title"], 
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                    ),
                    Text(
                      groupSet["course_code"], 
                      style: const TextStyle(color: Colors.black45, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 25),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (groupSet["groups"] as List).map<Widget>((g) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F7FC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black12.withOpacity(0.05))
                ),
                child: Text(
                  "${g['name']} (${(g['members'] as List).length} students)",
                  style: const TextStyle(color: Color(0xFF05398F), fontSize: 12, fontWeight: FontWeight.w600),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
