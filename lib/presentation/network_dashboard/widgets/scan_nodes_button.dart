import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class ScanNodesButton extends StatefulWidget {
  final bool isScanning;
  final VoidCallback onScan;

  const ScanNodesButton({
    super.key,
    required this.isScanning,
    required this.onScan,
  });

  @override
  State<ScanNodesButton> createState() => _ScanNodesButtonState();
}

class _ScanNodesButtonState extends State<ScanNodesButton>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _radarController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _radarAnimation;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _radarController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    _radarAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _radarController,
      curve: Curves.easeOut,
    ));

    if (widget.isScanning) {
      _startAnimations();
    }
  }

  @override
  void didUpdateWidget(ScanNodesButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isScanning != oldWidget.isScanning) {
      if (widget.isScanning) {
        _startAnimations();
      } else {
        _stopAnimations();
      }
    }
  }

  void _startAnimations() {
    _rotationController.repeat();
    _radarController.repeat();
  }

  void _stopAnimations() {
    _rotationController.stop();
    _radarController.stop();
    _rotationController.reset();
    _radarController.reset();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _radarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: widget.isScanning ? null : widget.onScan,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: widget.isScanning
                ? [
                    AppTheme.accentColor.withValues(alpha: 0.8),
                    AppTheme.accentColor,
                  ]
                : [
                    AppTheme.accentColor,
                    AppTheme.accentColor.withValues(alpha: 0.8),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.accentColor.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Radar visualization
            Stack(
              alignment: Alignment.center,
              children: [
                // Radar circles
                if (widget.isScanning)
                  AnimatedBuilder(
                    animation: _radarAnimation,
                    builder: (context, child) {
                      return Container(
                        width: 12.w * (1 + _radarAnimation.value),
                        height: 12.w * (1 + _radarAnimation.value),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.surfaceLight.withValues(
                              alpha: 0.3 * (1 - _radarAnimation.value),
                            ),
                            width: 2,
                          ),
                        ),
                      );
                    },
                  ),

                // Rotating scanner icon
                AnimatedBuilder(
                  animation: _rotationAnimation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotationAnimation.value * 2 * 3.14159,
                      child: Container(
                        width: 12.w,
                        height: 12.w,
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceLight.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: CustomIconWidget(
                            iconName: widget.isScanning ? 'radar' : 'search',
                            color: AppTheme.surfaceLight,
                            size: 6.w,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),

            SizedBox(width: 4.w),

            // Button text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.isScanning
                        ? 'Scannen voor Nodes...'
                        : 'Scan voor FERMesh Nodes',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.surfaceLight,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    widget.isScanning
                        ? 'Zoeken naar beschikbare apparaten'
                        : 'Ontdek nabije FERMesh apparaten',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.surfaceLight.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),

            // Progress indicator
            if (widget.isScanning)
              Container(
                width: 6.w,
                height: 6.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.surfaceLight,
                  ),
                ),
              )
            else
              CustomIconWidget(
                iconName: 'arrow_forward',
                color: AppTheme.surfaceLight,
                size: 6.w,
              ),
          ],
        ),
      ),
    );
  }
}
