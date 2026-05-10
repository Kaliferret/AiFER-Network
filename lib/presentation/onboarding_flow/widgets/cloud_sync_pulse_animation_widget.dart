import 'package:flutter/material.dart';
import '../../../core/color_polyfill.dart';
import 'dart:math' as math;
import 'package:sizer/sizer.dart';

class CloudSyncPulseAnimationWidget extends StatefulWidget {
  final AnimationController controller;
  final Color color;
  final String? connectionStatus;
  final bool isConnecting;

  const CloudSyncPulseAnimationWidget({
    super.key,
    required this.controller,
    required this.color,
    this.connectionStatus,
    required this.isConnecting,
  });

  @override
  State<CloudSyncPulseAnimationWidget> createState() =>
      _CloudSyncPulseAnimationWidgetState();
}

class _CloudSyncPulseAnimationWidgetState
    extends State<CloudSyncPulseAnimationWidget> {
  late List<CloudNode> cloudNodes;
  late List<SyncParticle> syncParticles;
  late List<DataBridge> bridges;
  late QuantumBridge quantumBridge;

  @override
  void initState() {
    super.initState();
    _initializeCloudSystem();
  }

  void _initializeCloudSystem() {
    // Initialize cloud nodes
    cloudNodes = [
      // Main cloud core
      CloudNode(
        position: Offset(40.w, 15.h),
        size: 18.0,
        nodeType: CloudNodeType.core,
        pulseSpeed: 1.0,
        energyLevel: 1.0,
        connections: [1, 2, 3],
      ),
      // Database cluster
      CloudNode(
        position: Offset(20.w, 25.h),
        size: 12.0,
        nodeType: CloudNodeType.database,
        pulseSpeed: 1.2,
        energyLevel: 0.8,
        connections: [0, 4],
      ),
      // Authentication server
      CloudNode(
        position: Offset(60.w, 25.h),
        size: 12.0,
        nodeType: CloudNodeType.auth,
        pulseSpeed: 1.5,
        energyLevel: 0.9,
        connections: [0, 5],
      ),
      // API gateway
      CloudNode(
        position: Offset(40.w, 35.h),
        size: 14.0,
        nodeType: CloudNodeType.api,
        pulseSpeed: 1.3,
        energyLevel: 0.85,
        connections: [0, 6, 7],
      ),
      // Storage nodes
      CloudNode(
        position: Offset(10.w, 35.h),
        size: 10.0,
        nodeType: CloudNodeType.storage,
        pulseSpeed: 0.8,
        energyLevel: 0.7,
        connections: [1],
      ),
      CloudNode(
        position: Offset(70.w, 35.h),
        size: 10.0,
        nodeType: CloudNodeType.storage,
        pulseSpeed: 0.8,
        energyLevel: 0.7,
        connections: [2],
      ),
      // Edge nodes
      CloudNode(
        position: Offset(25.w, 42.h),
        size: 8.0,
        nodeType: CloudNodeType.edge,
        pulseSpeed: 2.0,
        energyLevel: 0.6,
        connections: [3],
      ),
      CloudNode(
        position: Offset(55.w, 42.h),
        size: 8.0,
        nodeType: CloudNodeType.edge,
        pulseSpeed: 2.0,
        energyLevel: 0.6,
        connections: [3],
      ),
    ];

    // Initialize sync particles
    syncParticles = List.generate(20, (index) {
      return SyncParticle(
        position: Offset(
          math.Random().nextDouble() * 80.w,
          math.Random().nextDouble() * 45.h,
        ),
        velocity: Offset(
          (math.Random().nextDouble() - 0.5) * 3,
          (math.Random().nextDouble() - 0.5) * 3,
        ),
        size: math.Random().nextDouble() * 3 + 2,
        syncType:
            SyncType.values[math.Random().nextInt(SyncType.values.length)],
        lifespan: math.Random().nextDouble() * 8 + 4,
        birthTime: math.Random().nextDouble() * 10,
        targetNodeIndex: math.Random().nextInt(cloudNodes.length),
      );
    });

    // Initialize data bridges
    bridges = [];
    for (int i = 0; i < cloudNodes.length; i++) {
      for (final connectionIndex in cloudNodes[i].connections) {
        if (connectionIndex < cloudNodes.length && i < connectionIndex) {
          bridges.add(DataBridge(
            fromIndex: i,
            toIndex: connectionIndex,
            strength: math.Random().nextDouble() * 0.5 + 0.5,
            dataFlow: math.Random().nextDouble(),
            bridgeType: _getBridgeType(
                cloudNodes[i].nodeType, cloudNodes[connectionIndex].nodeType),
          ));
        }
      }
    }

    // Initialize quantum bridge
    quantumBridge = QuantumBridge(
      localEnd: Offset(40.w, 42.h),
      cloudEnd: Offset(40.w, 15.h),
      strength: 1.0,
      quantumEntanglement: 0.8,
      dimensionalPhase: 0.0,
    );
  }

  BridgeType _getBridgeType(CloudNodeType from, CloudNodeType to) {
    if (from == CloudNodeType.core || to == CloudNodeType.core) {
      return BridgeType.quantum;
    } else if (from == CloudNodeType.database || to == CloudNodeType.database) {
      return BridgeType.data;
    } else if (from == CloudNodeType.auth || to == CloudNodeType.auth) {
      return BridgeType.secure;
    } else {
      return BridgeType.standard;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) {
        return CustomPaint(
          painter: CloudSyncPulsePainter(
            animation: widget.controller,
            color: widget.color,
            cloudNodes: cloudNodes,
            syncParticles: syncParticles,
            bridges: bridges,
            quantumBridge: quantumBridge,
            connectionStatus: widget.connectionStatus,
            isConnecting: widget.isConnecting,
          ),
          size: Size(80.w, 45.h),
        );
      },
    );
  }
}

