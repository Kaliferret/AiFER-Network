import 'package:flutter/material.dart';
import '../../../core/color_polyfill.dart';
import 'package:sizer/sizer.dart';

import '../../../theme/app_theme.dart';

/// Admin Statistics Widget displaying system overview metrics
class AdminStatsWidget extends StatelessWidget {
  final Map<String, dynamic> stats;

  const AdminStatsWidget({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.accentColor.withValues(alpha: 0.1),
            AppTheme.accentColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.accentColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.dashboard,
                  color: AppTheme.accentColor,
                  size: 5.w,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'System Overview',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.accentColor,
                      ),
                    ),
                    Text(
                      'Real-time FERMesh network statistics',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppTheme.textSecondaryDark
                            : AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 2.w,
                  vertical: 1.w,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.circle,
                      color: AppTheme.successColor,
                      size: 2.w,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      'ONLINE',
                      style: TextStyle(
                        color: AppTheme.successColor,
                        fontSize: 8.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Statistics Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 3.w,
            mainAxisSpacing: 2.h,
            childAspectRatio: 2.5,
            children: [
              _buildStatCard(
                'Total Users',
                stats['total_users']?.toString() ?? '0',
                Icons.people,
                AppTheme.accentColor,
                isDark,
              ),
              _buildStatCard(
                'New Users (30d)',
                stats['new_users_30d']?.toString() ?? '0',
                Icons.person_add,
                Colors.green,
                isDark,
              ),
              _buildStatCard(
                'Total Messages',
                _formatNumber(stats['total_messages'] ?? 0),
                Icons.message,
                Colors.blue,
                isDark,
              ),
              _buildStatCard(
                'Network Nodes',
                stats['total_network_nodes']?.toString() ?? '0',
                Icons.hub,
                Colors.orange,
                isDark,
              ),
              _buildStatCard(
                'Games Played',
                _formatNumber(stats['total_games_played'] ?? 0),
                Icons.games,
                Colors.purple,
                isDark,
              ),
              _buildStatCard(
                'Explorations',
                stats['total_exploration_sessions']?.toString() ?? '0',
                Icons.explore,
                Colors.teal,
                isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.surfaceDark.withValues(alpha: 0.3)
            : AppTheme.surfaceLight.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(1.5.w),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 4.w,
                ),
              ),
              Spacer(),
              Icon(
                Icons.trending_up,
                color: AppTheme.successColor,
                size: 3.w,
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 9.sp,
              color:
                  isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
