import 'dart:io';
import 'package:flutter/material.dart';
import 'package:microsoft_viewer/microsoft_viewer.dart';

class FileViewerScreen extends StatefulWidget {
  final String filePath;
  final String fileName;

  const FileViewerScreen({Key? key, required this.filePath, required this.fileName}) : super(key: key);

  @override
  _FileViewerScreenState createState() => _FileViewerScreenState();
}

class _FileViewerScreenState extends State<FileViewerScreen> {
  String? textContent;
  List<int>? fileBytes;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFile();
  }

  Future<void> _loadFile() async {
    try {
      final ext = widget.fileName.split('.').last.toLowerCase();
      final file = File(widget.filePath);
      
      if (ext == 'txt') {
        textContent = await file.readAsString();
      } else {
        fileBytes = await file.readAsBytes();
      }
    } catch (e) {
      textContent = "Error loading file: $e";
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ext = widget.fileName.split('.').last.toLowerCase();
    final isMicrosoftSupported = ['docx', 'pptx', 'xlsx', 'doc', 'ppt', 'xls'].contains(ext);

    return Scaffold(
      appBar: AppBar(title: Text(widget.fileName)),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : textContent != null
              ? SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(textContent!),
                )
              : (fileBytes != null && isMicrosoftSupported)
                  ? MicrosoftViewer(fileBytes!)
                  : const Center(child: Text("Unsupported file format for internal viewer.")),
    );
  }
}
