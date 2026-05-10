import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class MeshNetworkAnimationWidget extends StatefulWidget {
  const MeshNetworkAnimationWidget({super.key});

  @override
  State<MeshNetworkAnimationWidget> createState() =>
      _MeshNetworkAnimationWidgetState();
}

class _MeshNetworkAnimationWidgetState extends State<MeshNetworkAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _connectionController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _connectionAnimation;

  final List<DeviceNode> _devices = [
    DeviceNode(
      id: 'device1',
      position: const Offset(0.2, 0.3),
      deviceType: 'smartphone',
      isActive: true,
    ),
    DeviceNode(
      id: 'device2',
      position: const Offset(0.8, 0.2),
      deviceType: 'tablet',
      isActive: true,
    ),
    DeviceNode(
      id: 'device3',
      position: const Offset(0.7, 0.7),
      deviceType: 'laptop',
      isActive: true,
    ),
    DeviceNode(
      id: 'device4',
      position: const Offset(0.3, 0.8),
      deviceType: 'smartphone',
      isActive: false,
    ),
    DeviceNode(
      id: 'device5',
      position: const Offset(0.5, 0.5),
      deviceType: 'router',
      isActive: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _connectionController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _connectionAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _connectionController,
      curve: Curves.easeInOut,
    ));

    _pulseController.repeat(reverse: true);
    _connectionController.repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _connectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        _connectionController.reset();
        _connectionController.forward();
      },
      child: Container(
        width: 100.w,
        height: 50.h,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 0.8,
            colors: [
              isDark
                  ? AppTheme.accentColor.withValues(alpha: 0.1)
                  : AppTheme.accentColor.withValues(alpha: 0.05),
              Colors.transparent,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            // Connection lines
            AnimatedBuilder(
              animation: _connectionAnimation,
              builder: (context, child) {
                return CustomPaint(
                  size: Size(100.w, 50.h),
                  painter: ConnectionLinesPainter(
                    devices: _devices,
                    animationValue: _connectionAnimation.value,
                    isDark: isDark,
                  ),
                );
              },
            ),

            // Device nodes
            ...(_devices.map((device) => _buildDeviceNode(device, isDark))),

            // Tap instruction
            Positioned(
              bottom: 2.h,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppTheme.surfaceDark.withValues(alpha: 0.9)
                        : AppTheme.surfaceLight.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.accentColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIconWidget(
                        iconName: 'touch_app',
                        color: AppTheme.accentColor,
                        size: 16,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Tik om verbindingen te zien',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.accentColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceNode(DeviceNode device, bool isDark) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Positioned(
          left: device.position.dx * 80.w,
          top: device.position.dy * 40.h,
          child: Transform.scale(
            scale: device.isActive ? _pulseAnimation.value : 1.0,
            child: Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: device.isActive
                    ? AppTheme.accentColor
                    : (isDark
                        ? AppTheme.textSecondaryDark
                        : AppTheme.textSecondary),
                shape: BoxShape.circle,
                boxShadow: device.isActive
                    ? [
                        BoxShadow(
                          color: AppTheme.accentColor.withValues(alpha: 0.4),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: _getDeviceIcon(device.deviceType),
                  color: device.isActive
                      ? AppTheme.primaryLight
                      : (isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight),
                  size: 20,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _getDeviceIcon(String deviceType) {
    switch (deviceType) {
      case 'smartphone':
        return 'smartphone';
      case 'tablet':
        return 'tablet_mac';
      case 'laptop':
        return 'laptop_mac';
      case 'router':
        return 'router';
      default:
        return 'device_unknown';
    }
  }
}

class DeviceNode {
  final String id;
  final Offset position;
  final String deviceType;
  final bool isActive;

  DeviceNode({
    required this.id,
    required this.position,
    required this.deviceType,
    required this.isActive,
  });
}

class ConnectionLinesPainter extends CustomPainter {
  final List<DeviceNode> devices;
  final double animationValue;
  final bool isDark;

  ConnectionLinesPainter({
    required this.devices,
    required this.animationValue,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.accentColor.withValues(alpha: 0.6)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final dashedPaint = Paint()
      ..color = (isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary)
          .withValues(alpha: 0.3)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw connections between active devices
    final activeDevices = devices.where((d) => d.isActive).toList();

    for (int i = 0; i < activeDevices.length; i++) {
      for (int j = i + 1; j < activeDevices.length; j++) {
        final start = Offset(
          activeDevices[i].position.dx * size.width * 0.8,
          activeDevices[i].position.dy * size.height * 0.8,
        );
        final end = Offset(
          activeDevices[j].position.dx * size.width * 0.8,
          activeDevices[j].position.dy * size.height * 0.8,
        );

        // Animate connection line
        final animatedEnd = Offset.lerp(start, end, animationValue) ?? end;

        canvas.drawLine(start, animatedEnd, paint);

        // Draw data packet animation
        if (animationValue > 0.5) {
          final packetPosition =
              Offset.lerp(start, end, (animationValue - 0.5) * 2) ?? start;
          canvas.drawCircle(
              packetPosition, 3, Paint()..color = AppTheme.warningColor);
        }
      }
    }

    // Draw dashed lines to inactive devices
    final inactiveDevices = devices.where((d) => !d.isActive).toList();
    for (final inactive in inactiveDevices) {
      if (activeDevices.isNotEmpty) {
        final nearestActive = activeDevices.first;
        final start = Offset(
          nearestActive.position.dx * size.width * 0.8,
          nearestActive.position.dy * size.height * 0.8,
        );
        final end = Offset(
          inactive.position.dx * size.width * 0.8,
          inactive.position.dy * size.height * 0.8,
        );

        _drawDashedLine(canvas, start, end, dashedPaint);
      }
    }
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashWidth = 5.0;
    const dashSpace = 3.0;

    final distance = (end - start).distance;
    final dashCount = (distance / (dashWidth + dashSpace)).floor();

    for (int i = 0; i < dashCount; i++) {
      final startOffset =
          start + (end - start) * (i * (dashWidth + dashSpace) / distance);
      final endOffset = start +
          (end - start) *
              ((i * (dashWidth + dashSpace) + dashWidth) / distance);
      canvas.drawLine(startOffset, endOffset, paint);
    }
  }

  @override
  bool shouldRepaint(ConnectionLinesPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
