import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

/// FerretNotes - Notes with AI Assist
/// Placeholder implementation for AIFER v11 integration
class FerretNotesScreen extends StatefulWidget {
  const FerretNotesScreen({Key? key}) : super(key: key);

  @override
  State<FerretNotesScreen> createState() => _FerretNotesScreenState();
}

class _FerretNotesScreenState extends State<FerretNotesScreen> {
  final List<Note> _notes = [];
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();

  bool _isCreatingNote = false;
  bool _isAiAssistEnabled = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    // Simulate loading notes with placeholder data
    await Future.delayed(const Duration(milliseconds: 300));
    
    setState(() {
      _notes.clear();
      _notes.addAll(_getPlaceholderNotes());
    });
  }

  List<Note> _getPlaceholderNotes() {
    return [
      Note(
        id: '1',
        title: 'AIFER v11 Integration Plan',
        content: '''
Phase 1: UI Enhancements
- Ferret button
- Slide-out menu
- FERCompanion

Phase 2: Authentication
- Social login
- Biometric auth
- Sui blockchain
''',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
        color: Color(0xFF39FF14),
        tags: ['Integration', 'AIFER'],
      ),
      Note(
        id: '2',
        title: 'Meeting Notes',
        content: '''
Discussion points:
1. Project timeline
2. Tech stack review
3. Resource allocation

Action items:
- [ ] Define milestones
- [ ] Assign team members
- [ ] Set up CI/CD
''',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        color: Color(0xFF00E5FF),
        tags: ['Meeting', 'Planning'],
      ),
      Note(
        id: '3',
        title: 'Quick Reminder',
        content: 'Don\'t forget to test the build before committing!',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
        color: Color(0xFFB388FF),
        tags: ['Reminder'],
      ),
      Note(
        id: '4',
        title: 'Code Ideas',
        content: '''
Potential improvements:
- Add dark mode toggle
- Implement search filters
- Add note sharing
- Cloud sync integration
''',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        color: Color(0xFFFFD740),
        tags: ['Ideas', 'Development'],
      ),
    ];
  }

  List<Note> get _filteredNotes {
    if (_searchQuery.isEmpty) return _notes;
    return _notes
        .where((note) =>
            note.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            note.content.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  void _showCreateNoteDialog() {
    setState(() {
      _isCreatingNote = true;
      _titleController.clear();
      _noteController.clear();
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Create New Note'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 2.h),
              TextField(
                controller: _noteController,
                decoration: InputDecoration(
                  labelText: 'Content',
                  border: OutlineInputBorder(),
                ),
                maxLines: 10,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _isCreatingNote = false;
              });
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _createNote();
              setState(() {
                _isCreatingNote = false;
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF39FF14),
              foregroundColor: Colors.black,
            ),
            child: Text('Create'),
          ),
        ],
      ),
    );
  }

  void _createNote() {
    if (_titleController.text.isEmpty) return;

    final note = Note(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      content: _noteController.text,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      color: _getRandomColor(),
      tags: [],
    );

    setState(() {
      _notes.insert(0, note);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Note created: ${note.title}'),
        backgroundColor: Color(0xFF39FF14),
      ),
    );
  }

  void _showNoteDetail(Note note) {
    TextEditingController contentController = TextEditingController(text: note.content);
    TextEditingController titleController = TextEditingController(text: note.title);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(note.title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Last updated: ${_formatDate(note.updatedAt)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 2.h),
              TextField(
                controller: contentController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Content',
                ),
                maxLines: 10,
              ),
              SizedBox(height: 2.h),
              Row(
                children: [
                  Icon(Icons.auto_awesome, color: Color(0xFF39FF14)),
                  SizedBox(width: 1.w),
                  Text('AI Assist'),
                  Switch(
                    value: _isAiAssistEnabled,
                    onChanged: (value) {
                      setState(() {
                        _isAiAssistEnabled = value;
                      });
                    },
                  ),
                ],
              ),
              if (_isAiAssistEnabled)
                Container(
                  margin: EdgeInsets.only(top: 2.h),
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: Color(0xFF39FF14).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(2.w),
                    border: Border.all(color: Color(0xFF39FF14), width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '🦦 AI Assistant',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF39FF14),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'I can help you with:\n• Summarize your notes\n• Extract action items\n• Improve formatting\n• Generate ideas',
                        style: TextStyle(fontSize: 12),
                      ),
                      SizedBox(height: 1.h),
                      ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('AI summarization coming soon!'),
                            ),
                          );
                        },
                        icon: Icon(Icons.auto_awesome),
                        label: Text('Summarize'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF39FF14),
                          foregroundColor: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              _updateNote(note.id, titleController.text, contentController.text);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF39FF14),
              foregroundColor: Colors.black,
            ),
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _updateNote(String id, String title, String content) {
    final index = _notes.indexWhere((note) => note.id == id);
    if (index != -1) {
      setState(() {
        _notes[index] = _notes[index].copyWith(
          title: title,
          content: content,
          updatedAt: DateTime.now(),
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Note updated'),
          backgroundColor: Color(0xFF39FF14),
        ),
      );
    }
  }

  void _deleteNote(Note note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Note'),
        content: Text('Are you sure you want to delete "${note.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _notes.removeWhere((n) => n.id == note.id);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Note deleted'),
                  backgroundColor: Color(0xFF39FF14),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  Color _getRandomColor() {
    final colors = [
      Color(0xFF39FF14), // Neon green
      Color(0xFF00E5FF), // Cyan
      Color(0xFFB388FF), // Violet
      Color(0xFFFFD740), // Gold
      Color(0xFFFF0080), // Magenta
      Color(0xFF40C4FF), // Sky blue
    ];
    return colors[DateTime.now().millisecond % colors.length];
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
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.note, color: Color(0xFF39FF14)),
            SizedBox(width: 2.w),
            Text('FerretNotes'),
          ],
        ),
        backgroundColor: isDark ? Color(0xFF1A1A1A) : Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Show search bar
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$value coming soon!')),
              );
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'View All Notes',
                child: Text('View All Notes'),
              ),
              const PopupMenuItem(
                value: 'View Archived',
                child: Text('View Archived'),
              ),
              const PopupMenuItem(
                value: 'Import Notes',
                child: Text('Import Notes'),
              ),
              const PopupMenuItem(
                value: 'Export Notes',
                child: Text('Export Notes'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            margin: EdgeInsets.all(3.w),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search notes...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(3.w),
                ),
                filled: true,
                fillColor: isDark ? Color(0xFF0A0A0A) : Colors.grey[100],
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Notes grid
          Expanded(
            child: _filteredNotes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.note_add_outlined,
                          size: 15.w,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          _searchQuery.isEmpty
                              ? 'No notes yet'
                              : 'No results for "$_searchQuery"',
                          style: GoogleFonts.inter(
                            fontSize: 16.sp,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        if (_searchQuery.isEmpty)
                          ElevatedButton.icon(
                            onPressed: _showCreateNoteDialog,
                            icon: const Icon(Icons.add),
                            label: const Text('Create Note'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF39FF14),
                              foregroundColor: Colors.black,
                            ),
                          ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: EdgeInsets.all(2.w),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.8,
                      crossAxisSpacing: 2.w,
                      mainAxisSpacing: 2.h,
                    ),
                    itemCount: _filteredNotes.length,
                    itemBuilder: (context, index) {
                      return _buildNoteCard(_filteredNotes[index], isDark);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateNoteDialog,
        backgroundColor: Color(0xFF39FF14),
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget _buildNoteCard(Note note, bool isDark) {
    return GestureDetector(
      onTap: () => _showNoteDetail(note),
      onLongPress: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(note.title),
            content: Text('What would you like to do?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showNoteDetail(note);
                },
                child: Text('Edit'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteNote(note);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text('Delete'),
              ),
            ],
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Color(0xFF1A1A1A) : Colors.white,
          borderRadius: BorderRadius.circular(3.w),
          border: Border.all(
            color: note.color.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Color header
            Container(
              height: 3.h,
              decoration: BoxDecoration(
                color: note.color.withValues(alpha: 0.5),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(2.w),
                ),
              ),
            ),
            
            // Content
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(3.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      note.title,
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 1.h),
                    Expanded(
                      child: Text(
                        note.content,
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                        maxLines: 6,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 3.w, color: Colors.grey),
                        SizedBox(width: 1.w),
                        Text(
                          _formatDate(note.updatedAt),
                          style: GoogleFonts.inter(
                            fontSize: 10.sp,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    // Tags
                    if (note.tags.isNotEmpty) ...[
                      SizedBox(height: 1.h),
                      Wrap(
                        spacing: 1.w,
                        runSpacing: 0.5.h,
                        children: note.tags.take(3).map((tag) {
                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 2.w,
                              vertical: 0.3.h,
                            ),
                            decoration: BoxDecoration(
                              color: note.color.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(1.w),
                            ),
                            child: Text(
                              tag,
                              style: GoogleFonts.inter(
                                fontSize: 9.sp,
                                color: note.color,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Note data class
class Note {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Color color;
  final List<String> tags;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.color,
    required this.tags,
  });

  Note copyWith({
    String? title,
    String? content,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      color: color,
      tags: tags,
    );
  }
}