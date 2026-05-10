import 'package:flutter/material.dart';
import '../../../core/color_polyfill.dart';
import 'dart:math' as math;
import 'package:sizer/sizer.dart';

class PrivacyShieldAnimationWidget extends StatefulWidget {
  final AnimationController controller;
  final Color color;

  const PrivacyShieldAnimationWidget({
    super.key,
    required this.controller,
    required this.color,
  });

  @override
  State<PrivacyShieldAnimationWidget> createState() =>
      _PrivacyShieldAnimationWidgetState();
}

class _PrivacyShieldAnimationWidgetState
    extends State<PrivacyShieldAnimationWidget> {
  late List<FrequencyBouncer> bouncers;
  late List<AnonymousPacket> packets;
  late List<PrivacyLayer> layers;
  late ShieldCore core;

  @override
  void initState() {
    super.initState();
    _initializePrivacySystem();
  }

  void _initializePrivacySystem() {
    // Initialize frequency bouncers
    bouncers = List.generate(8, (index) {
      final angle = (index / 8) * 2 * math.pi;
      return FrequencyBouncer(
        position: Offset(
          40.w + math.cos(angle) * 25.w,
          22.5.h + math.sin(angle) * 15.h,
        ),
        targetPosition: Offset(
          40.w + math.cos(angle + math.pi) * 25.w,
          22.5.h + math.sin(angle + math.pi) * 15.h,
        ),
        bounceSpeed: math.Random().nextDouble() * 2 + 1,
        size: math.Random().nextDouble() * 6 + 4,
        frequency: math.Random().nextDouble() * 3 + 1,
        phase: math.Random().nextDouble() * 2 * math.pi,
      );
    });

    // Initialize anonymous packets
    packets = List.generate(12, (index) {
      return AnonymousPacket(
        startPosition: Offset(
          math.Random().nextDouble() * 80.w,
          math.Random().nextDouble() * 45.h,
        ),
        velocity: Offset(
          (math.Random().nextDouble() - 0.5) * 4,
          (math.Random().nextDouble() - 0.5) * 4,
        ),
        size: math.Random().nextDouble() * 4 + 2,
        encryptionLevel: math.Random().nextInt(3),
        anonymityStrength: math.Random().nextDouble(),
        lifespan: math.Random().nextDouble() * 5 + 3,
        birthTime: math.Random().nextDouble() * 10,
      );
    });

    // Initialize privacy layers
    layers = List.generate(5, (index) {
      return PrivacyLayer(
        radius: (index + 1) * 25.0,
        thickness: 3.0,
        rotationSpeed: (index % 2 == 0 ? 1 : -1) * (index + 1) * 0.2,
        opacity: 1.0 - (index * 0.15),
        segmentCount: 6 + (index * 2),
        layerType:
            PrivacyLayerType.values[index % PrivacyLayerType.values.length],
      );
    });

    // Initialize shield core
    core = ShieldCore(
      position: Offset(40.w, 22.5.h),
      size: 12.0,
      pulseSpeed: 1.5,
      energyLevel: 1.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) {
        return CustomPaint(
          painter: PrivacyShieldPainter(
            animation: widget.controller,
            color: widget.color,
            bouncers: bouncers,
            packets: packets,
            layers: layers,
            core: core,
          ),
          size: Size(80.w, 45.h),
        );
      },
    );
  }
}

class PrivacyShieldPainter extends CustomPainter {
  final AnimationController animation;
  final Color color;
  final List<FrequencyBouncer> bouncers;
  final List<AnonymousPacket> packets;
  final List<PrivacyLayer> layers;
  final ShieldCore core;

