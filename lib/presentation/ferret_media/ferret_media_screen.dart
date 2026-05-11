import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

class FerretMediaScreen extends StatefulWidget {
  const FerretMediaScreen({super.key});

  @override
  State<FerretMediaScreen> createState() => _FerretMediaScreenState();
}

class _FerretMediaScreenState extends State<FerretMediaScreen> with TickerProviderStateMixin {
  int _selectedTab = 0; // 0: Music, 1: Videos, 2: Podcasts
  bool _isPlaying = false;
  double _progress = 0.35;

  final List<MediaItem> _musicItems = [
    MediaItem(
      title: 'Neon Dreams',
      artist: 'Quantum Beats',
      album: 'Digital Horizon',
      duration: '3:45',
      type: MediaType.music,
    ),
    MediaItem(
      title: 'Neural pathways',
      artist: 'Synth Wave',
      album: 'AI Rhythms',
      duration: '4:12',
      type: MediaType.music,
    ),
    MediaItem(
      title: 'Moonlit Transmission',
      artist: 'Cyber Ferret',
      album: 'Mesh Network',
      duration: '3:28',
      type: MediaType.music,
    ),
    MediaItem(
      title: 'Echoes of Tomorrow',
      artist: 'Neural Sync',
      album: 'Future Sounds',
      duration: '4:56',
      type: MediaType.music,
    ),
    MediaItem(
      title: 'Quantum Leaps',
      artist: 'Bit Stream',
      album: 'Digital Dreams',
      duration: '3:19',
      type: MediaType.music,
    ),
  ];

  final List<MediaItem> _videoItems = [
    MediaItem(
      title: 'FER Network Tutorial',
      artist: 'Official Channel',
      album: 'Educational',
      duration: '15:30',
      type: MediaType.video,
    ),
    MediaItem(
      title: 'Quantum Security Demo',
      artist: 'Security Team',
      album: 'Tech Talks',
      duration: '22:45',
      type: MediaType.video,
    ),
    MediaItem(
      title: 'Mesh Network Explained',
      artist: 'Dev Team',
      album: 'Architecture',
      duration: '18:20',
      type: MediaType.video,
    ),
    MediaItem(
      title: 'AiFER v11 Tour',
      artist: 'Product Team',
      album: 'Release Notes',
      duration: '10:15',
      type: MediaType.video,
    ),
  ];

  final List<MediaItem> _podcastItems = [
    MediaItem(
      title: 'The Future of Decentralization',
      artist: 'FER Talks',
      album: 'Episode 45',
      duration: '45:30',
      type: MediaType.podcast,
    ),
    MediaItem(
      title: 'Quantum Computing in Practice',
      artist: 'Tech Insights',
      album: 'Episode 112',
      duration: '52:20',
      type: MediaType.podcast,
    ),
    MediaItem(
      title: 'Building Secure Networks',
      artist: 'Security Now',
      album: 'Episode 89',
      duration: '38:15',
      type: MediaType.podcast,
    ),
  ];

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  List<MediaItem> get _currentItems {
    switch (_selectedTab) {
      case 0:
        return _musicItems;
      case 1:
        return _videoItems;
      case 2:
        return _podcastItems;
      default:
        return _musicItems;
    }
  }

