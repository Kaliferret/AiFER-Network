import 'package:flutter/material.dart';
import '../../../core/color_polyfill.dart';
import 'package:sizer/sizer.dart';

import '../../../services/unified_supabase_service.dart';
import '../../../theme/app_theme.dart';

class SupabaseHealthWidget extends StatefulWidget {
  const SupabaseHealthWidget({super.key});

  @override
  State<SupabaseHealthWidget> createState() => _SupabaseHealthWidgetState();
}

class _SupabaseHealthWidgetState extends State<SupabaseHealthWidget> {
  final UnifiedSupabaseService _supabaseService =
      UnifiedSupabaseService.instance;
  Map<String, dynamic>? _healthData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHealthStatus();
    // Refresh every 30 seconds
    _startPeriodicRefresh();
  }

  void _startPeriodicRefresh() {
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) {
        _loadHealthStatus();
        _startPeriodicRefresh();
      }
    });
  }

  Future<void> _loadHealthStatus() async {
    try {
      final health = await _supabaseService.healthCheck();
      if (mounted) {
        setState(() {
          _healthData = health;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _healthData = {
            'status': 'unhealthy',
            'error': e.toString(),
            'timestamp': DateTime.now().toIso8601String(),
          };
          _isLoading = false;
        });
      }
    }
  }

  Color _getStatusColor() {
    if (_healthData == null) return AppTheme.textSecondary;

    switch (_healthData!['status']) {
      case 'healthy':
        return AppTheme.successColor;
      case 'unhealthy':
        return AppTheme.errorColor;
      default:
        return AppTheme.warningColor;
    }
  }

  IconData _getStatusIcon() {
    if (_healthData == null) return Icons.help_outline;

    switch (_healthData!['status']) {
      case 'healthy':
        return Icons.check_circle_outline;
      case 'unhealthy':
        return Icons.error_outline;
      default:
        return Icons.warning_outlined;
    }
  }

  String _getStatusText() {
    if (_isLoading) return 'Checking...';
    if (_healthData == null) return 'Unknown';

    final status = _healthData!['status'];
    final latency = _healthData!['latency'];

    if (status == 'healthy' && latency != null) {
      return 'Online • ${latency}ms';
    } else if (status == 'unhealthy') {
      return 'Connection Issues';
    }

    return status?.toString().toUpperCase() ?? 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final statusColor = _getStatusColor();

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.surfaceDark.withValues(alpha: 0.8)
            : AppTheme.surfaceLight.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.1),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getStatusIcon(),
                  color: statusColor,
                  size: 5.w,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Supabase Connection',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppTheme.textPrimaryDark
                            : AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      _getStatusText(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (_isLoading)
                SizedBox(
                  width: 5.w,
                  height: 5.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: statusColor,
                  ),
                ),
            ],
          ),
          if (_healthData != null) ...[
            SizedBox(height: 3.h),

            // Connection details
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: isDark
                    ? AppTheme.backgroundDark.withValues(alpha: 0.3)
                    : AppTheme.backgroundLight.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildDetailRow(
                    'Authentication',
                    _healthData!['authenticated'] == true ? 'Active' : 'Guest',
                    _healthData!['authenticated'] == true
                        ? Icons.verified_user
                        : Icons.person_outline,
                    _healthData!['authenticated'] == true
                        ? AppTheme.successColor
                        : AppTheme.warningColor,
                    theme,
                  ),
                  if (_healthData!['latency'] != null) ...[
                    SizedBox(height: 2.h),
                    _buildDetailRow(
                      'Response Time',
                      '${_healthData!['latency']}ms',
                      Icons.speed,
                      _getLatencyColor(_healthData!['latency']),
                      theme,
                    ),
                  ],
                  SizedBox(height: 2.h),
                  _buildDetailRow(
                    'Last Check',
                    _formatTimestamp(_healthData!['timestamp']),
                    Icons.access_time,
                    isDark
                        ? AppTheme.textSecondaryDark
                        : AppTheme.textSecondary,
                    theme,
                  ),
                ],
              ),
            ),
          ],
          if (_healthData?['status'] == 'unhealthy') ...[
            SizedBox(height: 2.h),
            ElevatedButton.icon(
              onPressed: _loadHealthStatus,
              icon: Icon(Icons.refresh, size: 4.w),
              label: Text('Retry Connection'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: 4.w,
                  vertical: 1.5.h,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon,
    Color color,
    ThemeData theme,
  ) {
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Icon(
          icon,
          size: 4.w,
          color: color,
        ),
        SizedBox(width: 3.w),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Color _getLatencyColor(int latency) {
    if (latency < 100) return AppTheme.successColor;
    if (latency < 300) return AppTheme.warningColor;
    return AppTheme.errorColor;
  }

  String _formatTimestamp(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else {
        return '${difference.inHours}h ago';
      }
    } catch (e) {
      return 'Unknown';
    }
  }
}