  PrivacyShieldPainter({
    required this.animation,
    required this.color,
    required this.bouncers,
    required this.packets,
    required this.layers,
    required this.core,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final animValue = animation.value;

    // Draw privacy layers
    _drawPrivacyLayers(canvas, animValue);

    // Draw frequency bouncing paths
    _drawFrequencyBouncing(canvas, animValue);

    // Draw anonymous packets
    _drawAnonymousPackets(canvas, size, animValue);

    // Draw shield core
    _drawShieldCore(canvas, animValue);

    // Draw privacy metrics
    _drawPrivacyMetrics(canvas, size, animValue);

    // Draw stealth field
    _drawStealthField(canvas, animValue);
  }

  void _drawPrivacyLayers(Canvas canvas, double animValue) {
    final layerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (int i = 0; i < layers.length; i++) {
      final layer = layers[i];
      final rotation = animValue * layer.rotationSpeed * 2 * math.pi;

      canvas.save();
      canvas.translate(core.position.dx, core.position.dy);
      canvas.rotate(rotation);

      // Draw layer segments
      for (int j = 0; j < layer.segmentCount; j++) {
        final segmentAngle = (j / layer.segmentCount) * 2 * math.pi;
        final nextSegmentAngle = ((j + 1) / layer.segmentCount) * 2 * math.pi;

        // Animate segment visibility
        final segmentPhase = (animValue * 2 + j * 0.3) % 1.0;
        final segmentAlpha =
            _calculateSegmentAlpha(layer.layerType, segmentPhase) *
                layer.opacity;

        layerPaint.color =
            _getLayerColor(layer.layerType).withValues(alpha: segmentAlpha);

        // Draw arc segment
        final rect = Rect.fromCenter(
          center: Offset.zero,
          width: layer.radius * 2,
          height: layer.radius * 2,
        );

        canvas.drawArc(
          rect,
          segmentAngle,
          nextSegmentAngle - segmentAngle,
          false,
          layerPaint,
        );

        // Draw layer nodes
        if (j % 2 == 0) {
          final nodePos = Offset(
            math.cos(segmentAngle) * layer.radius,
            math.sin(segmentAngle) * layer.radius,
          );

          final nodePaint = Paint()
            ..style = PaintingStyle.fill
            ..color =
                _getLayerColor(layer.layerType).withValues(alpha: segmentAlpha);

          canvas.drawCircle(nodePos, 3.0, nodePaint);
        }
      }

      canvas.restore();
    }
  }

  void _drawFrequencyBouncing(Canvas canvas, double animValue) {
    final bouncePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final trailPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (final bouncer in bouncers) {
      // Calculate bouncing position
      final bounceProgress = (animValue * bouncer.bounceSpeed) % 2.0;
      final currentPos = bounceProgress <= 1.0
          ? Offset.lerp(
              bouncer.position, bouncer.targetPosition, bounceProgress)!
          : Offset.lerp(
              bouncer.targetPosition, bouncer.position, bounceProgress - 1.0)!;

      // Calculate frequency modulation
      final frequency =
          math.sin(animValue * bouncer.frequency * 2 * math.pi + bouncer.phase);
      final pulseSize = bouncer.size * (1.0 + frequency * 0.3);
      final alpha = (frequency + 1) / 2 * 0.8;

      // Draw bouncer
      bouncePaint.color = color.withValues(alpha: alpha);
      canvas.drawCircle(currentPos, pulseSize, bouncePaint);

      // Draw frequency trail
      final trailLength = 5;
      for (int i = 1; i <= trailLength; i++) {
        final trailProgress = (bounceProgress - i * 0.1).clamp(0.0, 2.0);
        final trailPos = trailProgress <= 1.0
            ? Offset.lerp(
                bouncer.position, bouncer.targetPosition, trailProgress)!
            : Offset.lerp(
                bouncer.targetPosition, bouncer.position, trailProgress - 1.0)!;

        final trailAlpha = alpha * (1.0 - i / trailLength);
        trailPaint.color = color.withValues(alpha: trailAlpha);

        canvas.drawCircle(trailPos, pulseSize * (1.0 - i * 0.15), trailPaint);
      }

      // Draw bouncing path
      final pathPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..color = color.withValues(alpha: 0.2);

      canvas.drawLine(bouncer.position, bouncer.targetPosition, pathPaint);
    }
  }

  void _drawAnonymousPackets(Canvas canvas, Size size, double animValue) {
    final packetPaint = Paint()..style = PaintingStyle.fill;

    final encryptionRingPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (final packet in packets) {
      final age = (animValue * 10 - packet.birthTime) % packet.lifespan;
      if (age < 0) continue; // Packet not born yet

      // Calculate packet position
      final currentPos = packet.startPosition + (packet.velocity * age * 10);
      final wrappedPos = Offset(
        currentPos.dx % size.width,
        currentPos.dy % size.height,
      );

      // Calculate packet visibility
      final lifeProgress = age / packet.lifespan;
      final visibility =
          math.sin(lifeProgress * math.pi) * packet.anonymityStrength;

      if (visibility <= 0) continue;

      // Draw encryption rings
      for (int i = 0; i <= packet.encryptionLevel; i++) {
        final ringRadius = packet.size + (i * 3);
        final ringAlpha = visibility * (1.0 - i * 0.3) * 0.6;

        encryptionRingPaint.color =
            _getEncryptionColor(i).withValues(alpha: ringAlpha);
        canvas.drawCircle(wrappedPos, ringRadius, encryptionRingPaint);
      }

      // Draw packet core
      packetPaint.color = color.withValues(alpha: visibility);
      canvas.drawCircle(wrappedPos, packet.size, packetPaint);

      // Draw anonymity indicator
      if (packet.anonymityStrength > 0.7) {
        final ghostPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0
          ..color = Colors.white.withValues(alpha: visibility * 0.5);

        canvas.drawCircle(wrappedPos, packet.size * 1.5, ghostPaint);
      }
    }
  }

  void _drawShieldCore(Canvas canvas, double animValue) {
    final corePaint = Paint()..style = PaintingStyle.fill;

    final coreGlowPaint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    // Calculate core pulse
    final pulse = (math.sin(animValue * core.pulseSpeed * 2 * math.pi) + 1) / 2;
    final coreSize = core.size * (0.8 + pulse * 0.4);

    // Draw core glow
    coreGlowPaint.color =
        color.withValues(alpha: pulse * 0.6 * core.energyLevel);
    canvas.drawCircle(core.position, coreSize * 2, coreGlowPaint);

    // Draw core
    corePaint.color = color.withValues(alpha: core.energyLevel);
    canvas.drawCircle(core.position, coreSize, corePaint);

    // Draw core pattern
    final patternPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Colors.white.withValues(alpha: pulse * 0.8);

    canvas.save();
    canvas.translate(core.position.dx, core.position.dy);
    canvas.rotate(animValue * 2 * math.pi);

    // Draw shield symbol
    for (int i = 0; i < 4; i++) {
      canvas.rotate(math.pi / 2);
      canvas.drawLine(
        Offset(0, -coreSize * 0.6),
        Offset(0, coreSize * 0.6),
        patternPaint,
      );
    }

    canvas.restore();
  }

  void _drawPrivacyMetrics(Canvas canvas, Size size, double animValue) {
    final metricsPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw privacy strength meter
    final meterRect = Rect.fromLTWH(10, size.height - 30, 100, 20);
    final privacyStrength = (math.sin(animValue * 2 * math.pi) + 1) / 2;

    metricsPaint.color = color.withValues(alpha: 0.4);
    canvas.drawRect(meterRect, metricsPaint);

    final fillRect = Rect.fromLTWH(
      meterRect.left + 2,
      meterRect.top + 2,
      (meterRect.width - 4) * privacyStrength,
      meterRect.height - 4,
    );

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = color.withValues(alpha: 0.6);

    canvas.drawRect(fillRect, fillPaint);

    // Draw anonymity indicators
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'ANONYMOUS',
        style: TextStyle(
          color: color.withValues(alpha: privacyStrength),
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width - 80, size.height - 25));
  }

