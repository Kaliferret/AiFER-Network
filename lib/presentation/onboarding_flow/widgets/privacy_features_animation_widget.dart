import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'dart:math'; // Add this import for cos and sin functions

import '../../../core/app_export.dart';

class PrivacyFeaturesAnimationWidget extends StatefulWidget {
  const PrivacyFeaturesAnimationWidget({super.key});

  @override
  State<PrivacyFeaturesAnimationWidget> createState() =>
      _PrivacyFeaturesAnimationWidgetState();
}

class _PrivacyFeaturesAnimationWidgetState
    extends State<PrivacyFeaturesAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _destructionController;
  late AnimationController _routingController;
  late Animation<double> _destructionAnimation;
  late Animation<double> _routingAnimation;
  late Animation<Color?> _colorAnimation;

  bool _isPackageDestroyed = false;
  int _currentStep = 0;

  final List<String> _destructionSteps = [
    'Bericht verzonden',
    'Ontvanger leest bericht',
    'Zelfvernietiging gestart',
    'Bericht volledig gewist',
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _destructionController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );

    _routingController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _destructionAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _destructionController,
      curve: const Interval(0.6, 1.0, curve: Curves.easeInOut),
    ));

    _routingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _routingController,
      curve: Curves.easeInOut,
    ));

    _colorAnimation = ColorTween(
      begin: AppTheme.successColor,
      end: AppTheme.errorColor,
    ).animate(CurvedAnimation(
      parent: _destructionController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
    ));

    _destructionController.addListener(() {
      final progress = _destructionController.value;
      final newStep = (progress * (_destructionSteps.length - 1)).round();
      if (newStep != _currentStep) {
        setState(() {
          _currentStep = newStep;
        });
      }

      if (progress >= 0.9 && !_isPackageDestroyed) {
        setState(() {
          _isPackageDestroyed = true;
        });
      }
    });

    _routingController.repeat();
  }

  @override
  void dispose() {
    _destructionController.dispose();
    _routingController.dispose();
    super.dispose();
  }

  void _startDestruction() {
    setState(() {
      _isPackageDestroyed = false;
      _currentStep = 0;
    });
    _destructionController.reset();
    _destructionController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: _startDestruction,
      child: Container(
        width: 100.w,
        height: 50.h,
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              isDark
                  ? AppTheme.errorColor.withValues(alpha: 0.1)
                  : AppTheme.errorColor.withValues(alpha: 0.05),
              Colors.transparent,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            // Privacy package visualization
            Expanded(
              flex: 3,
              child: _buildPrivacyPackage(isDark),
            ),

            SizedBox(height: 2.h),

            // Routing visualization
            Expanded(
              flex: 2,
              child: _buildUntracableRouting(isDark),
            ),

            SizedBox(height: 2.h),

            // Destruction steps
            Container(
              width: 100.w,
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: isDark
                    ? AppTheme.surfaceDark.withValues(alpha: 0.5)
                    : AppTheme.surfaceLight.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.errorColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    _destructionSteps[_currentStep],
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: _colorAnimation.value ?? AppTheme.successColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 1.h),
                  LinearProgressIndicator(
                    value: _destructionController.value,
                    backgroundColor: (isDark
                            ? AppTheme.textSecondaryDark
                            : AppTheme.textSecondary)
                        .withValues(alpha: 0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _colorAnimation.value ?? AppTheme.successColor,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 2.h),

            // Interaction hint
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: isDark
                    ? AppTheme.surfaceDark.withValues(alpha: 0.9)
                    : AppTheme.surfaceLight.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.errorColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: 'auto_delete',
                    color: AppTheme.errorColor,
                    size: 16,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Tik om .AiFp zelfvernietiging te zien',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.errorColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyPackage(bool isDark) {
    return Center(
      child: AnimatedBuilder(
        animation: _destructionAnimation,
        builder: (context, child) {
          if (_isPackageDestroyed) {
            return _buildDestructionEffect(isDark);
          }

          return Transform.scale(
            scale: _destructionAnimation.value,
            child: Opacity(
              opacity: _destructionAnimation.value,
              child: Container(
                width: 30.w,
                height: 30.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _colorAnimation.value ?? AppTheme.successColor,
                      (_colorAnimation.value ?? AppTheme.successColor)
                          .withValues(alpha: 0.8),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (_colorAnimation.value ?? AppTheme.successColor)
                          .withValues(alpha: 0.4),
                      blurRadius: 12,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconWidget(
                      iconName: 'enhanced_encryption',
                      color: AppTheme.primaryLight,
                      size: 32,
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      '.AiFp',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDestructionEffect(bool isDark) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Explosion particles
        ...List.generate(8, (index) {
          final angle = (index * 45) * (3.14159 / 180);
          final distance = 15.w;

          return Transform.translate(
            offset: Offset(
              cos(angle) * distance,
              sin(angle) * distance,
            ),
            child: Container(
              width: 2.w,
              height: 2.w,
              decoration: BoxDecoration(
                color: AppTheme.errorColor,
                shape: BoxShape.circle,
              ),
            ),
          );
        }),

        // Destruction message
        Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: AppTheme.errorColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.errorColor,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomIconWidget(
                iconName: 'delete_forever',
                color: AppTheme.errorColor,
                size: 32,
              ),
              SizedBox(height: 1.h),
              Text(
                'VERNIETIGD',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.errorColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUntracableRouting(bool isDark) {
    return AnimatedBuilder(
      animation: _routingAnimation,
      builder: (context, child) {
        return Container(
          width: 100.w,
          height: 15.h,
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: isDark
                ? AppTheme.surfaceDark.withValues(alpha: 0.3)
                : AppTheme.surfaceLight.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.accentColor.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildRoutingNode('A', AppTheme.accentColor, true),
              _buildRoutingArrow(0.25),
              _buildRoutingNode('B', AppTheme.warningColor, false),
              _buildRoutingArrow(0.5),
              _buildRoutingNode('C', AppTheme.successColor, false),
              _buildRoutingArrow(0.75),
              _buildRoutingNode('D', AppTheme.errorColor, true),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRoutingNode(String label, Color color, bool isEndpoint) {
    return Container(
      width: 10.w,
      height: 10.w,
      decoration: BoxDecoration(
        color: isEndpoint ? color : color.withValues(alpha: 0.3),
        shape: BoxShape.circle,
        border: Border.all(
          color: color,
          width: isEndpoint ? 2 : 1,
        ),
      ),
      child: Center(
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: isEndpoint ? AppTheme.surfaceLight : color,
          ),
        ),
      ),
    );
  }

  Widget _buildRoutingArrow(double threshold) {
    final isActive = _routingAnimation.value >= threshold;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: CustomIconWidget(
        iconName: 'arrow_forward',
        color: isActive
            ? AppTheme.accentColor
            : (Theme.of(context).brightness == Brightness.dark
                    ? AppTheme.textSecondaryDark
                    : AppTheme.textSecondary)
                .withValues(alpha: 0.3),
        size: 20,
      ),
    );
  }
}