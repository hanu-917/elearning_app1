import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:open_filex/open_filex.dart';
import '../widgets/custom_microsoft_viewer.dart';

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
  bool isLandscape = false;
  bool isPdfError = false;
  String pdfErrorMessage = "";

  @override
  void initState() {
    super.initState();
    _loadFile();
    // Default to portrait but let user rotate if they want
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    // Reset orientation to system default when leaving the viewer
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
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

  void _toggleOrientation() {
    setState(() {
      isLandscape = !isLandscape;
      if (isLandscape) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      } else {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
        ]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ext = widget.fileName.split('.').last.toLowerCase();
    final isMicrosoftSupported = ['docx', 'pptx', 'xlsx', 'doc', 'ppt', 'xls'].contains(ext);
    final isImage = ['jpg', 'jpeg', 'png', 'gif', 'bmp'].contains(ext);
    final isPdf = ext == 'pdf';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.fileName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
        systemOverlayStyle: SystemUiOverlayStyle.light,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF09AEF5), Color(0xFF05398F)]),
          ),
        ),
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new_rounded, color: Colors.white),
            tooltip: "Open in System Viewer",
            onPressed: () async {
              try {
                final result = await OpenFilex.open(widget.filePath);
                if (result.type != ResultType.done) {
                  throw Exception(result.message);
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Could not open in system viewer: $e")),
                  );
                }
              }
            },
          ),
          if (isPdf)
            IconButton(
              icon: Icon(isLandscape ? Icons.screen_lock_portrait_rounded : Icons.screen_lock_landscape_rounded, color: Colors.white),
              onPressed: _toggleOrientation,
              tooltip: isLandscape ? "Switch to Portrait" : "Switch to Landscape",
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : textContent != null
              ? SizedBox.expand(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      textContent!,
                      style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
                    ),
                  ),
                )
              : (fileBytes != null && isMicrosoftSupported)
                  ? SizedBox.expand(
                      child: CustomMicrosoftViewer(fileBytes!),
                    )
                  : isImage
                      ? _buildImageViewer()
                      : isPdf
                          ? _buildPdfViewer()
                          : const Center(child: Text("Unsupported file format for internal viewer.")),
    );
  }

  Widget _buildImageViewer() {
    return SizedBox.expand(
      child: InteractiveViewer(
        boundaryMargin: const EdgeInsets.all(20),
        minScale: 1.0,
        maxScale: 5.0,
        child: Center(
          child: Image.file(
            File(widget.filePath),
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Center(child: Text("Could not load image")),
          ),
        ),
      ),
    );
  }

  Widget _buildPdfViewer() {
    if (isPdfError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 60, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text("Failed to render PDF", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(pdfErrorMessage, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54)),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                await OpenFilex.open(widget.filePath);
              },
              icon: const Icon(Icons.open_in_new_rounded),
              label: const Text("Open in System Viewer"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF05398F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      );
    }

    return PDFView(
      filePath: widget.filePath,
      enableSwipe: true,
      swipeHorizontal: false,
      autoSpacing: true, // Set to true for better spacing
      pageFling: true,
      pageSnap: true,
      defaultPage: 0,
      fitPolicy: FitPolicy.BOTH,
      preventLinkNavigation: false,
      onRender: (pages) {
        debugPrint("PDF Rendered with $pages pages");
      },
      onError: (error) {
        debugPrint("PDF Error: $error");
        if (mounted) {
          setState(() {
            isPdfError = true;
            pdfErrorMessage = error.toString();
          });
        }
      },
      onPageError: (page, error) {
        debugPrint("PDF Page Error on $page: $error");
      },
    );
  }
}