  String get _tabLabel {
    switch (_selectedTab) {
      case 0:
        return 'Music';
      case 1:
        return 'Videos';
      case 2:
        return 'Podcasts';
      default:
        return 'Music';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        title: Text(
          '🦦 Ferret Media',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 6.w, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, size: 5.w, color: Colors.white),
            onPressed: () {
              // Search functionality placeholder
            },
          ),
          SizedBox(width: 2.w),
        ],
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            decoration: const BoxDecoration(
              color: Color(0xFF1E1E1E),
              border: Border(
                bottom: BorderSide(color: Color(0xFF00E5FF), width: 2),
              ),
            ),
            child: Row(
              children: [
                _buildTabButton(0, 'Music'),
                _buildTabButton(1, 'Videos'),
                _buildTabButton(2, 'Podcasts'),
              ],
            ),
          ),
          // Media List
          Expanded(
            child: Container(
              padding: EdgeInsets.all(2.w),
              child: ListView.separated(
                itemCount: _currentItems.length,
                separatorBuilder: (context, index) => Divider(
                  color: Colors.grey[800],
                  thickness: 0.5,
                ),
                itemBuilder: (context, index) {
                  return _buildMediaItem(_currentItems[index], index);
                },
              ),
            ),
          ),
          // Now Playing Bar
          _buildNowPlayingBar(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Add new media functionality placeholder
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Import media - Feature coming soon'),
              backgroundColor: Color(0xFF39FF14),
            ),
          );
        },
        backgroundColor: const Color(0xFF39FF14),
        label: Text(
          'Import',
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        icon: Icon(Icons.add, size: 5.w, color: Colors.black),
      ),
    );
  }

  Widget _buildTabButton(int index, String label) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = index;
          });
        },
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 1.w),
          padding: EdgeInsets.symmetric(vertical: 1.5.h),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF39FF14).withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? const Color(0xFF39FF14) : Colors.transparent,
              width: 2,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? const Color(0xFF39FF14) : Colors.grey[400],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMediaItem(MediaItem item, int index) {
    IconData typeIcon;
    Color typeColor;

    switch (item.type) {
      case MediaType.music:
        typeIcon = Icons.music_note;
        typeColor = const Color(0xFF39FF14);
        break;
      case MediaType.video:
        typeIcon = Icons.play_circle_outline;
        typeColor = const Color(0xFF00E5FF);
        break;
      case MediaType.podcast:
        typeIcon = Icons.podcasts;
        typeColor = const Color(0xFF7B61FF);
        break;
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF2A2A2A).withOpacity(0.5),
            const Color(0xFF1E1E1E).withOpacity(0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: typeColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        leading: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            if (index == 0 && _selectedTab == 0) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: typeColor, width: 2),
                  ),
                  child: Icon(typeIcon, color: typeColor, size: 6.w),
                ),
              );
            }
            return Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: typeColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: typeColor, width: 2),
              ),
              child: Icon(typeIcon, color: typeColor, size: 6.w),
            );
          },
        ),
        title: Text(
          item.title,
          style: GoogleFonts.inter(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${item.artist} • ${item.album}',
              style: GoogleFonts.inter(
                fontSize: 10.sp,
                fontWeight: FontWeight.w400,
                color: Colors.grey[400],
              ),
            ),
            SizedBox(height: 0.3.h),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 3.w,
                  color: typeColor,
                ),
                SizedBox(width: 1.w),
                Text(
                  item.duration,
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                    color: typeColor,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                _isPlaying && _selectedTab == 0 && index == 0
                    ? Icons.pause_circle_filled
                    : Icons.play_circle_outline,
                color: const Color(0xFF39FF14),
                size: 7.w,
              ),
              onPressed: () {
                setState(() {
                  _isPlaying = !_isPlaying;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_isPlaying ? 'Playing: ${item.title}' : 'Paused'),
                    backgroundColor: const Color(0xFF39FF14),
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.more_vert, color: Colors.grey[400], size: 5.w),
              onPressed: () {
                // More options placeholder
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Media options coming soon'),
                    backgroundColor: Colors.grey,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNowPlayingBar() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        border: Border(
          top: BorderSide(color: const Color(0xFF39FF14), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF39FF14).withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          // Album Art Placeholder
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF39FF14), Color(0xFF00E5FF)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.music_note, color: Colors.black, size: 6.w),
          ),
          SizedBox(width: 3.w),
          // Track Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Neon Dreams',
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Quantum Beats',
                  style: GoogleFonts.inter(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[400],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Play/Pause Button
          IconButton(
            icon: Icon(
              _isPlaying ? Icons.pause : Icons.play_arrow,
              color: const Color(0xFF39FF14),
              size: 7.w,
            ),
            onPressed: () {
              setState(() {
                _isPlaying = !_isPlaying;
              });
            },
          ),
          // Next Button
          IconButton(
            icon: Icon(Icons.skip_next, color: Colors.grey[400], size: 6.w),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Next track'),
                  backgroundColor: Colors.grey,
                ),
              );
            },
          ),
          SizedBox(width: 2.w),
        ],
      ),
    );
  }
}

enum MediaType { music, video, podcast }

class MediaItem {
  final String title;
  final String artist;
  final String album;
  final String duration;
  final MediaType type;

  MediaItem({
    required this.title,
    required this.artist,
    required this.album,
    required this.duration,
    required this.type,
  });
}