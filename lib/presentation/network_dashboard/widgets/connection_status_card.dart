import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class ConnectionStatusCard extends StatefulWidget {
  final String networkStatus;
  final int connectedNodes;
  final double signalStrength;
  final VoidCallback? onRefresh;

  const ConnectionStatusCard({
    super.key,
    required this.networkStatus,
    required this.connectedNodes,
    required this.signalStrength,
    this.onRefresh,
  });

  @override
  State<ConnectionStatusCard> createState() => _ConnectionStatusCardState();
}

class _ConnectionStatusCardState extends State<ConnectionStatusCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    if (widget.networkStatus.toLowerCase() == 'connecting') {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(ConnectionStatusCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.networkStatus.toLowerCase() == 'connecting') {
      _pulseController.repeat(reverse: true);
    } else {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color _getStatusColor() {
    switch (widget.networkStatus.toLowerCase()) {
      case 'connected':
        return AppTheme.successColor;
      case 'connecting':
        return AppTheme.warningColor;
      case 'disconnected':
        return AppTheme.errorColor;
      default:
        return AppTheme.textSecondary;
    }
  }

  String _getStatusText() {
    switch (widget.networkStatus.toLowerCase()) {
      case 'connected':
        return 'FERMesh Actief';
      case 'connecting':
        return 'Verbinden...';
      case 'disconnected':
        return 'Niet Verbonden';
      default:
        return 'Onbekend';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final statusColor = _getStatusColor();

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? AppTheme.shadowDark.withValues(alpha: 0.2)
                : AppTheme.shadowLight.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with refresh button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Netwerk Status',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color:
                      isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: widget.onRefresh,
                child: Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomIconWidget(
                    iconName: 'refresh',
                    color: AppTheme.accentColor,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Main status indicator
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: widget.networkStatus.toLowerCase() == 'connecting'
                    ? _pulseAnimation.value
                    : 1.0,
                child: Container(
                  width: 20.w,
                  height: 20.w,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: statusColor,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withValues(alpha: 0.3),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: widget.networkStatus.toLowerCase() ==
                              'connected'
                          ? 'wifi'
                          : widget.networkStatus.toLowerCase() == 'connecting'
                              ? 'sync'
                              : 'wifi_off',
                      color: statusColor,
                      size: 8.w,
                    ),
                  ),
                ),
              );
            },
          ),

          SizedBox(height: 2.h),

          // Status text
          Text(
            _getStatusText(),
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: statusColor,
            ),
          ),

          SizedBox(height: 1.h),

          // Connection details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMetricItem(
                context,
                'Nodes',
                widget.connectedNodes.toString(),
                'group',
                isDark,
              ),
              Container(
                width: 1,
                height: 4.h,
                color: isDark ? AppTheme.dividerDark : AppTheme.dividerLight,
              ),
              _buildMetricItem(
                context,
                'Signaal',
                '${(widget.signalStrength * 100).toInt()}%',
                'signal_cellular_alt',
                isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(
    BuildContext context,
    String label,
    String value,
    String iconName,
    bool isDark,
  ) {
    return Column(
      children: [
        CustomIconWidget(
          iconName: iconName,
          color: AppTheme.accentColor,
          size: 6.w,
        ),
        SizedBox(height: 0.5.h),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isDark
                    ? AppTheme.textSecondaryDark
                    : AppTheme.textSecondary,
              ),
        ),
      ],
    );
  }
}
