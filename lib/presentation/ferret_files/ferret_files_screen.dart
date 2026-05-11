import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

/// FerretFiles - File Manager Screen
/// Placeholder implementation for AIFER v11 integration
class FerretFilesScreen extends StatefulWidget {
  const FerretFilesScreen({Key? key}) : super(key: key);

  @override
  State<FerretFilesScreen> createState() => _FerretFilesScreenState();
}

class _FerretFilesScreenState extends State<FerretFilesScreen> {
  final List<FileSystemItem> _items = [];
  String _currentPath = '/';
  bool _isLoading = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate file loading with placeholder data
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _items.clear();
      _items.addAll(_getPlaceholderFiles());
      _isLoading = false;
    });
  }

  List<FileSystemItem> _getPlaceholderFiles() {
    return [
      FileSystemItem(
        name: 'Documents',
        type: FileType.folder,
        size: null,
        modifiedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      FileSystemItem(
        name: 'Downloads',
        type: FileType.folder,
        size: null,
        modifiedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      FileSystemItem(
        name: 'Images',
        type: FileType.folder,
        size: null,
        modifiedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      FileSystemItem(
        name: 'app_document.pdf',
        type: FileType.file,
        size: 2048576, // 2MB
        modifiedAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      FileSystemItem(
        name: 'project_notes.txt',
        type: FileType.file,
        size: 1024, // 1KB
        modifiedAt: DateTime.now().subtract(const Duration(hours: 10)),
      ),
      FileSystemItem(
        name: 'configuration.json',
        type: FileType.file,
        size: 512, // 512B
        modifiedAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
      FileSystemItem(
        name: 'backup.zip',
        type: FileType.file,
        size: 10485760, // 10MB
        modifiedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];
  }

  List<FileSystemItem> get _filteredItems {
    if (_searchQuery.isEmpty) return _items;
    return _items
        .where((item) =>
            item.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  void _onItemTap(FileSystemItem item) {
    if (item.type == FileType.folder) {
      setState(() {
        _currentPath = '$_currentPath${item.name}/';
      });
      // In full implementation, navigate to folder
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Opening folder: ${item.name}'),
          duration: const Duration(seconds: 1),
        ),
      );
    } else {
      // Open file
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Opening file: ${item.name}'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result != null && result.files.single.path != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Selected: ${result.files.single.name}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatFileSize(int? bytes) {
    if (bytes == null) return '-';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1073741824) return '${(bytes / 1048576).toStringAsFixed(1)} MB';
    return '${(bytes / 1073741824).toStringAsFixed(1)} GB';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.folder, color: Color(0xFF39FF14)),
            SizedBox(width: 2.w),
            Text('FerretFiles'),
          ],
        ),
        backgroundColor: isDark ? Color(0xFF1A1A1A) : Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: FileSearchDelegate(_items, _onItemTap),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _pickFile,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$value coming soon!')),
              );
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'Create New Folder',
                child: Text('Create New Folder'),
              ),
              const PopupMenuItem(
                value: 'Create New File',
                child: Text('Create New File'),
              ),
              const PopupMenuItem(
                value: 'Sort By',
                child: Text('Sort By'),
              ),
              const PopupMenuItem(
                value: 'View Settings',
                child: Text('View Settings'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Path bar
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            color: isDark ? Color(0xFF0A0A0A) : Colors.grey[100],
            child: Row(
              children: [
                Text(
                  _currentPath,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: isDark ? Colors.white54 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),

          // File list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.folder_open,
                              size: 15.w,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'No files found'
                                  : 'No results for "$_searchQuery"',
                              style: GoogleFonts.inter(
                                fontSize: 16.sp,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            if (_searchQuery.isEmpty)
                              ElevatedButton.icon(
                                onPressed: _pickFile,
                                icon: const Icon(Icons.add),
                                label: const Text('Add File'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF39FF14),
                                  foregroundColor: Colors.black,
                                ),
                              ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(2.w),
                        itemCount: _filteredItems.length,
                        itemBuilder: (context, index) {
                          return _buildFileItem(_filteredItems[index], isDark);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickFile,
        backgroundColor: Color(0xFF39FF14),
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget _buildFileItem(FileSystemItem item, bool isDark) {
    final icon = item.type == FileType.folder
        ? Icons.folder
        : _getFileIcon(item.name);

    final iconColor = item.type == FileType.folder
        ? Color(0xFF39FF14)
        : isDark
            ? Colors.white70
            : Colors.black87;

    return GestureDetector(
      onTap: () => _onItemTap(item),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 0.5.h),
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: isDark ? Color(0xFF1A1A1A) : Colors.white,
          borderRadius: BorderRadius.circular(2.w),
          border: Border.all(
            color: isDark ? Colors.white12 : Colors.black12,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 10.w,
              height: 10.w,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(2.w),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 5.w,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    '${_formatFileSize(item.size)} • ${_formatDate(item.modifiedAt)}',
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      case 'mp3':
      case 'wav':
        return Icons.audio_file;
      case 'mp4':
      case 'avi':
        return Icons.video_file;
      case 'zip':
      case 'rar':
      case '7z':
        return Icons.folder_zip;
      case 'txt':
        return Icons.text_snippet;
      case 'json':
      case 'xml':
        return Icons.code;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

/// File system item data class
class FileSystemItem {
  final String name;
  final FileType type;
  final int? size;
  final DateTime modifiedAt;

  FileSystemItem({
    required this.name,
    required this.type,
    this.size,
    required this.modifiedAt,
  });
}

/// File type enum
enum FileType {
  folder,
  file,
}

/// File search delegate
class FileSearchDelegate extends SearchDelegate<String> {
  final List<FileSystemItem> items;
  final Function(FileSystemItem) onItemTap;

  FileSearchDelegate(this.items, this.onItemTap);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    final results = items
        .where((item) =>
            item.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    if (results.isEmpty) {
      return const Center(
        child: Text('No files found'),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final item = results[index];
        return ListTile(
          leading: Icon(
            item.type == FileType.folder ? Icons.folder : Icons.insert_drive_file,
            color: Color(0xFF39FF14),
          ),
          title: Text(item.name),
          subtitle: Text(item.type == FileType.folder ? 'Folder' : 'File'),
          onTap: () {
            onItemTap(item);
            close(context, item.name);
          },
        );
      },
    );
  }
}