import 'package:flutter/material.dart';
import '../../../core/color_polyfill.dart';
import 'dart:math' as math;
import 'package:sizer/sizer.dart';

class NeuralMeshAnimationWidget extends StatefulWidget {
  final AnimationController controller;
  final Color color;

  const NeuralMeshAnimationWidget({
    super.key,
    required this.controller,
    required this.color,
  });

  @override
  State<NeuralMeshAnimationWidget> createState() =>
      _NeuralMeshAnimationWidgetState();
}

class _NeuralMeshAnimationWidgetState extends State<NeuralMeshAnimationWidget> {
  late List<NeuralNode> nodes;
  late List<NeuralConnection> connections;

  @override
  void initState() {
    super.initState();
    _initializeNeuralNetwork();
  }

  void _initializeNeuralNetwork() {
    nodes = List.generate(12, (index) {
      return NeuralNode(
        id: index,
        position: Offset(
          (math.Random().nextDouble() * 0.8 + 0.1) * 80.w,
          (math.Random().nextDouble() * 0.8 + 0.1) * 45.h,
        ),
        size: math.Random().nextDouble() * 8 + 4,
        pulseOffset: math.Random().nextDouble() * 2 * math.pi,
        driftSpeed: math.Random().nextDouble() * 0.5 + 0.2,
        driftAngle: math.Random().nextDouble() * 2 * math.pi,
      );
    });

    connections = [];
    for (int i = 0; i < nodes.length; i++) {
      for (int j = i + 1; j < nodes.length; j++) {
        final distance = (nodes[i].position - nodes[j].position).distance;
        if (distance < 150 && math.Random().nextBool()) {
          connections.add(NeuralConnection(
            from: i,
            to: j,
            strength: math.Random().nextDouble(),
            dataFlowOffset: math.Random().nextDouble() * 2 * math.pi,
          ));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) {
        return CustomPaint(
          painter: NeuralMeshPainter(
            animation: widget.controller,
            color: widget.color,
            nodes: nodes,
            connections: connections,
          ),
          size: Size(80.w, 45.h),
        );
      },
    );
  }
}

class NeuralMeshPainter extends CustomPainter {
  final AnimationController animation;
  final Color color;
  final List<NeuralNode> nodes;
  final List<NeuralConnection> connections;

  NeuralMeshPainter({
    required this.animation,
    required this.color,
    required this.nodes,
    required this.connections,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final animValue = animation.value;

    // Draw connections with data flow
    _drawConnections(canvas, size, animValue);

    // Draw nodes with pulsing effect
    _drawNodes(canvas, size, animValue);

    // Draw data packets
    _drawDataPackets(canvas, size, animValue);
  }

  void _drawConnections(Canvas canvas, Size size, double animValue) {
    final connectionPaint = Paint()
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (final connection in connections) {
      final from = nodes[connection.from];
      final to = nodes[connection.to];

      // Animate connection strength
      final strength =
          (math.sin(animValue * 2 * math.pi + connection.dataFlowOffset) + 1) /
              2;
      final alpha = (connection.strength * strength * 0.6).clamp(0.1, 0.6);

      connectionPaint.color = color.withValues(alpha: alpha);

      // Create gradient effect along connection
      final gradient = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          color.withValues(alpha: alpha * 0.3),
          color.withValues(alpha: alpha),
          color.withValues(alpha: alpha * 0.3),
        ],
        stops: const [0.0, 0.5, 1.0],
      );

      connectionPaint.shader = gradient.createShader(
        Rect.fromPoints(from.position, to.position),
      );

      canvas.drawLine(from.position, to.position, connectionPaint);
    }
  }

  void _drawNodes(Canvas canvas, Size size, double animValue) {
    final nodePaint = Paint()..style = PaintingStyle.fill;

    final nodeGlowPaint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    for (final node in nodes) {
      // Calculate pulsing effect
      final pulse =
          (math.sin(animValue * 3 * math.pi + node.pulseOffset) + 1) / 2;
      final nodeSize = node.size * (0.8 + pulse * 0.4);

      // Calculate drifting position
      final drift = Offset(
        math.cos(animValue * node.driftSpeed * 2 * math.pi + node.driftAngle) *
            10,
        math.sin(animValue * node.driftSpeed * 2 * math.pi + node.driftAngle) *
            10,
      );
      final currentPos = node.position + drift;

      // Draw glow effect
      nodeGlowPaint.color = color.withValues(alpha: pulse * 0.4);
      canvas.drawCircle(currentPos, nodeSize * 1.5, nodeGlowPaint);

      // Draw core node
      nodePaint.color = color.withValues(alpha: 0.8 + pulse * 0.2);
      canvas.drawCircle(currentPos, nodeSize, nodePaint);

      // Draw inner core
      nodePaint.color = color.withValues(alpha: 1.0);
      canvas.drawCircle(currentPos, nodeSize * 0.3, nodePaint);
    }
  }

  void _drawDataPackets(Canvas canvas, Size size, double animValue) {
    final packetPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;

    for (final connection in connections) {
      final from = nodes[connection.from];
      final to = nodes[connection.to];

      // Calculate packet position along connection
      final progress = (animValue + connection.dataFlowOffset) % 1.0;
      final packetPos = Offset.lerp(from.position, to.position, progress)!;

      // Draw data packet
      final packetSize = 3.0 + math.sin(animValue * 4 * math.pi) * 1.0;
      canvas.drawCircle(packetPos, packetSize, packetPaint);

      // Draw packet trail
      for (int i = 1; i <= 3; i++) {
        final trailProgress = (progress - i * 0.05).clamp(0.0, 1.0);
        final trailPos =
            Offset.lerp(from.position, to.position, trailProgress)!;
        final trailAlpha = (1.0 - i * 0.3).clamp(0.0, 1.0);

        packetPaint.color = color.withValues(alpha: trailAlpha * 0.6);
        canvas.drawCircle(trailPos, packetSize * (1.0 - i * 0.2), packetPaint);
      }

      // Reset paint color
      packetPaint.color = color;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class NeuralNode {
  final int id;
  final Offset position;
  final double size;
  final double pulseOffset;
  final double driftSpeed;
  final double driftAngle;

  NeuralNode({
    required this.id,
    required this.position,
    required this.size,
    required this.pulseOffset,
    required this.driftSpeed,
    required this.driftAngle,
  });
}

class NeuralConnection {
  final int from;
  final int to;
  final double strength;
  final double dataFlowOffset;

  NeuralConnection({
    required this.from,
    required this.to,
    required this.strength,
    required this.dataFlowOffset,
  });
}
