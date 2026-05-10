import 'package:flutter/material.dart';
import '../../../core/color_polyfill.dart';
import 'dart:math' as math;
import 'package:sizer/sizer.dart';

class QuantumSecurityAnimationWidget extends StatefulWidget {
  final AnimationController controller;
  final Color color;

  const QuantumSecurityAnimationWidget({
    super.key,
    required this.controller,
    required this.color,
  });

  @override
  State<QuantumSecurityAnimationWidget> createState() =>
      _QuantumSecurityAnimationWidgetState();
}

class _QuantumSecurityAnimationWidgetState
    extends State<QuantumSecurityAnimationWidget> {
  late List<QuantumParticle> particles;
  late List<SecurityLayer> layers;
  late List<EncryptionBlock> blocks;

  @override
  void initState() {
    super.initState();
    _initializeQuantumSystem();
  }

  void _initializeQuantumSystem() {
    // Initialize quantum particles
    particles = List.generate(20, (index) {
      return QuantumParticle(
        position: Offset(
          math.Random().nextDouble() * 80.w,
          math.Random().nextDouble() * 45.h,
        ),
        velocity: Offset(
          (math.Random().nextDouble() - 0.5) * 2,
          (math.Random().nextDouble() - 0.5) * 2,
        ),
        size: math.Random().nextDouble() * 4 + 2,
        phase: math.Random().nextDouble() * 2 * math.pi,
        frequency: math.Random().nextDouble() * 2 + 1,
      );
    });

    // Initialize security layers
    layers = List.generate(4, (index) {
      return SecurityLayer(
        radius: (index + 1) * 40.0,
        thickness: 2.0,
        rotationSpeed: (index + 1) * 0.3,
        opacity: 1.0 - (index * 0.2),
        particleCount: 8 - (index * 2),
      );
    });

    // Initialize encryption blocks
    blocks = List.generate(6, (index) {
      return EncryptionBlock(
        position: Offset(
          (index % 3) * 25.w + 10.w,
          (index ~/ 3) * 15.h + 15.h,
        ),
        size: Size(20.w, 8.h),
        encryptionProgress: 0.0,
        blockType: index % 3,
        animationOffset: index * 0.3,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) {
        return CustomPaint(
          painter: QuantumSecurityPainter(
            animation: widget.controller,
            color: widget.color,
            particles: particles,
            layers: layers,
            blocks: blocks,
          ),
          size: Size(80.w, 45.h),
        );
      },
    );
  }
}

class QuantumSecurityPainter extends CustomPainter {
  final AnimationController animation;
  final Color color;
  final List<QuantumParticle> particles;
  final List<SecurityLayer> layers;
  final List<EncryptionBlock> blocks;

  QuantumSecurityPainter({
    required this.animation,
    required this.color,
    required this.particles,
    required this.layers,
    required this.blocks,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final animValue = animation.value;
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final center = Offset(centerX, centerY);

    // Draw security layers
    _drawSecurityLayers(canvas, center, animValue);

    // Draw quantum particles
    _drawQuantumParticles(canvas, size, animValue);

    // Draw encryption blocks
    _drawEncryptionBlocks(canvas, size, animValue);

    // Draw central quantum core
    _drawQuantumCore(canvas, center, animValue);

    // Draw security shield
    _drawSecurityShield(canvas, center, animValue);
  }

  void _drawSecurityLayers(Canvas canvas, Offset center, double animValue) {
    final layerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (int i = 0; i < layers.length; i++) {
      final layer = layers[i];
      final rotation = animValue * layer.rotationSpeed * 2 * math.pi;

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(rotation);

      // Draw rotating layer ring
      layerPaint.color = color.withValues(alpha: layer.opacity * 0.6);
      canvas.drawCircle(Offset.zero, layer.radius, layerPaint);

      // Draw layer particles
      for (int j = 0; j < layer.particleCount; j++) {
        final angle = (j / layer.particleCount) * 2 * math.pi;
        final particlePos = Offset(
          math.cos(angle) * layer.radius,
          math.sin(angle) * layer.radius,
        );

        final pulse = (math.sin(animValue * 4 * math.pi + j) + 1) / 2;
        final particleSize = 3.0 + pulse * 2.0;

        final particlePaint = Paint()
          ..style = PaintingStyle.fill
          ..color = color.withValues(alpha: layer.opacity);

        canvas.drawCircle(particlePos, particleSize, particlePaint);

        // Draw particle glow
        final glowPaint = Paint()
          ..style = PaintingStyle.fill
          ..color = color.withValues(alpha: layer.opacity * 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

        canvas.drawCircle(particlePos, particleSize * 2, glowPaint);
      }

      canvas.restore();
    }
  }

  void _drawQuantumParticles(Canvas canvas, Size size, double animValue) {
    final particlePaint = Paint()..style = PaintingStyle.fill;

    for (final particle in particles) {
      // Update particle position
      final newPos = particle.position + (particle.velocity * animValue * 100);

      // Wrap around screen edges
      final wrappedX = newPos.dx % size.width;
      final wrappedY = newPos.dy % size.height;
      final currentPos = Offset(wrappedX, wrappedY);

      // Calculate quantum phase
      final phase = math
          .sin(animValue * particle.frequency * 2 * math.pi + particle.phase);
      final alpha = (phase + 1) / 2 * 0.8;
      final currentSize = particle.size * (0.5 + alpha);

      particlePaint.color = color.withValues(alpha: alpha);
      canvas.drawCircle(currentPos, currentSize, particlePaint);

      // Draw quantum trail
      for (int i = 1; i <= 3; i++) {
        final trailPos = currentPos - (particle.velocity * i.toDouble() * 5.0);
        final trailAlpha = alpha * (1.0 - i * 0.3);
        final trailSize = currentSize * (1.0 - i * 0.2);

        particlePaint.color = color.withValues(alpha: trailAlpha);
        canvas.drawCircle(trailPos, trailSize, particlePaint);
      }
    }
  }

  void _drawEncryptionBlocks(Canvas canvas, Size size, double animValue) {
    final blockPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final fillPaint = Paint()..style = PaintingStyle.fill;

    for (final block in blocks) {
      final progress = ((animValue + block.animationOffset) % 1.0);
      final encryptProgress = math.sin(progress * math.pi);

      // Draw block outline
      blockPaint.color = color.withValues(alpha: 0.6);
      final rect = Rect.fromCenter(
        center: block.position,
        width: block.size.width,
        height: block.size.height,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(8)),
        blockPaint,
      );

      // Draw encryption progress
      final progressRect = Rect.fromLTWH(
        rect.left + 4,
        rect.top + 4,
        (rect.width - 8) * encryptProgress,
        rect.height - 8,
      );

      fillPaint.color = color.withValues(alpha: 0.3);
      canvas.drawRRect(
        RRect.fromRectAndRadius(progressRect, const Radius.circular(4)),
        fillPaint,
      );

      // Draw encryption pattern
      _drawEncryptionPattern(canvas, rect, encryptProgress);
    }
  }

  void _drawEncryptionPattern(Canvas canvas, Rect rect, double progress) {
    final patternPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = color.withValues(alpha: progress * 0.8);

    final centerX = rect.center.dx;
    final centerY = rect.center.dy;

    // Draw encryption matrix pattern
    for (int i = 0; i < 5; i++) {
      for (int j = 0; j < 3; j++) {
        if (math.Random().nextDouble() < progress) {
          final x = rect.left + 8 + (i * 12);
          final y = rect.top + 8 + (j * 8);

          canvas.drawRect(
            Rect.fromCenter(center: Offset(x, y), width: 8, height: 4),
            patternPaint,
          );
        }
      }
    }
  }

  void _drawQuantumCore(Canvas canvas, Offset center, double animValue) {
    final corePaint = Paint()..style = PaintingStyle.fill;

    final coreGlowPaint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    // Pulsing core
    final pulse = (math.sin(animValue * 3 * math.pi) + 1) / 2;
    final coreRadius = 8.0 + pulse * 4.0;

    // Draw core glow
    coreGlowPaint.color = color.withValues(alpha: pulse * 0.6);
    canvas.drawCircle(center, coreRadius * 2, coreGlowPaint);

    // Draw core
    corePaint.color = color;
    canvas.drawCircle(center, coreRadius, corePaint);

    // Draw inner quantum field
    corePaint.color = color.withValues(alpha: 0.8);
    canvas.drawCircle(center, coreRadius * 0.6, corePaint);
  }

  void _drawSecurityShield(Canvas canvas, Offset center, double animValue) {
    final shieldPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    // Hexagonal shield pattern
    final shieldRadius = 60.0 + math.sin(animValue * 2 * math.pi) * 5;
    final hexPath = Path();

    for (int i = 0; i < 6; i++) {
      final angle = (i / 6) * 2 * math.pi - math.pi / 2;
      final x = center.dx + math.cos(angle) * shieldRadius;
      final y = center.dy + math.sin(angle) * shieldRadius;

      if (i == 0) {
        hexPath.moveTo(x, y);
      } else {
        hexPath.lineTo(x, y);
      }
    }
    hexPath.close();

    // Animate shield segments
    for (int i = 0; i < 6; i++) {
      final segmentAlpha = (math.sin(animValue * 4 * math.pi + i) + 1) / 2;
      shieldPaint.color = color.withValues(alpha: segmentAlpha * 0.8);

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(i * math.pi / 3);
      canvas.clipRect(Rect.fromLTWH(-shieldRadius, -shieldRadius / 6,
          shieldRadius * 2, shieldRadius / 3));
      canvas.drawPath(hexPath, shieldPaint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class QuantumParticle {
  final Offset position;
  final Offset velocity;
  final double size;
  final double phase;
  final double frequency;

  QuantumParticle({
    required this.position,
    required this.velocity,
    required this.size,
    required this.phase,
    required this.frequency,
  });
}

class SecurityLayer {
  final double radius;
  final double thickness;
  final double rotationSpeed;
  final double opacity;
  final int particleCount;

  SecurityLayer({
    required this.radius,
    required this.thickness,
    required this.rotationSpeed,
    required this.opacity,
    required this.particleCount,
  });
}

class EncryptionBlock {
  final Offset position;
  final Size size;
  final double encryptionProgress;
  final int blockType;
  final double animationOffset;

  EncryptionBlock({
    required this.position,
    required this.size,
    required this.encryptionProgress,
    required this.blockType,
    required this.animationOffset,
  });
}
