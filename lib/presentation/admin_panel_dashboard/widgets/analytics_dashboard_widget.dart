import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

/// Analytics Dashboard Widget for comprehensive usage statistics and data visualization
class AnalyticsDashboardWidget extends StatelessWidget {
  final Map<String, dynamic> networkStats;
  final Map<String, dynamic> userStats;
  final VoidCallback onExportData;

  const AnalyticsDashboardWidget({
    Key? key,
    required this.networkStats,
    required this.userStats,
    required this.onExportData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Analytics Overview
          _buildAnalyticsOverview(context),

          SizedBox(height: 6.w),

          // Usage Statistics
          _buildUsageStatistics(context),

          SizedBox(height: 6.w),

          // Geographic Distribution
          _buildGeographicSection(context),

          SizedBox(height: 6.w),

          // Performance Trending
          _buildPerformanceSection(context),

          SizedBox(height: 6.w),

          // Data Export Tools
          _buildExportSection(context),
        ],
      ),
    );
  }

  Widget _buildAnalyticsOverview(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withAlpha(26),
            Theme.of(context).primaryColor.withAlpha(13),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).primaryColor.withAlpha(77),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Analytics Overview',
                style: GoogleFonts.inter(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.w),
                decoration: BoxDecoration(
                  color: Colors.green.withAlpha(51),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Live Data',
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.w),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  context,
                  'Total Transactions',
                  '${(networkStats['total_nodes'] ?? 0) * 150}',
                  Icons.swap_horiz,
                  Colors.blue,
                  '+12.5%',
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: _buildMetricCard(
                  context,
                  'Data Processed',
                  '2.4TB',
                  Icons.storage,
                  Colors.green,
                  '+8.2%',
                ),
              ),
            ],
          ),
          SizedBox(height: 4.w),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  context,
                  'Network Uptime',
                  '99.8%',
                  Icons.timeline,
                  Colors.purple,
                  '+0.1%',
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: _buildMetricCard(
                  context,
                  'Avg Response',
                  '12ms',
                  Icons.speed,
                  Colors.orange,
                  '-2.1%',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    String change,
  ) {
    final isPositive = change.startsWith('+');

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
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
              Icon(
                icon,
                color: color,
                size: 5.w,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.w),
                decoration: BoxDecoration(
                  color: (isPositive ? Colors.green : Colors.red).withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  change,
                  style: GoogleFonts.inter(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w600,
                    color: isPositive ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.w),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 10.sp,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageStatistics(BuildContext context) {
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
            'Usage Statistics',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).textTheme.titleMedium?.color,
            ),
          ),
          SizedBox(height: 4.w),
          _buildUsageBar('Gaming Activity', 0.78, Colors.purple),
          _buildUsageBar('Messaging Volume', 0.65, Colors.blue),
          _buildUsageBar('Exploration Sessions', 0.42, Colors.green),
          _buildUsageBar('Data Transfers', 0.89, Colors.orange),
        ],
      ),
    );
  }

  Widget _buildUsageBar(String label, double percentage, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  color: Colors.grey[700],
                ),
              ),
              Text(
                '${(percentage * 100).toInt()}%',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.w),
          Container(
            width: double.infinity,
            height: 2.w,
            decoration: BoxDecoration(
              color: color.withAlpha(51),
              borderRadius: BorderRadius.circular(1.w),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(1.w),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeographicSection(BuildContext context) {
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
            'Geographic Distribution',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).textTheme.titleMedium?.color,
            ),
          ),
          SizedBox(height: 4.w),
          Container(
            width: double.infinity,
            height: 40.w,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue.withAlpha(26),
                  Colors.blue.withAlpha(13),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.public,
                  size: 15.w,
                  color: Colors.blue,
                ),
                SizedBox(height: 2.w),
                Text(
                  'Interactive World Map',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                ),
                Text(
                  'Node distribution across continents',
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 4.w),
          Row(
            children: [
              Expanded(
                child: _buildRegionStat('North America', '35%', Colors.blue),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: _buildRegionStat('Europe', '28%', Colors.green),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: _buildRegionStat('Asia Pacific', '37%', Colors.orange),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRegionStat(String region, String percentage, Color color) {
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
          Text(
            percentage,
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            region,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 10.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceSection(BuildContext context) {
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
            'Performance Trending',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).textTheme.titleMedium?.color,
            ),
          ),
          SizedBox(height: 4.w),
          Container(
            width: double.infinity,
            height: 30.w,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.purple.withAlpha(26),
                  Colors.purple.withAlpha(13),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.trending_up,
                    size: 10.w,
                    color: Colors.purple,
                  ),
                  SizedBox(height: 2.w),
                  Text(
                    'Performance Charts',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.purple,
                    ),
                  ),
                  Text(
                    'Last 30 days trending analysis',
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      color: Theme.of(context).textTheme.bodySmall?.color,
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

  Widget _buildExportSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.withAlpha(26),
            Colors.green.withAlpha(13),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.green.withAlpha(77),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.download,
                color: Colors.green,
                size: 6.w,
              ),
              SizedBox(width: 3.w),
              Text(
                'Data Export & Reporting',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.green,
                ),
              ),
            ],
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
              _buildExportButton(
                context,
                'CSV Export',
                Icons.table_chart,
                () => _handleCSVExport(context),
              ),
              _buildExportButton(
                context,
                'PDF Report',
                Icons.picture_as_pdf,
                () => _handlePDFExport(context),
              ),
              _buildExportButton(
                context,
                'JSON Data',
                Icons.code,
                () => _handleJSONExport(context),
              ),
              _buildExportButton(
                context,
                'Email Report',
                Icons.email,
                () => _handleEmailReport(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExportButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green.withAlpha(26),
        foregroundColor: Colors.green,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.green.withAlpha(77)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 4.w),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleCSVExport(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('CSV export initiated'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _handlePDFExport(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('PDF report generation started'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _handleJSONExport(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('JSON data export ready'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _handleEmailReport(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Email report scheduled'),
        backgroundColor: Colors.green,
      ),
    );
  }
}