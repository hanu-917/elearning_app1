import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CreateQuizScreen extends StatefulWidget {
  final String currentCourseId;
  final List<dynamic>? allCourses;

  const CreateQuizScreen({
    super.key,
    required this.currentCourseId,
    this.allCourses,
  });

  @override
  State<CreateQuizScreen> createState() => _CreateQuizScreenState();
}

class QuestionModel {
  String text;
  int points;
  String type; // 'multiple_choice', 'true_false', 'short_answer', 'fill_blank'
  List<Map<String, dynamic>> options;

  QuestionModel({
    required this.text,
    required this.points,
    required this.type,
    required this.options,
  });
}

class _CreateQuizScreenState extends State<CreateQuizScreen> {
  final ApiService _apiService = ApiService();

  late String _selectedCourseId;
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _durationCtrl = TextEditingController(text: "30");
  final _attemptsCtrl = TextEditingController(text: "1");

  List<QuestionModel> _questions = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedCourseId = widget.currentCourseId;
  }

  void _showQuestionDialog({int? index}) async {
    final textCtrl = TextEditingController();
    final pointsCtrl = TextEditingController(text: "1");
    String selectedType = 'multiple_choice';
    List<Map<String, dynamic>> options = [
      {"text": "", "correct": false},
      {"text": "", "correct": false},
      {"text": "", "correct": false},
      {"text": "", "correct": false},
    ];

    if (index != null) {
      final q = _questions[index];
      textCtrl.text = q.text;
      pointsCtrl.text = q.points.toString();
      selectedType = q.type;
      options = q.options.map((o) => Map<String, dynamic>.from(o)).toList();
    }

    final result = await showDialog<QuestionModel>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          bool isFormValid() {
            if (textCtrl.text.trim().isEmpty) return false;
            if (selectedType == 'multiple_choice' || selectedType == 'true_false') {
              return options.any((o) => o["correct"] == true && (o["text"] as String).trim().isNotEmpty);
            }
            if (selectedType == 'short_answer' || selectedType == 'fill_blank') {
              return options.isNotEmpty && (options[0]["text"] as String).trim().isNotEmpty;
            }
            return false;
          }

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(index == null ? "Add Question" : "Edit Question", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF05398F))),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedType,
                      decoration: const InputDecoration(labelText: "Question Type", border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: 'multiple_choice', child: Text("Multiple Choice")),
                        DropdownMenuItem(value: 'true_false', child: Text("True / False")),
                        DropdownMenuItem(value: 'short_answer', child: Text("Short Answer")),
                        DropdownMenuItem(value: 'fill_blank', child: Text("Fill in the Blank")),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() {
                            selectedType = val;
                            if (selectedType == 'true_false') {
                              options = [
                                {"text": "True", "correct": true},
                                {"text": "False", "correct": false},
                              ];
                            } else if (selectedType == 'multiple_choice') {
                              options = [
                                {"text": "", "correct": false},
                                {"text": "", "correct": false},
                                {"text": "", "correct": false},
                                {"text": "", "correct": false},
                              ];
                            } else {
                              options = [
                                {"text": "", "correct": true},
                              ];
                            }
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                        controller: textCtrl,
                        onChanged: (val) => setDialogState(() {}),
                        decoration: const InputDecoration(
                            labelText: "Question Text*", border: OutlineInputBorder(), alignLabelWithHint: true),
                        maxLines: 3),
                    const SizedBox(height: 12),
                    TextField(
                        controller: pointsCtrl,
                        decoration: const InputDecoration(
                            labelText: "Points", border: OutlineInputBorder()),
                        keyboardType: TextInputType.number),
                    const SizedBox(height: 20),
                    
                    if (selectedType == 'multiple_choice') ...[
                      const Text("Options (mark the correct one):", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 8),
                      ...List.generate(options.length, (i) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Radio<int>(
                                value: i,
                                groupValue: options.indexWhere((o) => o["correct"] == true),
                                activeColor: const Color(0xFF09AEF5),
                                onChanged: (v) {
                                  setDialogState(() {
                                    for (var o in options) o["correct"] = false;
                                    options[i]["correct"] = true;
                                  });
                                },
                              ),
                              Expanded(
                                child: TextField(
                                  decoration: InputDecoration(
                                      hintText: "Option ${i + 1}",
                                      isDense: true,
                                      border: const OutlineInputBorder()),
                                  controller: TextEditingController.fromValue(TextEditingValue(
                                    text: options[i]["text"],
                                    selection: TextSelection.collapsed(offset: options[i]["text"].length),
                                  )),
                                  onChanged: (val) {
                                    options[i]["text"] = val;
                                    setDialogState(() {});
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ] else if (selectedType == 'true_false') ...[
                      const Text("Correct Answer:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<int>(
                              title: const Text("True"),
                              value: 0,
                              groupValue: options.indexWhere((o) => o["correct"] == true),
                              onChanged: (v) {
                                setDialogState(() {
                                  options[0]["correct"] = true;
                                  options[1]["correct"] = false;
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<int>(
                              title: const Text("False"),
                              value: 1,
                              groupValue: options.indexWhere((o) => o["correct"] == true),
                              onChanged: (v) {
                                setDialogState(() {
                                  options[0]["correct"] = false;
                                  options[1]["correct"] = true;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      const Text("Correct Answer:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 8),
                      TextField(
                        decoration: const InputDecoration(
                            hintText: "Enter the correct answer text",
                            border: OutlineInputBorder()),
                        onChanged: (val) {
                          options[0]["text"] = val;
                          setDialogState(() {});
                        },
                        controller: TextEditingController.fromValue(TextEditingValue(
                          text: options[0]["text"],
                          selection: TextSelection.collapsed(offset: options[0]["text"].length),
                        )),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("Cancel", style: TextStyle(color: Colors.grey))),
              ElevatedButton(
                  onPressed: isFormValid()
                      ? () {
                          Navigator.pop(
                            ctx,
                            QuestionModel(
                              text: textCtrl.text.trim(),
                              points: int.tryParse(pointsCtrl.text) ?? 1,
                              type: selectedType,
                              options: options,
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF05398F)),
                  child: Text(index == null ? "Add" : "Save", style: const TextStyle(color: Colors.white))),
            ],
          );
        },
      ),
    );

    if (result != null) {
      setState(() {
        if (index == null) {
          _questions.add(result);
        } else {
          _questions[index] = result;
        }
      });
    }
  }

  Future<void> _saveQuiz() async {
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Title is required"), backgroundColor: Colors.red));
      return;
    }

    setState(() => _isSaving = true);
    try {
      final quiz = await _apiService.createQuiz({
        "course_id": _selectedCourseId,
        "title": _titleCtrl.text.trim(),
        "description": _descCtrl.text.trim(),
        "duration_minutes": int.tryParse(_durationCtrl.text) ?? 30,
        "max_attempts": int.tryParse(_attemptsCtrl.text) ?? 1,
      });

      final quizId = quiz['id'].toString();

      for (int i = 0; i < _questions.length; i++) {
        final q = _questions[i];
        final validOptions = q.options
            .where((o) => (o["text"] as String).trim().isNotEmpty)
            .toList();

        await _apiService.addQuizQuestion(quizId, {
          "question_text": q.text,
          "question_type": q.type,
          "points": q.points,
          "order_index": i,
          "options": validOptions
              .map((o) => {"option_text": o["text"], "is_correct": o["correct"]})
              .toList(),
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Quiz created successfully!"), backgroundColor: Colors.green));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        title: const Text("Create Quiz", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        systemOverlayStyle: SystemUiOverlayStyle.light,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF09AEF5), Color(0xFF05398F)]),
          ),
        ),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (widget.allCourses != null && widget.allCourses!.isNotEmpty)
                  DropdownButtonFormField<String>(
                    value: _selectedCourseId,
                    decoration: const InputDecoration(
                      labelText: "Course",
                      border: OutlineInputBorder(),
                    ),
                    items: widget.allCourses!.map((course) {
                      return DropdownMenuItem<String>(
                        value: course['id'].toString(),
                        child: Text(
                          course['title'] ?? course['course_code'] ?? 'Unknown Course',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedCourseId = val;
                        });
                      }
                    },
                  ),
                const SizedBox(height: 16),
                TextField(
                    controller: _titleCtrl,
                    decoration: const InputDecoration(
                        labelText: "Quiz Title*", border: OutlineInputBorder())),
                const SizedBox(height: 16),
                TextField(
                    controller: _descCtrl,
                    decoration: const InputDecoration(
                        labelText: "Description", border: OutlineInputBorder()),
                    maxLines: 3),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _durationCtrl,
                        decoration: const InputDecoration(
                            labelText: "Duration (min)",
                            border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _attemptsCtrl,
                        decoration: const InputDecoration(
                            labelText: "Max Attempts",
                            border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Questions",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    ElevatedButton.icon(
                      onPressed: () => _showQuestionDialog(),
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text("Add Question", style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF05398F),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_questions.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Center(
                        child: Text("No questions added yet.",
                            style: TextStyle(color: Colors.grey))),
                  )
                else
                  ...List.generate(_questions.length, (index) {
                    final q = _questions[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        onTap: () => _showQuestionDialog(index: index),
                        title: Text(q.text, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("${_formatType(q.type)} • ${q.points} Points"),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _questions.removeAt(index);
                            });
                          },
                        ),
                      ),
                    );
                  }),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _saveQuiz,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF05398F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Save Quiz",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
    );
  }
  String _formatType(String type) {
    switch (type) {
      case 'multiple_choice': return "Multiple Choice";
      case 'true_false': return "True / False";
      case 'short_answer': return "Short Answer";
      case 'fill_blank': return "Fill in the Blank";
      default: return type;
    }
  }
}
