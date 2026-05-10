import 'package:flutter/material.dart';
import '../../../core/color_polyfill.dart';
import 'dart:math' as math;
import 'package:sizer/sizer.dart';

class HolographicConnectivityAnimationWidget extends StatefulWidget {
  final AnimationController controller;
  final Color color;

  const HolographicConnectivityAnimationWidget({
    super.key,
    required this.controller,
    required this.color,
  });

  @override
  State<HolographicConnectivityAnimationWidget> createState() =>
      _HolographicConnectivityAnimationWidgetState();
}

class _HolographicConnectivityAnimationWidgetState
    extends State<HolographicConnectivityAnimationWidget> {
  late List<HolographicNode> nodes;
  late List<DataStream> streams;
  late List<FrequencyWave> waves;

  @override
  void initState() {
    super.initState();
    _initializeHolographicSystem();
  }

  void _initializeHolographicSystem() {
    // Initialize holographic nodes (representing different connectivity types)
    nodes = [
      // Central hub
      HolographicNode(
        position: Offset(40.w, 22.5.h),
        size: 16.0,
        nodeType: HolographicNodeType.hub,
        pulseSpeed: 1.0,
        rotationSpeed: 0.5,
        connections: [1, 2, 3, 4],
      ),
      // 5G Node
      HolographicNode(
        position: Offset(15.w, 10.h),
        size: 12.0,
        nodeType: HolographicNodeType.fiveG,
        pulseSpeed: 1.5,
        rotationSpeed: 0.8,
        connections: [0, 5],
      ),
      // WiFi Node
      HolographicNode(
        position: Offset(65.w, 10.h),
        size: 12.0,
        nodeType: HolographicNodeType.wifi,
        pulseSpeed: 1.2,
        rotationSpeed: -0.6,
        connections: [0, 6],
      ),
      // Bluetooth Node
      HolographicNode(
        position: Offset(15.w, 35.h),
        size: 10.0,
        nodeType: HolographicNodeType.bluetooth,
        pulseSpeed: 2.0,
        rotationSpeed: 1.2,
        connections: [0, 7],
      ),
      // GPS Node
      HolographicNode(
        position: Offset(65.w, 35.h),
        size: 10.0,
        nodeType: HolographicNodeType.gps,
        pulseSpeed: 0.8,
        rotationSpeed: -0.4,
        connections: [0, 8],
      ),
      // Satellite connections
      HolographicNode(
        position: Offset(5.w, 5.h),
        size: 8.0,
        nodeType: HolographicNodeType.satellite,
        pulseSpeed: 0.6,
        rotationSpeed: 0.3,
        connections: [1],
      ),
      HolographicNode(
        position: Offset(75.w, 5.h),
        size: 8.0,
        nodeType: HolographicNodeType.satellite,
        pulseSpeed: 0.6,
        rotationSpeed: -0.3,
        connections: [2],
      ),
      HolographicNode(
        position: Offset(5.w, 40.h),
        size: 6.0,
        nodeType: HolographicNodeType.device,
        pulseSpeed: 1.8,
        rotationSpeed: 0.9,
        connections: [3],
      ),
      HolographicNode(
        position: Offset(75.w, 40.h),
        size: 6.0,
        nodeType: HolographicNodeType.device,
        pulseSpeed: 1.8,
        rotationSpeed: -0.9,
        connections: [4],
      ),
    ];

    // Initialize data streams
    streams = [];
    for (int i = 0; i < nodes.length; i++) {
      for (final connectionIndex in nodes[i].connections) {
        if (connectionIndex < nodes.length && i < connectionIndex) {
          streams.add(DataStream(
            fromIndex: i,
            toIndex: connectionIndex,
            speed: math.Random().nextDouble() * 2 + 1,
            dataPackets: _generateDataPackets(),
            streamType: _getStreamType(
                nodes[i].nodeType, nodes[connectionIndex].nodeType),
          ));
        }
      }
    }

    // Initialize frequency waves
    waves = List.generate(4, (index) {
      return FrequencyWave(
        center: Offset(40.w, 22.5.h),
        radius: (index + 1) * 30.0,
        frequency: (index + 1) * 0.5,
        amplitude: 5.0,
        waveType: FrequencyType.values[index % FrequencyType.values.length],
      );
    });
  }

  List<DataPacket> _generateDataPackets() {
    return List.generate(3, (index) {
      return DataPacket(
        progress: math.Random().nextDouble(),
        size: math.Random().nextDouble() * 3 + 2,
        packetType: DataPacketType
            .values[math.Random().nextInt(DataPacketType.values.length)],
      );
    });
  }

  StreamType _getStreamType(HolographicNodeType from, HolographicNodeType to) {
    if (from == HolographicNodeType.hub || to == HolographicNodeType.hub) {
      return StreamType.highSpeed;
    } else if (from == HolographicNodeType.satellite ||
        to == HolographicNodeType.satellite) {
      return StreamType.satellite;
    } else {
      return StreamType.local;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) {
        return CustomPaint(
          painter: HolographicConnectivityPainter(
            animation: widget.controller,
            color: widget.color,
            nodes: nodes,
            streams: streams,
            waves: waves,
          ),
          size: Size(80.w, 45.h),
        );
      },
    );
  }
}

