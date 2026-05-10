import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class NetworkStatusBar extends StatefulWidget {
  final Map<String, dynamic> networkStatus;
  final VoidCallback? onTap;

  const NetworkStatusBar({
    super.key,
    required this.networkStatus,
    this.onTap,
  });

  @override
  State<NetworkStatusBar> createState() => _NetworkStatusBarState();
}

class _NetworkStatusBarState extends State<NetworkStatusBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _startAnimationIfNeeded();
  }

  void _startAnimationIfNeeded() {
    final status =
        widget.networkStatus['status']?.toString().toLowerCase() ?? '';
    if (status == 'connecting' || status == 'syncing') {
      _animationController.repeat(reverse: true);
    } else {
      _animationController.stop();
      _animationController.reset();
    }
  }

  @override
  void didUpdateWidget(NetworkStatusBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.networkStatus['status'] != widget.networkStatus['status']) {
      _startAnimationIfNeeded();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final status = widget.networkStatus['status']?.toString() ?? 'disconnected';
    final statusColor = AppTheme.getNetworkStatusColor(status);

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: statusColor.withValues(alpha: 0.1),
          border: Border(
            bottom: BorderSide(
              color: statusColor.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            // Status indicator with animation
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: (status.toLowerCase() == 'connecting' ||
                          status.toLowerCase() == 'syncing')
                      ? _pulseAnimation.value
                      : 1.0,
                  child: Container(
                    width: 3.w,
                    height: 3.w,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: statusColor.withValues(alpha: 0.4),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            SizedBox(width: 3.w),

            // Status text and details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _getStatusDisplayText(status),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (widget.networkStatus['nodeCount'] != null) ...[
                        SizedBox(width: 2.w),
                        Text(
                          '• ${widget.networkStatus['nodeCount']} nodes',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isDark
                                ? AppTheme.textSecondaryDark
                                    .withValues(alpha: 0.8)
                                : AppTheme.textSecondary.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (widget.networkStatus['details'] != null) ...[
                    SizedBox(height: 0.5.h),
                    Text(
                      widget.networkStatus['details'],
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isDark
                            ? AppTheme.textSecondaryDark.withValues(alpha: 0.7)
                            : AppTheme.textSecondary.withValues(alpha: 0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // Network metrics
            if (widget.networkStatus['signalStrength'] != null) ...[
              _NetworkSignalWidget(
                strength: widget.networkStatus['signalStrength'],
                color: statusColor,
              ),
              SizedBox(width: 3.w),
            ],

            // Latency indicator
            if (widget.networkStatus['latency'] != null) ...[
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 2.w,
                  vertical: 0.5.h,
                ),
                decoration: BoxDecoration(
                  color: _getLatencyColor(widget.networkStatus['latency'])
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${widget.networkStatus['latency']}ms',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: _getLatencyColor(widget.networkStatus['latency']),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(width: 2.w),
            ],

            // Expand/collapse indicator
            CustomIconWidget(
              iconName: 'keyboard_arrow_right',
              color: isDark
                  ? AppTheme.textSecondaryDark.withValues(alpha: 0.6)
                  : AppTheme.textSecondary.withValues(alpha: 0.6),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusDisplayText(String status) {
    switch (status.toLowerCase()) {
      case 'connected':
        return 'FERMesh Connected';
      case 'connecting':
        return 'Connecting to FERMesh...';
      case 'syncing':
        return 'Syncing Messages...';
      case 'disconnected':
        return 'FERMesh Disconnected';
      case 'offline':
        return 'Offline Mode';
      default:
        return 'Network Status Unknown';
    }
  }

  Color _getLatencyColor(int latency) {
    if (latency < 50) {
      return AppTheme.successColor;
    } else if (latency < 150) {
      return AppTheme.warningColor;
    } else {
      return AppTheme.errorColor;
    }
  }
}

class _NetworkSignalWidget extends StatelessWidget {
  final int strength; // 0-4 signal strength
  final Color color;

  const _NetworkSignalWidget({
    required this.strength,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(4, (index) {
        final isActive = index < strength;
        final barHeight = (index + 1) * 0.8.h;

        return Container(
          width: 0.8.w,
          height: 3.2.h,
          margin: EdgeInsets.symmetric(horizontal: 0.2.w),
          alignment: Alignment.bottomCenter,
          child: Container(
            width: 0.8.w,
            height: barHeight,
            decoration: BoxDecoration(
              color: isActive ? color : color.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        );
      }),
    );
  }
}
