import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

/// Network Monitoring Widget for real-time mesh topology visualization
class NetworkMonitoringWidget extends StatelessWidget {
  final Map<String, dynamic> networkStats;
  final VoidCallback onRefresh;

  const NetworkMonitoringWidget({
    Key? key,
    required this.networkStats,
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
            // Network Overview Cards
            _buildNetworkOverview(context),

            SizedBox(height: 6.w),

            // Real-time Monitoring
            _buildRealtimeSection(context),

            SizedBox(height: 6.w),

            // Topology Visualization
            _buildTopologySection(context),

            SizedBox(height: 6.w),

            // Performance Metrics
            _buildPerformanceSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkOverview(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Network Overview',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        SizedBox(height: 4.w),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 4.w,
          mainAxisSpacing: 4.w,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard(
              context,
              title: 'Total Nodes',
              value: '${networkStats['total_nodes'] ?? 0}',
              icon: Icons.device_hub,
              color: Colors.blue,
            ),
            _buildStatCard(
              context,
              title: 'Active Users',
              value: '${networkStats['active_users'] ?? 0}',
              icon: Icons.people,
              color: Colors.green,
            ),
            _buildStatCard(
              context,
              title: 'Blockchain Nodes',
              value: '${networkStats['blockchain_nodes'] ?? 0}',
              icon: Icons.link,
              color: Colors.purple,
            ),
            _buildStatCard(
              context,
              title: 'Data Streams',
              value: '${networkStats['data_streams'] ?? 0}',
              icon: Icons.stream,
              color: Colors.orange,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withAlpha(51),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(26),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  color: color.withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 6.w,
                ),
              ),
              Icon(
                Icons.trending_up,
                color: Colors.green,
                size: 5.w,
              ),
            ],
          ),
          SizedBox(height: 3.w),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRealtimeSection(BuildContext context) {
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
            children: [
              Icon(
                Icons.monitor_heart,
                color: Colors.red,
                size: 6.w,
              ),
              SizedBox(width: 3.w),
              Text(
                'Real-time Status',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).textTheme.titleMedium?.color,
                ),
              ),
              const Spacer(),
              Container(
                width: 3.w,
                height: 3.w,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 2.w),
              Text(
                'Live',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.w),
          _buildStatusItem('Mesh Network Health', '98.5%', Colors.green),
          _buildStatusItem('Traffic Analysis', '1.2TB/day', Colors.blue),
          _buildStatusItem('Network Latency', '12ms avg', Colors.orange),
          _buildStatusItem('Security Status', 'Secure', Colors.purple),
        ],
      ),
    );
  }

  Widget _buildStatusItem(String label, String value, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              color: Colors.grey[600],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.w),
            decoration: BoxDecoration(
              color: color.withAlpha(26),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopologySection(BuildContext context) {
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
            'Global Mesh Topology',
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
                  Theme.of(context).primaryColor.withAlpha(26),
                  Theme.of(context).primaryColor.withAlpha(13),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.hub,
                    size: 15.w,
                    color: Theme.of(context).primaryColor,
                  ),
                  SizedBox(height: 2.w),
                  Text(
                    'Interactive Topology Visualization',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  Text(
                    'Node connections and traffic patterns',
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
            'Performance Metrics',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).textTheme.titleMedium?.color,
            ),
          ),
          SizedBox(height: 4.w),
          _buildMetricBar('CPU Usage', 0.65, Colors.blue),
          _buildMetricBar('Memory Usage', 0.42, Colors.green),
          _buildMetricBar('Network Load', 0.78, Colors.orange),
          _buildMetricBar('Storage Usage', 0.33, Colors.purple),
        ],
      ),
    );
  }

  Widget _buildMetricBar(String label, double value, Color color) {
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
                  color: Colors.grey[600],
                ),
              ),
              Text(
                '${(value * 100).toInt()}%',
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
              widthFactor: value,
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
}