class CloudSyncPulsePainter extends CustomPainter {
  final AnimationController animation;
  final Color color;
  final List<CloudNode> cloudNodes;
  final List<SyncParticle> syncParticles;
  final List<DataBridge> bridges;
  final QuantumBridge quantumBridge;
  final String? connectionStatus;
  final bool isConnecting;

  CloudSyncPulsePainter({
    required this.animation,
    required this.color,
    required this.cloudNodes,
    required this.syncParticles,
    required this.bridges,
    required this.quantumBridge,
    required this.connectionStatus,
    required this.isConnecting,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final animValue = animation.value;

    // Draw quantum bridge
    _drawQuantumBridge(canvas, animValue);

    // Draw data bridges
    _drawDataBridges(canvas, animValue);

    // Draw cloud nodes
    _drawCloudNodes(canvas, animValue);

    // Draw sync particles
    _drawSyncParticles(canvas, size, animValue);

    // Draw connection status
    _drawConnectionStatus(canvas, size, animValue);

    // Draw sync pulses
    _drawSyncPulses(canvas, animValue);

    // Draw dimensional portal effect
    _drawDimensionalPortal(canvas, animValue);
  }

  void _drawQuantumBridge(Canvas canvas, double animValue) {
    final bridgePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    // Calculate quantum entanglement effect
    final entanglement = (math.sin(animValue * 4 * math.pi) + 1) / 2;
    final bridgeStrength = quantumBridge.strength * entanglement;

    // Draw main quantum beam
    bridgePaint.color = color.withValues(alpha: bridgeStrength);
    canvas.drawLine(
        quantumBridge.localEnd, quantumBridge.cloudEnd, bridgePaint);

    // Draw quantum fluctuations
    for (int i = 0; i < 5; i++) {
      final fluctuation = math.sin(animValue * 6 * math.pi + i) * 8;
      final midPoint =
          Offset.lerp(quantumBridge.localEnd, quantumBridge.cloudEnd, 0.5)!;
      final fluctuationPoint = midPoint + Offset(fluctuation, 0);

      bridgePaint.strokeWidth = 1.5;
      bridgePaint.color = color.withValues(alpha: bridgeStrength * 0.6);

      canvas.drawLine(
        Offset.lerp(quantumBridge.localEnd, fluctuationPoint, 0.5)!,
        fluctuationPoint,
        bridgePaint,
      );
      canvas.drawLine(
        fluctuationPoint,
        Offset.lerp(fluctuationPoint, quantumBridge.cloudEnd, 0.5)!,
        bridgePaint,
      );
    }

    // Draw quantum particles along bridge
    for (int i = 0; i < 8; i++) {
      final progress = (animValue * 2 + i * 0.2) % 1.0;
      final particlePos = Offset.lerp(
          quantumBridge.localEnd, quantumBridge.cloudEnd, progress)!;

      final particlePaint = Paint()
        ..style = PaintingStyle.fill
        ..color = color.withValues(alpha: bridgeStrength);

      canvas.drawCircle(particlePos,
          3.0 + math.sin(animValue * 8 * math.pi + i) * 1.5, particlePaint);
    }
  }

  void _drawDataBridges(Canvas canvas, double animValue) {
    final bridgePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (final bridge in bridges) {
      final from = cloudNodes[bridge.fromIndex];
      final to = cloudNodes[bridge.toIndex];

      // Calculate data flow
      final flowPulse =
          (math.sin(animValue * 3 * math.pi + bridge.dataFlow * 2 * math.pi) +
                  1) /
              2;
      final bridgeAlpha = bridge.strength * (0.4 + flowPulse * 0.4);

      bridgePaint.color =
          _getBridgeColor(bridge.bridgeType).withValues(alpha: bridgeAlpha);

      // Draw bridge with flow effect
      final path = Path();
      path.moveTo(from.position.dx, from.position.dy);

      // Add curve for organic flow
      final controlPoint = Offset(
        (from.position.dx + to.position.dx) / 2 +
            math.sin(animValue * 2 * math.pi) * 10,
        (from.position.dy + to.position.dy) / 2 +
            math.cos(animValue * 2 * math.pi) * 10,
      );

      path.quadraticBezierTo(
        controlPoint.dx,
        controlPoint.dy,
        to.position.dx,
        to.position.dy,
      );

      canvas.drawPath(path, bridgePaint);

      // Draw data packets
      for (int i = 0; i < 3; i++) {
        final packetProgress =
            (animValue * 2 + i * 0.3 + bridge.dataFlow) % 1.0;
        final packetPos = _getPointOnPath(path, packetProgress);

        if (packetPos != null) {
          final packetPaint = Paint()
            ..style = PaintingStyle.fill
            ..color = _getBridgeColor(bridge.bridgeType);

          canvas.drawCircle(packetPos, 2.5, packetPaint);
        }
      }
    }
  }

  void _drawCloudNodes(Canvas canvas, double animValue) {
    final nodePaint = Paint()..style = PaintingStyle.fill;

    final nodeGlowPaint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    for (final node in cloudNodes) {
      // Calculate node pulse
      final pulse =
          (math.sin(animValue * node.pulseSpeed * 2 * math.pi) + 1) / 2;
      final nodeSize = node.size * (0.8 + pulse * 0.3);
      final energyPulse = node.energyLevel * (0.7 + pulse * 0.3);

      // Adjust based on connection status
      final statusMultiplier = _getStatusMultiplier();
      final finalEnergy = energyPulse * statusMultiplier;

      // Draw node glow
      nodeGlowPaint.color =
          _getNodeColor(node.nodeType).withValues(alpha: finalEnergy * 0.6);
      canvas.drawCircle(node.position, nodeSize * 1.5, nodeGlowPaint);

      // Draw node based on type
      _drawNodeByType(canvas, node, nodeSize, finalEnergy, pulse);
    }
  }

  void _drawNodeByType(
      Canvas canvas, CloudNode node, double size, double energy, double pulse) {
    final nodePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = _getNodeColor(node.nodeType).withValues(alpha: energy);

    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = _getNodeColor(node.nodeType);

    canvas.save();
    canvas.translate(node.position.dx, node.position.dy);

    switch (node.nodeType) {
      case CloudNodeType.core:
        // Draw core as layered circles
        canvas.drawCircle(Offset.zero, size, nodePaint);
        canvas.drawCircle(Offset.zero, size * 0.7, outlinePaint);
        canvas.drawCircle(Offset.zero, size * 0.4, nodePaint);
        break;

      case CloudNodeType.database:
        // Draw database as stacked cylinders
        _drawDatabase(canvas, Offset.zero, size, nodePaint, outlinePaint);
        break;

      case CloudNodeType.auth:
        // Draw auth as shield
        _drawShield(canvas, Offset.zero, size, nodePaint, outlinePaint);
        break;

      case CloudNodeType.api:
        // Draw API as hexagon
        _drawHexagon(canvas, Offset.zero, size, nodePaint, outlinePaint);
        break;

      case CloudNodeType.storage:
        // Draw storage as cube
        _drawCube(canvas, Offset.zero, size, nodePaint, outlinePaint);
        break;

      case CloudNodeType.edge:
        // Draw edge as diamond
        _drawDiamond(canvas, Offset.zero, size, nodePaint, outlinePaint);
        break;
    }

    canvas.restore();
  }

  void _drawDatabase(Canvas canvas, Offset center, double size, Paint fillPaint,
      Paint outlinePaint) {
    // Draw three stacked ellipses for database representation
    for (int i = 0; i < 3; i++) {
      final yOffset = (i - 1) * (size * 0.3);
      final ellipseRect = Rect.fromCenter(
        center: Offset(center.dx, center.dy + yOffset),
        width: size * 1.5,
        height: size * 0.5,
      );
      canvas.drawOval(ellipseRect, fillPaint);
      canvas.drawOval(ellipseRect, outlinePaint);
    }
  }

  void _drawShield(Canvas canvas, Offset center, double size, Paint fillPaint,
      Paint outlinePaint) {
    final path = Path();
    path.moveTo(center.dx, center.dy - size);
    path.lineTo(center.dx + size * 0.7, center.dy - size * 0.3);
    path.lineTo(center.dx + size * 0.7, center.dy + size * 0.3);
    path.lineTo(center.dx, center.dy + size);
    path.lineTo(center.dx - size * 0.7, center.dy + size * 0.3);
    path.lineTo(center.dx - size * 0.7, center.dy - size * 0.3);
    path.close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, outlinePaint);
  }

