import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

/// FerretGallery - Photo Viewer
/// Placeholder implementation for AIFER v11 integration
class FerretGalleryScreen extends StatefulWidget {
  const FerretGalleryScreen({Key? key}) : super(key: key);

  @override
  State<FerretGalleryScreen> createState() => _FerretGalleryScreenState();
}

class _FerretGalleryScreenState extends State<FerretGalleryScreen> {
  final List<GalleryItem> _items = [];

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  void _loadImages() {
    setState(() {
      _items.clear();
      _items.addAll(_getPlaceholderImages());
    });
  }

  List<GalleryItem> _getPlaceholderImages() {
    return [
      GalleryItem(
        id: '1',
        name: 'Screenshot_2024.png',
        date: DateTime.now().subtract(Duration(hours: 2)),
        size: '2.4 MB',
        type: 'Image',
      ),
      GalleryItem(
        id: '2',
        name: 'AiFER_Os_Screenshot.jpg',
        date: DateTime.now().subtract(Duration(days: 1)),
        size: '1.8 MB',
        type: 'Image',
      ),
      GalleryItem(
        id: '3',
        name: 'profile_picture.png',
        date: DateTime.now().subtract(Duration(days: 3)),
        size: '512 KB',
        type: 'Image',
      ),
      GalleryItem(
        id: '4',
        name: 'network_diagram.svg',
        date: DateTime.now().subtract(Duration(days: 5)),
        size: '256 KB',
        type: 'Vector',
      ),
      GalleryItem(
        id: '5',
        name: 'ferret_avatar.gif',
        date: DateTime.now().subtract(Duration(days: 7)),
        size: '1.2 MB',
        type: 'GIF',
      ),
      GalleryItem(
        id: '6',
        name: 'screenshot_game.png',
        date: DateTime.now().subtract(Duration(days: 10)),
        size: '3.1 MB',
        type: 'Image',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.photo_library, color: Color(0xFFE040FB)),
            SizedBox(width: 2.w),
            Text('FerretGallery'),
          ],
        ),
        backgroundColor: isDark ? Color(0xFF0A0A0A) : Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Search coming soon!')),
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$value coming soon!')),
              );
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'By Date', child: Text('Sort by Date')),
              const PopupMenuItem(value: 'By Size', child: Text('Sort by Size')),
              const PopupMenuItem(value: 'By Type', child: Text('Sort by Type')),
            ],
          ),
        ],
      ),
      backgroundColor: isDark ? Color(0xFF0A0A0A) : Colors.white,
      body: _items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.photo_library_outlined,
                    size: 15.w,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'No images yet',
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: EdgeInsets.all(2.w),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 2.w,
                mainAxisSpacing: 2.h,
                childAspectRatio: 1.0,
              ),
              itemCount: _items.length,
              itemBuilder: (context, index) {
                return _buildImageCard(_items[index], isDark);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Image picker coming soon!'),
              backgroundColor: Color(0xFFE040FB),
            ),
          );
        },
        backgroundColor: Color(0xFFE040FB),
        child: const Icon(Icons.add_a_photo, color: Colors.white),
      ),
    );
  }

  Widget _buildImageCard(GalleryItem item, bool isDark) {
    final colors = {
      'Image': Color(0xFFE040FB),
      'Vector': Color(0xFFFFAB40),
      'GIF': Color(0xFFFF5252),
    };
    final color = colors[item.type] ?? Color(0xFFE040FB);

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(item.name),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2.w),
                  ),
                  child: Icon(
                    Icons.image,
                    size: 15.w,
                    color: color,
                  ),
                ),
                SizedBox(height: 2.h),
                _buildInfoRow('Type', item.type),
                _buildInfoRow('Size', item.size),
                _buildInfoRow('Date', _formatDate(item.date)),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
              ),
            ],
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(2.w),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image,
              size: 8.w,
              color: color,
            ),
            SizedBox(height: 1.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 1.w),
              child: Text(
                item.name,
                style: GoogleFonts.inter(
                  fontSize: 9.sp,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class GalleryItem {
  final String id;
  final String name;
  final DateTime date;
  final String size;
  final String type;

  GalleryItem({
    required this.id,
    required this.name,
    required this.date,
    required this.size,
    required this.type,
  });
}