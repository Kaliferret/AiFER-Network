import 'package:flutter/material.dart';
import '../../../core/color_polyfill.dart';
import 'package:sizer/sizer.dart';

import '../../../theme/app_theme.dart';

/// System Controls Tab for network-wide configuration and emergency controls
class SystemControlsTab extends StatefulWidget {
  const SystemControlsTab({super.key});

  @override
  State<SystemControlsTab> createState() => _SystemControlsTabState();
}

class _SystemControlsTabState extends State<SystemControlsTab> {
  bool _emergencyMode = false;
  bool _blockchainSyncEnabled = true;
  bool _autoDiscovery = true;
  double _frequencyAllocation = 2.4;
  int _maxConnections = 50;

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
            'Network Configuration',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
            ),
          ),

          SizedBox(height: 3.h),

          // Emergency Controls Section
          _buildControlSection(
            'Emergency Controls',
            Icons.emergency,
            AppTheme.errorColor,
            isDark,
            [
              _buildEmergencyToggle(isDark),
              _buildEmergencyBroadcastButton(isDark),
              _buildDisasterModeButton(isDark),
            ],
          ),

          SizedBox(height: 3.h),

          // Network Parameters Section
          _buildControlSection(
            'Network Parameters',
            Icons.tune,
            AppTheme.accentColor,
            isDark,
            [
              _buildFrequencySlider(isDark),
              _buildConnectionLimitSlider(isDark),
              _buildBlockchainSyncToggle(isDark),
              _buildAutoDiscoveryToggle(isDark),
            ],
          ),

          SizedBox(height: 3.h),

          // System Status Section
          _buildControlSection(
            'System Status',
            Icons.monitor_heart,
            AppTheme.successColor,
            isDark,
            [
              _buildSystemHealthCard(isDark),
              _buildNetworkDiagnosticsButton(isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlSection(
    String title,
    IconData icon,
    Color color,
    bool isDark,
    List<Widget> controls,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
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
              SizedBox(width: 3.w),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          ...controls.map((control) => Padding(
                padding: EdgeInsets.only(bottom: 2.h),
                child: control,
              )),
        ],
      ),
    );
  }

  Widget _buildEmergencyToggle(bool isDark) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: _emergencyMode
            ? AppTheme.errorColor.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _emergencyMode
              ? AppTheme.errorColor.withValues(alpha: 0.3)
              : Colors.grey.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning,
            color: _emergencyMode ? AppTheme.errorColor : Colors.grey,
            size: 5.w,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Emergency Network Mode',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12.sp,
                    color: _emergencyMode
                        ? AppTheme.errorColor
                        : (isDark
                            ? AppTheme.textPrimaryDark
                            : AppTheme.textPrimary),
                  ),
                ),
                Text(
                  'Activates priority routing and emergency broadcasts',
                  style: TextStyle(
                    fontSize: 9.sp,
                    color: isDark
                        ? AppTheme.textSecondaryDark
                        : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _emergencyMode,
            onChanged: (value) {
              setState(() {
                _emergencyMode = value;
              });
              _showConfirmationDialog(
                'Emergency Mode ${value ? 'Activated' : 'Deactivated'}',
                'Network-wide emergency protocols ${value ? 'enabled' : 'disabled'}.',
              );
            },
            activeColor: AppTheme.errorColor,
          ),
        ],
      ),
    );
  }

  Widget _buildFrequencySlider(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.radio,
              color: AppTheme.accentColor,
              size: 4.w,
            ),
            SizedBox(width: 2.w),
            Text(
              'Frequency Allocation: ${_frequencyAllocation}GHz',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12.sp,
                color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        Slider(
          value: _frequencyAllocation,
          min: 2.4,
          max: 5.8,
          divisions: 34,
          label: '${_frequencyAllocation}GHz',
          activeColor: AppTheme.accentColor,
          onChanged: (value) {
            setState(() {
              _frequencyAllocation = double.parse(value.toStringAsFixed(1));
            });
          },
        ),
      ],
    );
  }

  Widget _buildConnectionLimitSlider(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.device_hub,
              color: AppTheme.accentColor,
              size: 4.w,
            ),
            SizedBox(width: 2.w),
            Text(
              'Max Connections: $_maxConnections',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12.sp,
                color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        Slider(
          value: _maxConnections.toDouble(),
          min: 10,
          max: 100,
          divisions: 18,
          label: '$_maxConnections',
          activeColor: AppTheme.accentColor,
          onChanged: (value) {
            setState(() {
              _maxConnections = value.round();
            });
          },
        ),
      ],
    );
  }

  Widget _buildBlockchainSyncToggle(bool isDark) {
    return _buildToggleOption(
      'Blockchain Sync',
      'Synchronize blockchain data across network nodes',
      Icons.sync,
      _blockchainSyncEnabled,
      (value) => setState(() => _blockchainSyncEnabled = value),
      isDark,
    );
  }

  Widget _buildAutoDiscoveryToggle(bool isDark) {
    return _buildToggleOption(
      'Auto Discovery',
      'Automatically discover and connect to nearby nodes',
      Icons.radar,
      _autoDiscovery,
      (value) => setState(() => _autoDiscovery = value),
      isDark,
    );
  }

  Widget _buildToggleOption(
    String title,
    String description,
    IconData icon,
    bool value,
    Function(bool) onChanged,
    bool isDark,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: value ? AppTheme.accentColor : Colors.grey,
          size: 4.w,
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12.sp,
                  color:
                      isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 9.sp,
                  color: isDark
                      ? AppTheme.textSecondaryDark
                      : AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppTheme.accentColor,
        ),
      ],
    );
  }

  Widget _buildEmergencyBroadcastButton(bool isDark) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _showEmergencyBroadcastDialog(),
        icon: Icon(Icons.campaign),
        label: Text('Send Emergency Broadcast'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 2.h),
        ),
      ),
    );
  }

  Widget _buildDisasterModeButton(bool isDark) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _showDisasterModeDialog(),
        icon: Icon(Icons.crisis_alert),
        label: Text('Activate Disaster Mode'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.errorColor,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 2.h),
        ),
      ),
    );
  }

  Widget _buildSystemHealthCard(bool isDark) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.successColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.successColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: AppTheme.successColor,
            size: 5.w,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'System Health: Optimal',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12.sp,
                    color: AppTheme.successColor,
                  ),
                ),
                Text(
                  'All systems operational • Last check: 2 minutes ago',
                  style: TextStyle(
                    fontSize: 9.sp,
                    color: AppTheme.successColor.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkDiagnosticsButton(bool isDark) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _showNetworkDiagnostics(),
        icon: Icon(Icons.computer),
        label: Text('Run Network Diagnostics'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.accentColor,
          side: BorderSide(color: AppTheme.accentColor),
          padding: EdgeInsets.symmetric(vertical: 2.h),
        ),
      ),
    );
  }

  void _showConfirmationDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showEmergencyBroadcastDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Emergency Broadcast'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Emergency Message',
                hintText: 'Enter emergency broadcast message...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showConfirmationDialog(
                'Emergency Broadcast Sent',
                'Emergency message broadcast to all network nodes.',
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: Text('Send Broadcast'),
          ),
        ],
      ),
    );
  }

  void _showDisasterModeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: AppTheme.errorColor),
            SizedBox(width: 2.w),
            Text('Disaster Mode'),
          ],
        ),
        content: Text(
          'This will activate emergency protocols and prioritize disaster recovery communications. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showConfirmationDialog(
                'Disaster Mode Activated',
                'Network has switched to disaster recovery protocols.',
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: Text('Activate'),
          ),
        ],
      ),
    );
  }

  void _showNetworkDiagnostics() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Network Diagnostics'),
        content: Container(
          height: 30.h,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Running comprehensive network diagnostics...'),
              SizedBox(height: 2.h),
              LinearProgressIndicator(),
              SizedBox(height: 2.h),
              Text('• Node connectivity: PASS'),
              Text('• Packet routing: PASS'),
              Text('• Blockchain sync: PASS'),
              Text('• Security protocols: PASS'),
              SizedBox(height: 2.h),
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Network Status: Healthy',
                  style: TextStyle(
                    color: AppTheme.successColor,
                    fontWeight: FontWeight.w600,
                  ),
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
        ],
      ),
    );
  }
}
