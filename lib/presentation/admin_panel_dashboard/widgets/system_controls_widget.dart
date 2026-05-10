import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

/// System Controls Widget for network-wide configuration and emergency controls
class SystemControlsWidget extends StatelessWidget {
  final VoidCallback onEmergencyBroadcast;
  final VoidCallback onNetworkConfiguration;

  const SystemControlsWidget({
    Key? key,
    required this.onEmergencyBroadcast,
    required this.onNetworkConfiguration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Emergency Controls
          _buildEmergencySection(context),

          SizedBox(height: 6.w),

          // Network Configuration
          _buildNetworkConfigSection(context),

          SizedBox(height: 6.w),

          // Blockchain Parameters
          _buildBlockchainSection(context),

          SizedBox(height: 6.w),

          // System Maintenance
          _buildMaintenanceSection(context),
        ],
      ),
    );
  }

  Widget _buildEmergencySection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.red.withAlpha(26),
            Colors.red.withAlpha(13),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.red.withAlpha(77),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.emergency,
                color: Colors.red,
                size: 6.w,
              ),
              SizedBox(width: 3.w),
              Text(
                'Emergency Controls',
                style: GoogleFonts.inter(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.w),
          Text(
            'Critical network-wide emergency functions with immediate effect',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
          SizedBox(height: 4.w),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 4.w,
            mainAxisSpacing: 4.w,
            childAspectRatio: 2,
            children: [
              _buildEmergencyButton(
                context,
                'Emergency Broadcast',
                Icons.campaign,
                onEmergencyBroadcast,
              ),
              _buildEmergencyButton(
                context,
                'Network Lockdown',
                Icons.lock,
                () => _showLockdownDialog(context),
              ),
              _buildEmergencyButton(
                context,
                'Disaster Mode',
                Icons.warning,
                () => _showDisasterModeDialog(context),
              ),
              _buildEmergencyButton(
                context,
                'Force Resync',
                Icons.sync,
                () => _handleForceResync(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 6.w),
          SizedBox(height: 2.w),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkConfigSection(BuildContext context) {
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
                Icons.settings,
                color: Theme.of(context).primaryColor,
                size: 6.w,
              ),
              SizedBox(width: 3.w),
              Text(
                'Network Configuration',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).textTheme.titleMedium?.color,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.w),
          _buildConfigItem(
            context,
            'Frequency Allocation',
            '2.4GHz, 5GHz Active',
            Icons.radio,
            Colors.blue,
            () => _showFrequencyDialog(context),
          ),
          _buildConfigItem(
            context,
            'Transmission Power',
            'Global: 75%',
            Icons.signal_cellular_alt,
            Colors.green,
            () => _showPowerDialog(context),
          ),
          _buildConfigItem(
            context,
            'Connection Limits',
            'Max: 50 per node',
            Icons.device_hub,
            Colors.orange,
            () => _showConnectionDialog(context),
          ),
          _buildConfigItem(
            context,
            'Security Protocols',
            'Quantum Encryption',
            Icons.security,
            Colors.purple,
            () => _showSecurityDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigItem(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.w),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: color.withAlpha(13),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 10.w,
                height: 10.w,
                decoration: BoxDecoration(
                  color: color.withAlpha(51),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 5.w,
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.titleMedium?.color,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: color,
                size: 4.w,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBlockchainSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.withAlpha(26),
            Colors.purple.withAlpha(13),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.purple.withAlpha(77),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.link,
                color: Colors.purple,
                size: 6.w,
              ),
              SizedBox(width: 3.w),
              Text(
                'Blockchain Parameters',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.w),
          _buildBlockchainParam('Stellar Network', 'Mainnet Active', true),
          _buildBlockchainParam('SUI Network', 'Testnet Mode', false),
          _buildBlockchainParam('Consensus Algorithm', 'PBFT Enhanced', true),
          _buildBlockchainParam('Block Time', '5 seconds', true),
        ],
      ),
    );
  }

  Widget _buildBlockchainParam(String label, String value, bool isActive) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.purple,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 11.sp,
                  color: Colors.purple.withOpacity(0.7),
                ),
              ),
            ],
          ),
          Container(
            width: 3.w,
            height: 3.w,
            decoration: BoxDecoration(
              color: isActive ? Colors.green : Colors.orange,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaintenanceSection(BuildContext context) {
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
            'System Maintenance',
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
            crossAxisCount: 1,
            crossAxisSpacing: 4.w,
            mainAxisSpacing: 3.w,
            childAspectRatio: 4,
            children: [
              _buildMaintenanceButton(
                context,
                'Database Cleanup',
                Icons.cleaning_services,
                Colors.blue,
                () => _handleDatabaseCleanup(context),
              ),
              _buildMaintenanceButton(
                context,
                'Log Rotation',
                Icons.rotate_right,
                Colors.green,
                () => _handleLogRotation(context),
              ),
              _buildMaintenanceButton(
                context,
                'Performance Optimization',
                Icons.speed,
                Colors.orange,
                () => _handlePerformanceOptimization(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMaintenanceButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withAlpha(26),
        foregroundColor: color,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color.withAlpha(77)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 5.w),
          SizedBox(width: 3.w),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // Dialog and action handlers
  void _showLockdownDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Network lockdown protocol initiated'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showDisasterModeDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Disaster recovery mode activated'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _handleForceResync(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Force network resynchronization started'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showFrequencyDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Frequency allocation management'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showPowerDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Transmission power configuration'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showConnectionDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Connection limits adjustment'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _showSecurityDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Security protocol configuration'),
        backgroundColor: Colors.purple,
      ),
    );
  }

  void _handleDatabaseCleanup(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Database cleanup initiated'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _handleLogRotation(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Log rotation started'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _handlePerformanceOptimization(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Performance optimization running'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}