import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class NetworkQualityWidget extends StatefulWidget {
  final String networkStatus;
  final int signalStrength;
  final int latency;
  final double packetLoss;
  final String currentFrequency;
  final bool isEmergencyMode;

  const NetworkQualityWidget({
    super.key,
    required this.networkStatus,
    required this.signalStrength,
    required this.latency,
    required this.packetLoss,
    required this.currentFrequency,
    this.isEmergencyMode = false,
  });

  @override
  State<NetworkQualityWidget> createState() => _NetworkQualityWidgetState();
}

class _NetworkQualityWidgetState extends State<NetworkQualityWidget>
    with TickerProviderStateMixin {
  late AnimationController _signalController;
  late AnimationController _emergencyController;
  late Animation<double> _signalAnimation;
  late Animation<Color?> _emergencyAnimation;

  @override
  void initState() {
    super.initState();
    _signalController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _emergencyController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _signalAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _signalController,
      curve: Curves.easeInOut,
    ));

    _emergencyAnimation = ColorTween(
      begin: AppTheme.errorColor,
      end: AppTheme.warningColor,
    ).animate(CurvedAnimation(
      parent: _emergencyController,
      curve: Curves.easeInOut,
    ));

    if (widget.networkStatus.toLowerCase() == 'connecting') {
      _signalController.repeat(reverse: true);
    }

    if (widget.isEmergencyMode) {
      _emergencyController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(NetworkQualityWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.networkStatus.toLowerCase() == 'connecting') {
      _signalController.repeat(reverse: true);
    } else {
      _signalController.stop();
      _signalController.reset();
    }

    if (widget.isEmergencyMode && !oldWidget.isEmergencyMode) {
      _emergencyController.repeat(reverse: true);
    } else if (!widget.isEmergencyMode && oldWidget.isEmergencyMode) {
      _emergencyController.stop();
      _emergencyController.reset();
    }
  }

  @override
  void dispose() {
    _signalController.dispose();
    _emergencyController.dispose();
    super.dispose();
  }

  Color _getQualityColor() {
    if (widget.isEmergencyMode) return AppTheme.warningColor;
    if (widget.signalStrength >= 80) return AppTheme.successColor;
    if (widget.signalStrength >= 50) return AppTheme.accentColor;
    if (widget.signalStrength >= 20) return AppTheme.warningColor;
    return AppTheme.errorColor;
  }

  String _getQualityText() {
    if (widget.isEmergencyMode) return 'Emergency Mode';
    if (widget.signalStrength >= 80) return 'Excellent';
    if (widget.signalStrength >= 50) return 'Good';
    if (widget.signalStrength >= 20) return 'Fair';
    return 'Poor';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final qualityColor = _getQualityColor();

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.surfaceDark.withValues(alpha: 0.8)
            : AppTheme.surfaceLight.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: qualityColor.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: qualityColor.withValues(alpha: 0.1),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          // Network status header
          Row(
            children: [
              AnimatedBuilder(
                animation: widget.isEmergencyMode
                    ? _emergencyAnimation
                    : _signalAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: widget.networkStatus.toLowerCase() == 'connecting'
                        ? _signalAnimation.value
                        : 1.0,
                    child: Container(
                      width: 3.w,
                      height: 3.w,
                      decoration: BoxDecoration(
                        color: widget.isEmergencyMode
                            ? _emergencyAnimation.value
                            : qualityColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: qualityColor.withValues(alpha: 0.4),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  _getQualityText(),
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: isDark
                        ? AppTheme.textPrimaryDark
                        : AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                  ),
                ),
              ),
              Text(
                widget.currentFrequency,
                style: AppTheme.getMonospaceStyle(
                  isLight: !isDark,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Signal strength bars
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Signal Strength',
                      style:
                          AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                        color: isDark
                            ? AppTheme.textSecondaryDark
                            : AppTheme.textSecondary,
                        fontSize: 11.sp,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Row(
                      children: List.generate(5, (index) {
                        final isActive =
                            index < (widget.signalStrength / 20).ceil();
                        return Container(
                          width: 1.5.w,
                          height: (2 + index * 0.5).h,
                          margin: EdgeInsets.only(right: 1.w),
                          decoration: BoxDecoration(
                            color: isActive
                                ? qualityColor
                                : (isDark
                                    ? AppTheme.textSecondaryDark
                                        .withValues(alpha: 0.3)
                                    : AppTheme.textSecondary
                                        .withValues(alpha: 0.3)),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),

              // Network metrics
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildMetric(
                    'Latency',
                    '${widget.latency}ms',
                    isDark,
                  ),
                  SizedBox(height: 1.h),
                  _buildMetric(
                    'Packet Loss',
                    '${widget.packetLoss.toStringAsFixed(1)}%',
                    isDark,
                  ),
                ],
              ),
            ],
          ),

          if (widget.isEmergencyMode) ...[
            SizedBox(height: 2.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: AppTheme.warningColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.warningColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'warning',
                    color: AppTheme.warningColor,
                    size: 4.w,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      'Extended range mode active - Battery usage increased',
                      style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                        color: AppTheme.warningColor,
                        fontSize: 10.sp,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
            color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
            fontSize: 10.sp,
          ),
        ),
        Text(
          value,
          style: AppTheme.getMonospaceStyle(
            isLight: !isDark,
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
