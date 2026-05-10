import 'package:flutter/material.dart';
import '../../../core/color_polyfill.dart';
import 'package:sizer/sizer.dart';

import '../../../theme/app_theme.dart';

/// Analytics Tab for comprehensive usage statistics and performance trending
class AnalyticsTab extends StatefulWidget {
  const AnalyticsTab({super.key});

  @override
  State<AnalyticsTab> createState() => _AnalyticsTabState();
}

class _AnalyticsTabState extends State<AnalyticsTab> {
  String _selectedTimeRange = '7d';

  final Map<String, String> _timeRanges = {
    '24h': 'Last 24 Hours',
    '7d': 'Last 7 Days',
    '30d': 'Last 30 Days',
    '90d': 'Last 90 Days',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with time range selector
          Row(
            children: [
              Text(
                'Usage Analytics',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color:
                      isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
                ),
              ),
              Spacer(),
              DropdownButton<String>(
                value: _selectedTimeRange,
                items: _timeRanges.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedTimeRange = value!;
                  });
                },
                borderRadius: BorderRadius.circular(12),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Key Metrics Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 3.w,
            mainAxisSpacing: 2.h,
            childAspectRatio: 1.2,
            children: [
              _buildMetricCard(
                'Daily Active Users',
                '1,234',
                '+12.3%',
                Icons.people,
                AppTheme.accentColor,
                isDark,
              ),
              _buildMetricCard(
                'Messages Sent',
                '45.6K',
                '+8.7%',
                Icons.message,
                Colors.blue,
                isDark,
              ),
              _buildMetricCard(
                'Data Usage',
                '2.3 TB',
                '+5.2%',
                Icons.storage,
                Colors.green,
                isDark,
              ),
              _buildMetricCard(
                'Network Uptime',
                '99.97%',
                '+0.1%',
                Icons.timeline,
                Colors.orange,
                isDark,
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Usage Trends Chart
          _buildChartSection(
            'Usage Trends',
            Icons.trending_up,
            isDark,
          ),

          SizedBox(height: 3.h),

          // Geographic Distribution
          _buildGeographicSection(isDark),

          SizedBox(height: 3.h),

          // Performance Metrics
          _buildPerformanceSection(isDark),

          SizedBox(height: 3.h),

          // Export Options
          _buildExportSection(isDark),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    String change,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    final isPositive = change.startsWith('+');

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.surfaceDark.withValues(alpha: 0.3)
            : AppTheme.surfaceLight.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 5.w,
                ),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 2.w,
                  vertical: 0.5.w,
                ),
                decoration: BoxDecoration(
                  color:
                      (isPositive ? AppTheme.successColor : AppTheme.errorColor)
                          .withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  change,
                  style: TextStyle(
                    color: isPositive
                        ? AppTheme.successColor
                        : AppTheme.errorColor,
                    fontSize: 8.sp,
                    fontWeight: FontWeight.w600,
                  ),
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
              fontSize: 9.sp,
              color:
                  isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection(String title, IconData icon, bool isDark) {
    return Container(
      width: double.infinity,
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
          Row(
            children: [
              Icon(
                icon,
                color: AppTheme.accentColor,
                size: 5.w,
              ),
              SizedBox(width: 3.w),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.accentColor,
                    ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Container(
            height: 20.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.show_chart,
                    size: 8.w,
                    color: AppTheme.accentColor.withValues(alpha: 0.5),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'Interactive Chart Area',
                    style: TextStyle(
                      color: isDark
                          ? AppTheme.textSecondaryDark
                          : AppTheme.textSecondary,
                      fontSize: 11.sp,
                    ),
                  ),
                  Text(
                    'Real-time data visualization',
                    style: TextStyle(
                      color: isDark
                          ? AppTheme.textSecondaryDark
                          : AppTheme.textSecondary,
                      fontSize: 9.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeographicSection(bool isDark) {
    final List<Map<String, dynamic>> regions = [
      {'name': 'North America', 'users': 543, 'percentage': 45.2},
      {'name': 'Europe', 'users': 389, 'percentage': 32.4},
      {'name': 'Asia Pacific', 'users': 201, 'percentage': 16.7},
      {'name': 'South America', 'users': 67, 'percentage': 5.6},
      {'name': 'Africa', 'users': 34, 'percentage': 2.8},
    ];

    return Container(
      width: double.infinity,
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
          Row(
            children: [
              Icon(
                Icons.public,
                color: AppTheme.accentColor,
                size: 5.w,
              ),
              SizedBox(width: 3.w),
              Text(
                'Geographic Distribution',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.accentColor,
                    ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          ...regions.map((region) => _buildRegionItem(region, isDark)),
        ],
      ),
    );
  }

  Widget _buildRegionItem(Map<String, dynamic> region, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              region['name'],
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${region['users']} users',
              style: TextStyle(
                fontSize: 10.sp,
                color: isDark
                    ? AppTheme.textSecondaryDark
                    : AppTheme.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 0.8.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: region['percentage'] / 100,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.accentColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
                Text(
                  '${region['percentage']}%',
                  style: TextStyle(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.accentColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceSection(bool isDark) {
    final List<Map<String, dynamic>> metrics = [
      {'name': 'Average Response Time', 'value': '12ms', 'status': 'good'},
      {'name': 'Packet Loss Rate', 'value': '0.02%', 'status': 'good'},
      {'name': 'Network Throughput', 'value': '1.2 Gbps', 'status': 'good'},
      {'name': 'Error Rate', 'value': '0.001%', 'status': 'excellent'},
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.surfaceDark.withValues(alpha: 0.3)
            : AppTheme.surfaceLight.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.successColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.speed,
                color: AppTheme.successColor,
                size: 5.w,
              ),
              SizedBox(width: 3.w),
              Text(
                'Performance Metrics',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.successColor,
                    ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          ...metrics.map((metric) => _buildPerformanceItem(metric, isDark)),
        ],
      ),
    );
  }

  Widget _buildPerformanceItem(Map<String, dynamic> metric, bool isDark) {
    final Color statusColor = metric['status'] == 'excellent'
        ? AppTheme.successColor
        : metric['status'] == 'good'
            ? Colors.green
            : Colors.orange;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.5.h),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  metric['name'],
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppTheme.textPrimaryDark
                        : AppTheme.textPrimary,
                  ),
                ),
                Text(
                  metric['value'],
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
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
              color: statusColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              metric['status'].toUpperCase(),
              style: TextStyle(
                color: statusColor,
                fontSize: 8.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportSection(bool isDark) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.surfaceDark.withValues(alpha: 0.3)
            : AppTheme.surfaceLight.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.download,
                color: AppTheme.accentColor,
                size: 5.w,
              ),
              SizedBox(width: 3.w),
              Text(
                'Export & Reporting',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.accentColor,
                    ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _exportData('csv'),
                  icon: Icon(Icons.table_chart),
                  label: Text('Export CSV'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.accentColor,
                    side: BorderSide(color: AppTheme.accentColor),
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _exportData('pdf'),
                  icon: Icon(Icons.picture_as_pdf),
                  label: Text('Export PDF'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orange,
                    side: BorderSide(color: Colors.orange),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _exportData(String format) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Export Analytics'),
        content: Text(
          'Analytics data for ${_timeRanges[_selectedTimeRange]} will be exported as ${format.toUpperCase()}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Analytics data exported successfully!'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            child: Text('Export'),
          ),
        ],
      ),
    );
  }
}
