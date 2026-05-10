import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class RadioStatusCards extends StatelessWidget {
  final List<Map<String, dynamic>> radioData;

  const RadioStatusCards({
    super.key,
    required this.radioData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 12.h,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: radioData.length,
        separatorBuilder: (context, index) => SizedBox(width: 3.w),
        itemBuilder: (context, index) {
          final radio = radioData[index];
          return _RadioCard(
            radioType: radio['type'] as String,
            isActive: radio['isActive'] as bool,
            signalStrength: radio['signalStrength'] as double,
            throughput: radio['throughput'] as String,
          );
        },
      ),
    );
  }
}

class _RadioCard extends StatefulWidget {
  final String radioType;
  final bool isActive;
  final double signalStrength;
  final String throughput;

  const _RadioCard({
    required this.radioType,
    required this.isActive,
    required this.signalStrength,
    required this.throughput,
  });

  @override
  State<_RadioCard> createState() => _RadioCardState();
}

class _RadioCardState extends State<_RadioCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _getRadioIcon() {
    switch (widget.radioType.toLowerCase()) {
      case '5g':
        return 'network_cell';
      case 'wifi':
        return 'wifi';
      case 'bluetooth':
        return 'bluetooth';
      case 'gps':
        return 'gps_fixed';
      default:
        return 'radio';
    }
  }

  Color _getRadioColor() {
    if (!widget.isActive) return AppTheme.textSecondary;

    switch (widget.radioType.toLowerCase()) {
      case '5g':
        return AppTheme.accentColor;
      case 'wifi':
        return AppTheme.successColor;
      case 'bluetooth':
        return const Color(0xFF2196F3);
      case 'gps':
        return AppTheme.warningColor;
      default:
        return AppTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final radioColor = _getRadioColor();

    return GestureDetector(
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) => _animationController.reverse(),
      onTapCancel: () => _animationController.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 20.w,
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.isActive
                      ? radioColor.withValues(alpha: 0.3)
                      : Colors.transparent,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? AppTheme.shadowDark.withValues(alpha: 0.1)
                        : AppTheme.shadowLight.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Radio type and icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.radioType,
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: radioColor,
                        ),
                      ),
                      CustomIconWidget(
                        iconName: _getRadioIcon(),
                        color: radioColor,
                        size: 4.w,
                      ),
                    ],
                  ),

                  // Signal strength bars
                  _buildSignalBars(radioColor),

                  // Throughput
                  Text(
                    widget.throughput,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isDark
                          ? AppTheme.textSecondaryDark
                          : AppTheme.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSignalBars(Color radioColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        final isActive = widget.isActive &&
            (index + 1) <= (widget.signalStrength * 4).ceil();
        return Container(
          width: 2.w,
          height: (index + 1) * 1.h,
          margin: EdgeInsets.symmetric(horizontal: 0.5.w),
          decoration: BoxDecoration(
            color: isActive ? radioColor : radioColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(1),
          ),
        );
      }),
    );
  }
}
