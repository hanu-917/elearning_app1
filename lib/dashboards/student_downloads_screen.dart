import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:math';
import '../services/api_service.dart';

class StudentDownloadsScreen extends StatefulWidget {
  const StudentDownloadsScreen({super.key});

  @override
  State<StudentDownloadsScreen> createState() => _StudentDownloadsScreenState();
}

class _StudentDownloadsScreenState extends State<StudentDownloadsScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Documents', 'Videos', 'Images'];
  late ScrollController _scrollController;
  List<FileSystemEntity> _downloadedFiles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _loadDownloadedFiles();
  }

  Future<void> _loadDownloadedFiles() async {
    setState(() => _isLoading = true);
    try {
      Directory directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download/ELMS');
      } else {
        directory = Directory('${(await getApplicationDocumentsDirectory()).path}/ELMS');
      }

      if (await directory.exists()) {
        final List<FileSystemEntity> files = directory.listSync();
        if (mounted) {
          setState(() {
            _downloadedFiles = files.where((f) => f is File).toList();
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _downloadedFiles = [];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error loading downloads: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    var i = (log(bytes) / log(1024)).floor();
    return ((bytes / pow(1024, i)).toStringAsFixed(1)) + ' ' + suffixes[i];
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(), 
        slivers: [
          // The SliverAppBar that contains the Storage widget and expands when dragged down
          SliverAppBar(
            backgroundColor: const Color(0xFFF4F7FC),
            elevation: 0,
            pinned: true,
            floating: false,
            title: const Text(
              "Downloads",
              style: TextStyle(color: Color(0xFF05398F), fontSize: 24, fontWeight: FontWeight.bold)
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search_rounded, color: Color(0xFF05398F)),
                onPressed: () {},
              ),
            ],
          ),
          
          // Sticky Filter Chips Below App Bar
          SliverPersistentHeader(
            pinned: true,
            delegate: _FilterHeaderDelegate(
              child: Container(
                color: const Color(0xFFF4F7FC),
                width: double.infinity,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    children: _filters.map((filter) {
                      bool isSelected = _selectedFilter == filter;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedFilter = filter;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF09AEF5) : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              )
                            ],
                          ),
                          child: Text(
                            filter,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black54,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),

          // Search Results / Download List
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            sliver: _isLoading 
              ? const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator())))
              : Builder(
                  builder: (context) {
                    final filteredFiles = _downloadedFiles.where((f) {
                      if (_selectedFilter == 'All') return true;
                      String ext = f.path.split('.').last.toLowerCase();
                      if (_selectedFilter == 'Documents') return ['pdf', 'doc', 'docx', 'txt', 'xls', 'xlsx', 'ppt', 'pptx'].contains(ext);
                      if (_selectedFilter == 'Videos') return ['mp4', 'avi', 'mov'].contains(ext);
                      if (_selectedFilter == 'Images') return ['jpg', 'jpeg', 'png', 'gif'].contains(ext);
                      return false;
                    }).toList();

                    if (filteredFiles.isEmpty) {
                      return const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(40), child: Text("No downloaded files found", style: TextStyle(color: Colors.black38)))));
                    }

                    return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final file = filteredFiles[index] as File;
                        final name = file.path.split(Platform.pathSeparator).last;
                        return _buildDownloadFileTile(
                          name, 
                          _formatBytes(file.lengthSync()), 
                          "Local Device",
                          file.path,
                        );
                      },
                      childCount: filteredFiles.length,
                    ),
                  );
                },
              ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Widget _buildStorageStatus() {
    int totalBytes = 0;
    for (var f in _downloadedFiles) {
      if (f is File) totalBytes += f.lengthSync();
    }
    double progress = (totalBytes / (5 * 1024 * 1024 * 1024)).clamp(0.0, 1.0); // Assume 5GB limit for UI

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF09AEF5), Color(0xFF05398F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF05398F).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
               Text("Local Storage Used", style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
               Icon(Icons.sd_storage_rounded, color: Colors.white70, size: 20)
            ],
          ),
          const SizedBox(height: 5),
          Text(_formatBytes(totalBytes), style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: progress, 
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            borderRadius: BorderRadius.circular(5),
            minHeight: 6,
          ),
          const SizedBox(height: 8),
          const Text("Saved for Offline Viewing", style: TextStyle(color: Colors.white60, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildDateSection(String date) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 10.0),
      child: Text(
        date, 
        style: const TextStyle(
          fontSize: 15, 
          fontWeight: FontWeight.bold, 
          color: Colors.black87
        )
      ),
    );
  }

  Widget _buildDownloadFileTile(String name, String size, String author, String path) {
    IconData icon = _getIconForFile(name);
    Color iconColor = _getColorForFile(name);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          try {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Opening file...")));
            final api = ApiService();
            await api.downloadAndOpenFile(path, context: context, fileName: name);
          } catch (e) {
            if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87), overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(size, style: const TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        const Text("•", style: TextStyle(color: Colors.black38, fontSize: 12)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(author, style: const TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForFile(String name) {
    String ext = name.toLowerCase().split('.').last;
    if (ext.contains('pdf')) return Icons.picture_as_pdf_rounded;
    if (ext.contains('doc') || ext.contains('txt')) return Icons.description_rounded;
    if (ext.contains('mp4') || ext.contains('avi') || ext.contains('mov')) return Icons.video_collection_rounded;
    if (ext.contains('zip') || ext.contains('rar') || ext.contains('7z')) return Icons.folder_zip_rounded;
    if (ext.contains('jpg') || ext.contains('jpeg') || ext.contains('png') || ext.contains('gif')) return Icons.image_rounded;
    if (ext.contains('ppt') || ext.contains('pptx')) return Icons.slideshow_rounded;
    if (ext.contains('xls') || ext.contains('xlsx') || ext.contains('csv')) return Icons.table_chart_rounded;
    if (ext.contains('mp3') || ext.contains('wav') || ext.contains('aac')) return Icons.audiotrack_rounded;
    
    return Icons.insert_drive_file_rounded;
  }

  Color _getColorForFile(String name) {
    String ext = name.toLowerCase().split('.').last;
    if (ext.contains('pdf')) return Colors.red.shade600;
    if (ext.contains('doc') || ext.contains('txt')) return Colors.blue.shade700;
    if (ext.contains('mp4') || ext.contains('avi') || ext.contains('mov')) return Colors.deepPurple;
    if (ext.contains('zip') || ext.contains('rar') || ext.contains('7z')) return Colors.orange.shade800;
    if (ext.contains('jpg') || ext.contains('jpeg') || ext.contains('png') || ext.contains('gif')) return Colors.teal;
    if (ext.contains('ppt') || ext.contains('pptx')) return Colors.orange.shade900;
    if (ext.contains('xls') || ext.contains('xlsx') || ext.contains('csv')) return Colors.green.shade700;
    if (ext.contains('mp3') || ext.contains('wav') || ext.contains('aac')) return Colors.pink.shade400;

    return Colors.blueGrey;
  }
}

// Simple Delegate to keep the Filter Header pinned to the top below the AppBar
class _FilterHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _FilterHeaderDelegate({required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 60.0;

  @override
  double get minExtent => 60.0;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}