class HolographicConnectivityPainter extends CustomPainter {
  final AnimationController animation;
  final Color color;
  final List<HolographicNode> nodes;
  final List<DataStream> streams;
  final List<FrequencyWave> waves;

  HolographicConnectivityPainter({
    required this.animation,
    required this.color,
    required this.nodes,
    required this.streams,
    required this.waves,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final animValue = animation.value;

    // Draw frequency waves
    _drawFrequencyWaves(canvas, animValue);

    // Draw holographic connections
    _drawHolographicConnections(canvas, animValue);

    // Draw data streams
    _drawDataStreams(canvas, animValue);

    // Draw holographic nodes
    _drawHolographicNodes(canvas, animValue);

    // Draw AI routing paths
    _drawAIRoutingPaths(canvas, animValue);
  }

  void _drawFrequencyWaves(Canvas canvas, double animValue) {
    final wavePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (final wave in waves) {
      final waveRadius = wave.radius +
          math.sin(animValue * wave.frequency * 2 * math.pi) * wave.amplitude;
      final alpha =
          (math.sin(animValue * wave.frequency * 2 * math.pi + math.pi / 2) +
                  1) /
              2 *
              0.4;

      wavePaint.color = _getWaveColor(wave.waveType).withValues(alpha: alpha);

      // Create dashed circle effect
      final dashPath = Path();
      final circumference = 2 * math.pi * waveRadius;
      final dashLength = 10.0;
      final dashCount = (circumference / (dashLength * 2)).floor();

      for (int i = 0; i < dashCount; i++) {
        final startAngle =
            (i * 2 * dashLength / waveRadius) + (animValue * 2 * math.pi);
        final endAngle = startAngle + (dashLength / waveRadius);

        final startX = wave.center.dx + math.cos(startAngle) * waveRadius;
        final startY = wave.center.dy + math.sin(startAngle) * waveRadius;
        final endX = wave.center.dx + math.cos(endAngle) * waveRadius;
        final endY = wave.center.dy + math.sin(endAngle) * waveRadius;

        dashPath.moveTo(startX, startY);
        dashPath.arcToPoint(
          Offset(endX, endY),
          radius: Radius.circular(waveRadius),
        );
      }

      canvas.drawPath(dashPath, wavePaint);
    }
  }

  void _drawHolographicConnections(Canvas canvas, double animValue) {
    final connectionPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (final stream in streams) {
      final from = nodes[stream.fromIndex];
      final to = nodes[stream.toIndex];

      // Create holographic connection effect
      final connectionStrength =
          (math.sin(animValue * 3 * math.pi + stream.speed) + 1) / 2;
      final alpha = (0.3 + connectionStrength * 0.5).clamp(0.1, 0.8);

      connectionPaint.color =
          _getStreamColor(stream.streamType).withValues(alpha: alpha);

      // Draw main connection
      canvas.drawLine(from.position, to.position, connectionPaint);

      // Draw holographic shimmer effect
      connectionPaint.strokeWidth = 1.0;
      connectionPaint.color = color.withValues(alpha: connectionStrength * 0.3);

      final shimmerOffset = Offset(
        math.sin(animValue * 4 * math.pi) * 2,
        math.cos(animValue * 4 * math.pi) * 2,
      );

      canvas.drawLine(
        from.position + shimmerOffset,
        to.position + shimmerOffset,
        connectionPaint,
      );

      connectionPaint.strokeWidth = 2.0;
    }
  }

  void _drawDataStreams(Canvas canvas, double animValue) {
    final packetPaint = Paint()..style = PaintingStyle.fill;

    for (final stream in streams) {
      final from = nodes[stream.fromIndex];
      final to = nodes[stream.toIndex];

      for (final packet in stream.dataPackets) {
        final progress = (packet.progress + animValue * stream.speed) % 1.0;
        final packetPos = Offset.lerp(from.position, to.position, progress)!;

        // Draw data packet with type-specific styling
        packetPaint.color = _getPacketColor(packet.packetType);

        final pulseSize =
            packet.size * (1.0 + math.sin(animValue * 6 * math.pi) * 0.3);
        canvas.drawCircle(packetPos, pulseSize, packetPaint);

        // Draw packet trail
        for (int i = 1; i <= 2; i++) {
          final trailProgress = (progress - i * 0.1).clamp(0.0, 1.0);
          final trailPos =
              Offset.lerp(from.position, to.position, trailProgress)!;
          final trailAlpha = (1.0 - i * 0.4).clamp(0.0, 1.0);

          packetPaint.color =
              _getPacketColor(packet.packetType).withValues(alpha: trailAlpha);
          canvas.drawCircle(trailPos, pulseSize * (1.0 - i * 0.3), packetPaint);
        }
      }
    }
  }

  void _drawHolographicNodes(Canvas canvas, double animValue) {
    final nodePaint = Paint()..style = PaintingStyle.fill;

    final nodeGlowPaint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    for (final node in nodes) {
      // Calculate node pulse
      final pulse =
          (math.sin(animValue * node.pulseSpeed * 2 * math.pi) + 1) / 2;
      final nodeSize = node.size * (0.8 + pulse * 0.4);

      // Calculate rotation
      final rotation = animValue * node.rotationSpeed * 2 * math.pi;

      canvas.save();
      canvas.translate(node.position.dx, node.position.dy);
      canvas.rotate(rotation);

      // Draw node glow
      nodeGlowPaint.color =
          _getNodeColor(node.nodeType).withValues(alpha: pulse * 0.6);
      canvas.drawCircle(Offset.zero, nodeSize * 1.5, nodeGlowPaint);

      // Draw node based on type
      _drawNodeByType(canvas, node, nodeSize, pulse);

      canvas.restore();
    }
  }

  void _drawNodeByType(
      Canvas canvas, HolographicNode node, double size, double pulse) {
    final nodePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = _getNodeColor(node.nodeType);

    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = _getNodeColor(node.nodeType);

    switch (node.nodeType) {
      case HolographicNodeType.hub:
        // Draw central hub as complex star
        _drawComplexStar(canvas, Offset.zero, size, 8, nodePaint);
        break;

      case HolographicNodeType.fiveG:
        // Draw 5G as pentagon with internal pattern
        _drawPentagon(canvas, Offset.zero, size, nodePaint);
        _draw5GPattern(canvas, Offset.zero, size * 0.6, outlinePaint);
        break;

      case HolographicNodeType.wifi:
        // Draw WiFi as concentric arcs
        _drawWiFiSymbol(canvas, Offset.zero, size, outlinePaint);
        break;

      case HolographicNodeType.bluetooth:
        // Draw Bluetooth symbol
        _drawBluetoothSymbol(canvas, Offset.zero, size, outlinePaint);
        break;

      case HolographicNodeType.gps:
        // Draw GPS as diamond with crosshairs
        _drawDiamond(canvas, Offset.zero, size, nodePaint);
        _drawCrosshairs(canvas, Offset.zero, size * 0.8, outlinePaint);
        break;

      case HolographicNodeType.satellite:
        // Draw satellite as triangle
        _drawTriangle(canvas, Offset.zero, size, nodePaint);
        break;

      case HolographicNodeType.device:
        // Draw device as hexagon
        _drawHexagon(canvas, Offset.zero, size, nodePaint);
        break;
    }
  }

  void _drawComplexStar(
      Canvas canvas, Offset center, double size, int points, Paint paint) {
    final path = Path();
    final angleStep = (2 * math.pi) / points;

    for (int i = 0; i < points; i++) {
      final outerAngle = i * angleStep - math.pi / 2;
      final innerAngle = (i + 0.5) * angleStep - math.pi / 2;

      final outerX = center.dx + math.cos(outerAngle) * size;
      final outerY = center.dy + math.sin(outerAngle) * size;
      final innerX = center.dx + math.cos(innerAngle) * size * 0.5;
      final innerY = center.dy + math.sin(innerAngle) * size * 0.5;

      if (i == 0) {
        path.moveTo(outerX, outerY);
      } else {
        path.lineTo(outerX, outerY);
      }
      path.lineTo(innerX, innerY);
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  void _drawPentagon(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angle = (i * 2 * math.pi / 5) - math.pi / 2;
      final x = center.dx + math.cos(angle) * size;
      final y = center.dy + math.sin(angle) * size;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _draw5GPattern(Canvas canvas, Offset center, double size, Paint paint) {
    // Draw 5G internal pattern
    canvas.drawLine(
      Offset(center.dx - size / 2, center.dy),
      Offset(center.dx + size / 2, center.dy),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - size / 2),
      Offset(center.dx, center.dy + size / 2),
      paint,
    );
  }

  void _drawWiFiSymbol(Canvas canvas, Offset center, double size, Paint paint) {
    for (int i = 1; i <= 3; i++) {
      final radius = size * i / 3;
      final rect = Rect.fromCenter(
          center: center, width: radius * 2, height: radius * 2);
      canvas.drawArc(rect, -math.pi / 4, math.pi / 2, false, paint);
    }
  }

  void _drawBluetoothSymbol(
      Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    path.moveTo(center.dx, center.dy - size);
    path.lineTo(center.dx + size / 2, center.dy - size / 2);
    path.lineTo(center.dx - size / 2, center.dy);
    path.lineTo(center.dx + size / 2, center.dy + size / 2);
    path.lineTo(center.dx, center.dy + size);
    path.lineTo(center.dx, center.dy - size);
    canvas.drawPath(path, paint);
  }

  void _drawDiamond(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    path.moveTo(center.dx, center.dy - size);
    path.lineTo(center.dx + size, center.dy);
    path.lineTo(center.dx, center.dy + size);
    path.lineTo(center.dx - size, center.dy);
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawCrosshairs(Canvas canvas, Offset center, double size, Paint paint) {
    canvas.drawLine(
      Offset(center.dx - size, center.dy),
      Offset(center.dx + size, center.dy),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - size),
      Offset(center.dx, center.dy + size),
      paint,
    );
  }

  void _drawTriangle(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    path.moveTo(center.dx, center.dy - size);
    path.lineTo(center.dx + size * 0.866, center.dy + size / 2);
    path.lineTo(center.dx - size * 0.866, center.dy + size / 2);
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawHexagon(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = i * math.pi / 3;
      final x = center.dx + math.cos(angle) * size;
      final y = center.dy + math.sin(angle) * size;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawAIRoutingPaths(Canvas canvas, double animValue) {
    final aiPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw AI decision paths as flowing curves
    for (int i = 0; i < 3; i++) {
      final progress = (animValue + i * 0.3) % 1.0;
      final alpha = math.sin(progress * math.pi) * 0.6;

      aiPaint.color = color.withValues(alpha: alpha);

      final path = Path();
      final startNode = nodes[0]; // Hub
      final endNode = nodes[i + 1];

      // Create curved path
      final controlPoint = Offset(
        (startNode.position.dx + endNode.position.dx) / 2 +
            math.sin(animValue * 2 * math.pi) * 20,
        (startNode.position.dy + endNode.position.dy) / 2 +
            math.cos(animValue * 2 * math.pi) * 20,
      );

      path.moveTo(startNode.position.dx, startNode.position.dy);
      path.quadraticBezierTo(
        controlPoint.dx,
        controlPoint.dy,
        endNode.position.dx,
        endNode.position.dy,
      );

      canvas.drawPath(path, aiPaint);
    }
  }

  Color _getWaveColor(FrequencyType type) {
    switch (type) {
      case FrequencyType.fiveG:
        return const Color(0xFF00F5FF);
      case FrequencyType.wifi:
        return const Color(0xFF00FF88);
      case FrequencyType.bluetooth:
        return const Color(0xFF8800FF);
      case FrequencyType.gps:
        return const Color(0xFFFFAA00);
    }
  }

  Color _getNodeColor(HolographicNodeType type) {
    switch (type) {
      case HolographicNodeType.hub:
        return color;
      case HolographicNodeType.fiveG:
        return const Color(0xFF00F5FF);
      case HolographicNodeType.wifi:
        return const Color(0xFF00FF88);
      case HolographicNodeType.bluetooth:
        return const Color(0xFF8800FF);
      case HolographicNodeType.gps:
        return const Color(0xFFFFAA00);
      case HolographicNodeType.satellite:
        return const Color(0xFFFF6600);
      case HolographicNodeType.device:
        return const Color(0xFFFF0088);
    }
  }

  Color _getStreamColor(StreamType type) {
    switch (type) {
      case StreamType.highSpeed:
        return const Color(0xFF00F5FF);
      case StreamType.satellite:
        return const Color(0xFFFF6600);
      case StreamType.local:
        return const Color(0xFF00FF88);
    }
  }

  Color _getPacketColor(DataPacketType type) {
    switch (type) {
      case DataPacketType.data:
        return const Color(0xFF00F5FF);
      case DataPacketType.voice:
        return const Color(0xFF00FF88);
      case DataPacketType.video:
        return const Color(0xFFFF0088);
      case DataPacketType.control:
        return const Color(0xFFFFAA00);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Data models
enum HolographicNodeType { hub, fiveG, wifi, bluetooth, gps, satellite, device }

enum FrequencyType { fiveG, wifi, bluetooth, gps }

enum StreamType { highSpeed, satellite, local }

enum DataPacketType { data, voice, video, control }

class HolographicNode {
  final Offset position;
  final double size;
  final HolographicNodeType nodeType;
  final double pulseSpeed;
  final double rotationSpeed;
  final List<int> connections;

  HolographicNode({
    required this.position,
    required this.size,
    required this.nodeType,
    required this.pulseSpeed,
    required this.rotationSpeed,
    required this.connections,
  });
}

class DataStream {
  final int fromIndex;
  final int toIndex;
  final double speed;
  final List<DataPacket> dataPackets;
  final StreamType streamType;

  DataStream({
    required this.fromIndex,
    required this.toIndex,
    required this.speed,
    required this.dataPackets,
    required this.streamType,
  });
}

class DataPacket {
  final double progress;
  final double size;
  final DataPacketType packetType;

  DataPacket({
    required this.progress,
    required this.size,
    required this.packetType,
  });
}

class FrequencyWave {
  final Offset center;
  final double radius;
  final double frequency;
  final double amplitude;
  final FrequencyType waveType;

  FrequencyWave({
    required this.center,
    required this.radius,
    required this.frequency,
    required this.amplitude,
    required this.waveType,
  });
}