  void _drawHexagon(Canvas canvas, Offset center, double size, Paint fillPaint,
      Paint outlinePaint) {
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

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, outlinePaint);
  }

  void _drawCube(Canvas canvas, Offset center, double size, Paint fillPaint,
      Paint outlinePaint) {
    final path = Path();
    // Front face
    path.addRect(
        Rect.fromCenter(center: center, width: size * 1.2, height: size * 1.2));
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, outlinePaint);

    // Top face
    final topPath = Path();
    topPath.moveTo(center.dx - size * 0.6, center.dy - size * 0.6);
    topPath.lineTo(center.dx - size * 0.3, center.dy - size * 0.9);
    topPath.lineTo(center.dx + size * 0.9, center.dy - size * 0.9);
    topPath.lineTo(center.dx + size * 0.6, center.dy - size * 0.6);
    topPath.close();

    canvas.drawPath(topPath, fillPaint);
    canvas.drawPath(topPath, outlinePaint);
  }

  void _drawDiamond(Canvas canvas, Offset center, double size, Paint fillPaint,
      Paint outlinePaint) {
    final path = Path();
    path.moveTo(center.dx, center.dy - size);
    path.lineTo(center.dx + size, center.dy);
    path.lineTo(center.dx, center.dy + size);
    path.lineTo(center.dx - size, center.dy);
    path.close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, outlinePaint);
  }

  void _drawSyncParticles(Canvas canvas, Size size, double animValue) {
    final particlePaint = Paint()..style = PaintingStyle.fill;

    for (final particle in syncParticles) {
      final age = (animValue * 10 - particle.birthTime) % particle.lifespan;
      if (age < 0) continue;

      // Calculate particle position
      final currentPos = particle.position + (particle.velocity * age * 5);
      final wrappedPos = Offset(
        currentPos.dx % size.width,
        currentPos.dy % size.height,
      );

      // Calculate life progress
      final lifeProgress = age / particle.lifespan;
      final visibility = math.sin(lifeProgress * math.pi) * 0.8;

      if (visibility <= 0) continue;

      // Draw particle with sync-specific styling
      particlePaint.color =
          _getSyncColor(particle.syncType).withValues(alpha: visibility);

      final pulseSize =
          particle.size * (1.0 + math.sin(animValue * 6 * math.pi) * 0.2);
      canvas.drawCircle(wrappedPos, pulseSize, particlePaint);

      // Draw sync trail
      for (int i = 1; i <= 3; i++) {
        final trailPos = wrappedPos - (particle.velocity * i.toDouble() * 2.0);
        final trailAlpha = visibility * (1.0 - i * 0.3);
        final trailSize = pulseSize * (1.0 - i * 0.2);

        particlePaint.color =
            _getSyncColor(particle.syncType).withValues(alpha: trailAlpha);
        canvas.drawCircle(trailPos, trailSize, particlePaint);
      }
    }
  }

  void _drawConnectionStatus(Canvas canvas, Size size, double animValue) {
    final statusPaint = Paint()..style = PaintingStyle.fill;

    // Status indicator in top right
    final statusRect = Rect.fromLTWH(size.width - 60, 10, 50, 20);
    final statusColor = _getConnectionStatusColor();

    statusPaint.color = statusColor.withValues(alpha: 0.2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(statusRect, const Radius.circular(10)),
      statusPaint,
    );

    // Status pulse
    final pulse = (math.sin(animValue * 4 * math.pi) + 1) / 2;
    statusPaint.color = statusColor.withValues(alpha: pulse * 0.8);

    canvas.drawCircle(
      Offset(statusRect.left + 10, statusRect.center.dy),
      4.0 + pulse * 2.0,
      statusPaint,
    );
  }

  void _drawSyncPulses(Canvas canvas, double animValue) {
    final pulsePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw sync pulses emanating from core
    final coreNode = cloudNodes[0];
    for (int i = 0; i < 4; i++) {
      final pulseRadius = (animValue * 100 + i * 25) % 120;
      final pulseAlpha = (1.0 - pulseRadius / 120) * 0.6;

      pulsePaint.color = color.withValues(alpha: pulseAlpha);
      canvas.drawCircle(coreNode.position, pulseRadius, pulsePaint);
    }
  }

  void _drawDimensionalPortal(Canvas canvas, double animValue) {
    final portalPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Draw dimensional portal effect around quantum bridge endpoints
    for (final endpoint in [quantumBridge.localEnd, quantumBridge.cloudEnd]) {
      for (int i = 0; i < 6; i++) {
        final angle = (animValue * 2 * math.pi) + (i * math.pi / 3);
        final radius = 20 + math.sin(animValue * 4 * math.pi + i) * 5;

        final portalPos = Offset(
          endpoint.dx + math.cos(angle) * radius,
          endpoint.dy + math.sin(angle) * radius,
        );

        final alpha = (math.sin(animValue * 6 * math.pi + i) + 1) / 2 * 0.4;
        portalPaint.color = color.withValues(alpha: alpha);

        canvas.drawCircle(portalPos, 2.0, portalPaint);
      }
    }
  }

  Offset? _getPointOnPath(Path path, double t) {
    final pathMetrics = path.computeMetrics();
    if (pathMetrics.isEmpty) return null;

    final pathMetric = pathMetrics.first;
    final distance = pathMetric.length * t;
    final tangent = pathMetric.getTangentForOffset(distance);

    return tangent?.position;
  }

  double _getStatusMultiplier() {
    if (isConnecting) return 0.5;

    switch (connectionStatus) {
      case 'connected':
        return 1.0;
      case 'ready_to_connect':
        return 0.8;
      case 'connection_failed':
        return 0.3;
      default:
        return 0.6;
    }
  }

  Color _getConnectionStatusColor() {
    if (isConnecting) return Colors.orange;

    switch (connectionStatus) {
      case 'connected':
        return const Color(0xFF00FF88);
      case 'ready_to_connect':
        return color;
      case 'connection_failed':
        return const Color(0xFFFF6600);
      default:
        return Colors.grey;
    }
  }

  Color _getNodeColor(CloudNodeType type) {
    switch (type) {
      case CloudNodeType.core:
        return color;
      case CloudNodeType.database:
        return const Color(0xFF00F5FF);
      case CloudNodeType.auth:
        return const Color(0xFF00FF88);
      case CloudNodeType.api:
        return const Color(0xFFFF0088);
      case CloudNodeType.storage:
        return const Color(0xFFFFAA00);
      case CloudNodeType.edge:
        return const Color(0xFF8800FF);
    }
  }

  Color _getBridgeColor(BridgeType type) {
    switch (type) {
      case BridgeType.quantum:
        return color;
      case BridgeType.data:
        return const Color(0xFF00F5FF);
      case BridgeType.secure:
        return const Color(0xFF00FF88);
      case BridgeType.standard:
        return const Color(0xFFFFAA00);
    }
  }

  Color _getSyncColor(SyncType type) {
    switch (type) {
      case SyncType.data:
        return const Color(0xFF00F5FF);
      case SyncType.config:
        return const Color(0xFF00FF88);
      case SyncType.neural:
        return const Color(0xFFFF0088);
      case SyncType.quantum:
        return color;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Data models
enum CloudNodeType { core, database, auth, api, storage, edge }

enum BridgeType { quantum, data, secure, standard }

enum SyncType { data, config, neural, quantum }

class CloudNode {
  final Offset position;
  final double size;
  final CloudNodeType nodeType;
  final double pulseSpeed;
  final double energyLevel;
  final List<int> connections;

  CloudNode({
    required this.position,
    required this.size,
    required this.nodeType,
    required this.pulseSpeed,
    required this.energyLevel,
    required this.connections,
  });
}

class SyncParticle {
  final Offset position;
  final Offset velocity;
  final double size;
  final SyncType syncType;
  final double lifespan;
  final double birthTime;
  final int targetNodeIndex;

  SyncParticle({
    required this.position,
    required this.velocity,
    required this.size,
    required this.syncType,
    required this.lifespan,
    required this.birthTime,
    required this.targetNodeIndex,
  });
}

class DataBridge {
  final int fromIndex;
  final int toIndex;
  final double strength;
  final double dataFlow;
  final BridgeType bridgeType;

  DataBridge({
    required this.fromIndex,
    required this.toIndex,
    required this.strength,
    required this.dataFlow,
    required this.bridgeType,
  });
}

class QuantumBridge {
  final Offset localEnd;
  final Offset cloudEnd;
  final double strength;
  final double quantumEntanglement;
  final double dimensionalPhase;

  QuantumBridge({
    required this.localEnd,
    required this.cloudEnd,
    required this.strength,
    required this.quantumEntanglement,
    required this.dimensionalPhase,
  });
}
