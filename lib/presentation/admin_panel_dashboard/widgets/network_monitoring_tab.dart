import 'package:flutter/material.dart';
import '../../../core/color_polyfill.dart';
import 'package:sizer/sizer.dart';

import '../../../theme/app_theme.dart';

/// Network Monitoring Tab for FERMesh global mesh topology
class NetworkMonitoringTab extends StatelessWidget {
  const NetworkMonitoringTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Global Mesh Topology',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
            ),
          ),

          SizedBox(height: 2.h),

          // Real-time Node Status Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 3.w,
            mainAxisSpacing: 2.h,
            childAspectRatio: 1.5,
            children: [
              _buildNodeStatusCard(
                'Active Nodes',
                '1,247',
                Icons.circle,
                AppTheme.successColor,
                isDark,
              ),
              _buildNodeStatusCard(
                'Traffic Load',
                '23.4 GB/s',
                Icons.speed,
                Colors.orange,
                isDark,
              ),
              _buildNodeStatusCard(
                'Network Health',
                '98.7%',
                Icons.favorite,
                AppTheme.successColor,
                isDark,
              ),
              _buildNodeStatusCard(
                'Response Time',
                '12ms avg',
                Icons.timer,
                AppTheme.accentColor,
                isDark,
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Performance Metrics Chart Area
          Container(
            width: double.infinity,
            height: 25.h,
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: isDark
                  ? AppTheme.surfaceDark.withValues(alpha: 0.3)
                  : AppTheme.surfaceLight.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.accentColor.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Network Performance Metrics',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.accentColor,
                  ),
                ),
                SizedBox(height: 2.h),
                Expanded(
                  child: Center(
                    child: Text(
                      'Performance Chart\n(Real-time visualization)',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? AppTheme.textSecondaryDark
                            : AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNodeStatusCard(
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
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 5.w,
              ),
              Spacer(),
              Container(
                width: 2.w,
                height: 2.w,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 10.sp,
              color:
                  isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
