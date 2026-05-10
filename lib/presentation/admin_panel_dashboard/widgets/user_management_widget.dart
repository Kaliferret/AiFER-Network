import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

/// User Management Widget for admin user oversight and activity monitoring
class UserManagementWidget extends StatelessWidget {
  final Map<String, dynamic> userStats;
  final List<Map<String, dynamic>> recentActivity;
  final VoidCallback onRefresh;

  const UserManagementWidget({
    Key? key,
    required this.userStats,
    required this.recentActivity,
    required this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Statistics Overview
            _buildUserStatsSection(context),

            SizedBox(height: 6.w),

            // Recent Activity Feed
            _buildRecentActivitySection(context),

            SizedBox(height: 6.w),

            // User Management Tools
            _buildManagementToolsSection(context),

            SizedBox(height: 6.w),

            // Authentication Status
            _buildAuthStatusSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildUserStatsSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withAlpha(51),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'User Statistics',
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          SizedBox(height: 4.w),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  'Gaming Sessions',
                  '${userStats['total_gaming_sessions'] ?? 0}',
                  Icons.sports_esports,
                  Colors.purple,
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: _buildStatItem(
                  context,
                  'Messages Sent',
                  '${userStats['total_messages'] ?? 0}',
                  Icons.message,
                  Colors.blue,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.w),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  'Explorations',
                  '${userStats['exploration_sessions'] ?? 0}',
                  Icons.explore,
                  Colors.green,
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: _buildStatItem(
                  context,
                  'Active Now',
                  '${recentActivity.length}',
                  Icons.people_alt,
                  Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withAlpha(77),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 8.w,
          ),
          SizedBox(height: 2.w),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivitySection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withAlpha(51),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Activity',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).textTheme.titleMedium?.color,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Implement view all functionality
                },
                child: Text(
                  'View All',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.w),
          if (recentActivity.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.all(8.w),
                child: Column(
                  children: [
                    Icon(
                      Icons.timeline,
                      size: 12.w,
                      color: Theme.of(context).dividerColor,
                    ),
                    SizedBox(height: 2.w),
                    Text(
                      'No recent activity',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentActivity.take(5).length,
              separatorBuilder: (context, index) => Divider(
                color: Theme.of(context).dividerColor.withAlpha(77),
              ),
              itemBuilder: (context, index) {
                final activity = recentActivity[index];
                return _buildActivityItem(context, activity);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
      BuildContext context, Map<String, dynamic> activity) {
    final name = activity['full_name'] ?? 'Unknown User';
    final email = activity['email'] ?? '';
    final timestamp =
        DateTime.tryParse(activity['created_at'] ?? '') ?? DateTime.now();

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.w),
      child: Row(
        children: [
          CircleAvatar(
            radius: 5.w,
            backgroundColor: Theme.of(context).primaryColor.withAlpha(51),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'U',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.titleMedium?.color,
                  ),
                ),
                Text(
                  email,
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.w),
                decoration: BoxDecoration(
                  color: Colors.green.withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'New User',
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
              ),
              SizedBox(height: 1.w),
              Text(
                _formatTimestamp(timestamp),
                style: GoogleFonts.inter(
                  fontSize: 10.sp,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildManagementToolsSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withAlpha(51),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Management Tools',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).textTheme.titleMedium?.color,
            ),
          ),
          SizedBox(height: 4.w),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 4.w,
            mainAxisSpacing: 4.w,
            childAspectRatio: 2.5,
            children: [
              _buildToolButton(
                context,
                'Search Users',
                Icons.search,
                Colors.blue,
                () => _showSearchDialog(context),
              ),
              _buildToolButton(
                context,
                'Filter Activity',
                Icons.filter_list,
                Colors.green,
                () => _showFilterDialog(context),
              ),
              _buildToolButton(
                context,
                'Export Data',
                Icons.download,
                Colors.purple,
                () => _handleExportData(context),
              ),
              _buildToolButton(
                context,
                'Send Broadcast',
                Icons.campaign,
                Colors.orange,
                () => _showBroadcastDialog(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToolButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: color.withAlpha(26),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withAlpha(77),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 5.w,
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthStatusSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withAlpha(51),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Authentication Status',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).textTheme.titleMedium?.color,
            ),
          ),
          SizedBox(height: 4.w),
          _buildAuthStatusItem('Google OAuth', true, '95%'),
          _buildAuthStatusItem('Biometric Auth', true, '78%'),
          _buildAuthStatusItem('PIN Authentication', true, '82%'),
          _buildAuthStatusItem('Wallet Integration', true, '100%'),
        ],
      ),
    );
  }

  Widget _buildAuthStatusItem(String method, bool isActive, String usage) {
    return Builder(
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 2.w),
          child: Row(
            children: [
              Container(
                width: 3.w,
                height: 3.w,
                decoration: BoxDecoration(
                  color: isActive ? Colors.green : Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  method,
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ),
              Text(
                usage,
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  void _showSearchDialog(BuildContext context) {
    // Implement user search functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('User search functionality'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    // Implement activity filter
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Activity filter options'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _handleExportData(BuildContext context) {
    // Implement data export
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Data export initiated'),
        backgroundColor: Colors.purple,
      ),
    );
  }

  void _showBroadcastDialog(BuildContext context) {
    // Implement broadcast message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Broadcast message system'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}