  void _drawStealthField(Canvas canvas, double animValue) {
    final stealthPaint = Paint()..style = PaintingStyle.fill;

    // Draw stealth field particles
    for (int i = 0; i < 15; i++) {
      final angle = (i / 15) * 2 * math.pi + (animValue * 2 * math.pi);
      final radius = 50 + math.sin(animValue * 3 * math.pi + i) * 30;

      final particlePos = Offset(
        core.position.dx + math.cos(angle) * radius,
        core.position.dy + math.sin(angle) * radius,
      );

      final alpha = (math.sin(animValue * 4 * math.pi + i) + 1) / 2 * 0.3;
      stealthPaint.color = color.withValues(alpha: alpha);

      canvas.drawCircle(particlePos, 2.0, stealthPaint);
    }

    // Draw distortion field
    final distortionPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (int i = 0; i < 8; i++) {
      final waveRadius = 80 + i * 15;
      final distortion = math.sin(animValue * 3 * math.pi + i * 0.5) * 5;
      final alpha = (1.0 - i / 8) * 0.2;

      distortionPaint.color = color.withValues(alpha: alpha);

      final path = Path();
      for (int j = 0; j < 36; j++) {
        final angle = (j / 36) * 2 * math.pi;
        final currentRadius = waveRadius +
            math.sin(angle * 4 + animValue * 4 * math.pi) * distortion;

        final x = core.position.dx + math.cos(angle) * currentRadius;
        final y = core.position.dy + math.sin(angle) * currentRadius;

        if (j == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();

      canvas.drawPath(path, distortionPaint);
    }
  }

  double _calculateSegmentAlpha(PrivacyLayerType type, double phase) {
    switch (type) {
      case PrivacyLayerType.encryption:
        return (math.sin(phase * 2 * math.pi) + 1) / 2;
      case PrivacyLayerType.anonymization:
        return phase < 0.5 ? phase * 2 : (1 - phase) * 2;
      case PrivacyLayerType.obfuscation:
        return (math.sin(phase * 4 * math.pi).abs());
      case PrivacyLayerType.stealth:
        return math.Random().nextDouble() < 0.3 ? 1.0 : 0.1;
      case PrivacyLayerType.quantum:
        return (math.sin(phase * 8 * math.pi) + 1) / 2;
    }
  }

  Color _getLayerColor(PrivacyLayerType type) {
    switch (type) {
      case PrivacyLayerType.encryption:
        return const Color(0xFF00FF88);
      case PrivacyLayerType.anonymization:
        return const Color(0xFF8800FF);
      case PrivacyLayerType.obfuscation:
        return const Color(0xFFFF8800);
      case PrivacyLayerType.stealth:
        return const Color(0xFF0088FF);
      case PrivacyLayerType.quantum:
        return const Color(0xFFFF0088);
    }
  }

  Color _getEncryptionColor(int level) {
    switch (level) {
      case 0:
        return const Color(0xFF00FF88);
      case 1:
        return const Color(0xFFFFAA00);
      case 2:
        return const Color(0xFFFF0088);
      default:
        return Colors.white;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Data models
enum PrivacyLayerType {
  encryption,
  anonymization,
  obfuscation,
  stealth,
  quantum
}

class FrequencyBouncer {
  final Offset position;
  final Offset targetPosition;
  final double bounceSpeed;
  final double size;
  final double frequency;
  final double phase;

  FrequencyBouncer({
    required this.position,
    required this.targetPosition,
    required this.bounceSpeed,
    required this.size,
    required this.frequency,
    required this.phase,
  });
}

class AnonymousPacket {
  final Offset startPosition;
  final Offset velocity;
  final double size;
  final int encryptionLevel;
  final double anonymityStrength;
  final double lifespan;
  final double birthTime;

  AnonymousPacket({
    required this.startPosition,
    required this.velocity,
    required this.size,
    required this.encryptionLevel,
    required this.anonymityStrength,
    required this.lifespan,
    required this.birthTime,
  });
}

class PrivacyLayer {
  final double radius;
  final double thickness;
  final double rotationSpeed;
  final double opacity;
  final int segmentCount;
  final PrivacyLayerType layerType;

  PrivacyLayer({
    required this.radius,
    required this.thickness,
    required this.rotationSpeed,
    required this.opacity,
    required this.segmentCount,
    required this.layerType,
  });
}

class ShieldCore {
  final Offset position;
  final double size;
  final double pulseSpeed;
  final double energyLevel;

  ShieldCore({
    required this.position,
    required this.size,
    required this.pulseSpeed,
    required this.energyLevel,
  });
}
