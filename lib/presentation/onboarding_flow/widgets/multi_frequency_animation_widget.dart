import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'dart:math'; // Add this import for sin function

import '../../../core/app_export.dart';

class MultiFrequencyAnimationWidget extends StatefulWidget {
  const MultiFrequencyAnimationWidget({super.key});

  @override
  State<MultiFrequencyAnimationWidget> createState() =>
      _MultiFrequencyAnimationWidgetState();
}

class _MultiFrequencyAnimationWidgetState
    extends State<MultiFrequencyAnimationWidget> with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _chipController;
  late Animation<double> _waveAnimation;
  late Animation<double> _chipAnimation;

  final List<RadioChip> _radioChips = [
    RadioChip(
      name: '5G',
      frequency: '28 GHz',
      color: AppTheme.errorColor,
      icon: 'signal_cellular_4_bar',
      position: const Offset(0.2, 0.3),
      isActive: true,
    ),
    RadioChip(
      name: 'WiFi',
      frequency: '2.4 GHz',
      color: AppTheme.accentColor,
      icon: 'wifi',
      position: const Offset(0.8, 0.2),
      isActive: true,
    ),
    RadioChip(
      name: 'Bluetooth',
      frequency: '2.4 GHz',
      color: AppTheme.warningColor,
      icon: 'bluetooth',
      position: const Offset(0.7, 0.7),
      isActive: false,
    ),
    RadioChip(
      name: 'GPS',
      frequency: '1.5 GHz',
      color: AppTheme.successColor,
      icon: 'gps_fixed',
      position: const Offset(0.3, 0.8),
      isActive: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _chipController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _waveController,
      curve: Curves.easeInOut,
    ));

    _chipAnimation = Tween<double>(
      begin: 0.8,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _chipController,
      curve: Curves.elasticInOut,
    ));

    _waveController.repeat();
    _chipController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _waveController.dispose();
    _chipController.dispose();
    super.dispose();
  }

  void _toggleChip(int index) {
    setState(() {
      _radioChips[index] = RadioChip(
        name: _radioChips[index].name,
        frequency: _radioChips[index].frequency,
        color: _radioChips[index].color,
        icon: _radioChips[index].icon,
        position: _radioChips[index].position,
        isActive: !_radioChips[index].isActive,
      );
    });

    _chipController.reset();
    _chipController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 100.w,
      height: 50.h,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.0,
          colors: [
            isDark
                ? AppTheme.primaryLight.withValues(alpha: 0.1)
                : AppTheme.primaryLight.withValues(alpha: 0.05),
            Colors.transparent,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          // Central device
          Center(
            child: Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryLight,
                    AppTheme.primaryLight.withValues(alpha: 0.8),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryLight.withValues(alpha: 0.3),
                    blurRadius: 12,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'smartphone',
                  color: AppTheme.surfaceLight,
                  size: 32,
                ),
              ),
            ),
          ),

          // Radio waves
          AnimatedBuilder(
            animation: _waveAnimation,
            builder: (context, child) {
              return CustomPaint(
                size: Size(100.w, 50.h),
                painter: RadioWavesPainter(
                  animationValue: _waveAnimation.value,
                  isDark: isDark,
                  activeChips:
                      _radioChips.where((chip) => chip.isActive).toList(),
                ),
              );
            },
          ),

          // Radio chips
          ...(_radioChips.asMap().entries.map((entry) {
            final index = entry.key;
            final chip = entry.value;
            return _buildRadioChip(chip, index, isDark);
          })),

          // Frequency bouncing indicator
          Positioned(
            top: 2.h,
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
                      iconName: 'settings_input_antenna',
                      color: AppTheme.accentColor,
                      size: 16,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Multi-frequentie transmissie',
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

          // Instruction
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
                    color: AppTheme.warningColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(
                      iconName: 'touch_app',
                      color: AppTheme.warningColor,
                      size: 16,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Tik op chips om aan/uit te zetten',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.warningColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioChip(RadioChip chip, int index, bool isDark) {
    return AnimatedBuilder(
      animation: _chipAnimation,
      builder: (context, child) {
        return Positioned(
          left: chip.position.dx * 80.w,
          top: chip.position.dy * 40.h,
          child: GestureDetector(
            onTap: () => _toggleChip(index),
            child: Transform.scale(
              scale: chip.isActive ? _chipAnimation.value : 1.0,
              child: Container(
                width: 18.w,
                height: 12.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: chip.isActive
                        ? [
                            chip.color,
                            chip.color.withValues(alpha: 0.8),
                          ]
                        : [
                            (isDark
                                ? AppTheme.textSecondaryDark
                                : AppTheme.textSecondary),
                            (isDark
                                    ? AppTheme.textSecondaryDark
                                    : AppTheme.textSecondary)
                                .withValues(alpha: 0.8),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: chip.isActive
                      ? [
                          BoxShadow(
                            color: chip.color.withValues(alpha: 0.4),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconWidget(
                      iconName: chip.icon,
                      color: chip.isActive
                          ? AppTheme.surfaceLight
                          : (isDark
                              ? AppTheme.surfaceDark
                              : AppTheme.surfaceLight),
                      size: 20,
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      chip.name,
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: chip.isActive
                            ? AppTheme.surfaceLight
                            : (isDark
                                ? AppTheme.surfaceDark
                                : AppTheme.surfaceLight),
                      ),
                    ),
                    Text(
                      chip.frequency,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 8.sp,
                        fontWeight: FontWeight.w400,
                        color: chip.isActive
                            ? AppTheme.surfaceLight.withValues(alpha: 0.8)
                            : (isDark
                                    ? AppTheme.surfaceDark
                                    : AppTheme.surfaceLight)
                                .withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class RadioChip {
  final String name;
  final String frequency;
  final Color color;
  final String icon;
  final Offset position;
  final bool isActive;

  RadioChip({
    required this.name,
    required this.frequency,
    required this.color,
    required this.icon,
    required this.position,
    required this.isActive,
  });
}

class RadioWavesPainter extends CustomPainter {
  final double animationValue;
  final bool isDark;
  final List<RadioChip> activeChips;

  RadioWavesPainter({
    required this.animationValue,
    required this.isDark,
    required this.activeChips,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Draw concentric waves from center
    for (int i = 0; i < 4; i++) {
      final radius = (20 + i * 15) * (1 + animationValue * 0.5);
      final opacity = (1.0 - (i * 0.2)) * (1.0 - animationValue);

      final paint = Paint()
        ..color = AppTheme.accentColor.withValues(alpha: opacity * 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawCircle(Offset(centerX, centerY), radius, paint);
    }

    // Draw frequency-specific waves to active chips
    for (final chip in activeChips) {
      final chipX = chip.position.dx * size.width * 0.8;
      final chipY = chip.position.dy * size.height * 0.8;

      _drawFrequencyWave(
        canvas,
        Offset(centerX, centerY),
        Offset(chipX, chipY),
        chip.color,
        animationValue,
      );
    }
  }

  void _drawFrequencyWave(
    Canvas canvas,
    Offset start,
    Offset end,
    Color color,
    double animationValue,
  ) {
    final distance = (end - start).distance;
    final steps = (distance / 10).round();

    final paint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final path = Path();
    path.moveTo(start.dx, start.dy);

    for (int i = 0; i <= steps; i++) {
      final t = i / steps;
      final point = Offset.lerp(start, end, t)!;

      // Add wave effect
      final waveOffset = sin((t * 10 + animationValue * 6.28) * 2) * 5;
      final perpendicular = Offset(
        -(end.dy - start.dy) / distance,
        (end.dx - start.dx) / distance,
      );

      final wavePoint = point + perpendicular * waveOffset;

      if (i == 0) {
        path.moveTo(wavePoint.dx, wavePoint.dy);
      } else {
        path.lineTo(wavePoint.dx, wavePoint.dy);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(RadioWavesPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.activeChips.length != activeChips.length;
  }
}