import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../../../core/app_export.dart';

/// Quantum-inspired logo animation widget for FERMesh branding
class QuantumLogoAnimation extends StatefulWidget {
  final double size;
  final VoidCallback? onAnimationComplete;

  const QuantumLogoAnimation({
    super.key,
    this.size = 120.0,
    this.onAnimationComplete,
  });

  @override
  State<QuantumLogoAnimation> createState() => _QuantumLogoAnimationState();
}

class _QuantumLogoAnimationState extends State<QuantumLogoAnimation>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _scaleController;

  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();
  }

  void _initializeAnimations() {
    // Pulse animation for quantum effect
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Rotation animation for mesh network visualization
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    // Scale animation for entrance effect
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
  }

  void _startAnimationSequence() async {
    // Start scale animation first
    await _scaleController.forward();

    // Start continuous animations
    _pulseController.repeat(reverse: true);
    _rotationController.repeat();

    // Complete after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      widget.onAnimationComplete?.call();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: Listenable.merge([
        _pulseAnimation,
        _rotationAnimation,
        _scaleAnimation,
      ]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value * 2 * 3.14159,
            child: Container(
              width: widget.size,
              height: widget.size,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer quantum ring
                  Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: widget.size,
                      height: widget.size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.accentColor.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                    ),
                  ),

                  // Middle mesh network ring
                  Transform.scale(
                    scale: 0.7,
                    child: Container(
                      width: widget.size,
                      height: widget.size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.accentColor.withValues(alpha: 0.6),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),

                  // Inner core with FER logo
                  Container(
                    width: widget.size * 0.5,
                    height: widget.size * 0.5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [
                          AppTheme.accentColor,
                          Color.fromRGBO(0, 229, 255, 0.8),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.accentColor.withValues(alpha: 0.4),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'FER',
                        style: GoogleFonts.inter(
                          fontSize: widget.size * 0.15,
                          fontWeight: FontWeight.w900,
                          color: isDark
                              ? AppTheme.primaryLight
                              : AppTheme.surfaceLight,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),

                  // Quantum particles
                  ...List.generate(6, (index) {
                    final angle = (index * 60) * (3.14159 / 180);
                    final radius = widget.size * 0.35;

                    return Transform.translate(
                      offset: Offset(
                        radius *
                            math.cos(
                                angle + _rotationAnimation.value * 2 * 3.14159),
                        radius *
                            math.sin(
                                angle + _rotationAnimation.value * 2 * 3.14159),
                      ),
                      child: Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.accentColor,
                          boxShadow: [
                            BoxShadow(
                              color:
                                  AppTheme.accentColor.withValues(alpha: 0.6),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}