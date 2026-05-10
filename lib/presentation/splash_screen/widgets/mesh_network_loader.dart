import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Animated mesh network loading indicator showing connection progress
class MeshNetworkLoader extends StatefulWidget {
  final double progress;
  final String statusText;
  final VoidCallback? onComplete;

  const MeshNetworkLoader({
    super.key,
    this.progress = 0.0,
    this.statusText = 'Initializing FERMesh...',
    this.onComplete,
  });

  @override
  State<MeshNetworkLoader> createState() => _MeshNetworkLoaderState();
}

class _MeshNetworkLoaderState extends State<MeshNetworkLoader>
    with TickerProviderStateMixin {
  late AnimationController _nodeController;
  late AnimationController _connectionController;
  late AnimationController _progressController;

  late Animation<double> _nodeAnimation;
  late Animation<double> _connectionAnimation;
  late Animation<double> _progressAnimation;

  final List<NetworkNode> _nodes = [];
  final List<NetworkConnection> _connections = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _generateNetworkNodes();
    _startAnimations();
  }

  void _initializeAnimations() {
    _nodeController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    _nodeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _nodeController,
      curve: Curves.easeInOut,
    ));

    _connectionController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _connectionAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _connectionController,
      curve: Curves.easeInOut,
    ));

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
  }

  void _generateNetworkNodes() {
    final random = math.Random();

    // Generate 8 network nodes in circular pattern
    for (int i = 0; i < 8; i++) {
      final angle = (i * 45) * (math.pi / 180);
      final radius = 80.0;

      _nodes.add(NetworkNode(
        id: i,
        x: radius * math.cos(angle),
        y: radius * math.sin(angle),
        isActive: i < 3, // First 3 nodes start active
        delay: i * 200.0,
      ));
    }

    // Generate connections between nodes
    for (int i = 0; i < _nodes.length; i++) {
      for (int j = i + 1; j < _nodes.length; j++) {
        if (random.nextDouble() > 0.6) {
          // 40% chance of connection
          _connections.add(NetworkConnection(
            from: _nodes[i],
            to: _nodes[j],
            strength: random.nextDouble(),
            delay: (i + j) * 150.0,
          ));
        }
      }
    }
  }

  void _startAnimations() async {
    _nodeController.forward();

    await Future.delayed(const Duration(milliseconds: 500));
    _connectionController.forward();

    await Future.delayed(const Duration(milliseconds: 1000));
    _progressController.forward();

    // Complete after animations
    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });
  }

  @override
  void dispose() {
    _nodeController.dispose();
    _connectionController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Network visualization
        Container(
          width: 200,
          height: 200,
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _nodeAnimation,
              _connectionAnimation,
            ]),
            builder: (context, child) {
              return CustomPaint(
                painter: MeshNetworkPainter(
                  nodes: _nodes,
                  connections: _connections,
                  nodeProgress: _nodeAnimation.value,
                  connectionProgress: _connectionAnimation.value,
                  accentColor: AppTheme.accentColor,
                  isDark: isDark,
                ),
                size: const Size(200, 200),
              );
            },
          ),
        ),

        SizedBox(height: 4.h),

        // Progress indicator
        Container(
          width: 60.w,
          height: 4,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: isDark
                ? AppTheme.dividerDark.withValues(alpha: 0.3)
                : AppTheme.dividerLight.withValues(alpha: 0.3),
          ),
          child: AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _progressAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.accentColor,
                        AppTheme.successColor,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accentColor.withValues(alpha: 0.4),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        SizedBox(height: 2.h),

        // Status text
        AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            String currentStatus = widget.statusText;
            if (_progressAnimation.value > 0.3) {
              currentStatus = 'Scanning for mesh nodes...';
            }
            if (_progressAnimation.value > 0.6) {
              currentStatus = 'Establishing connections...';
            }
            if (_progressAnimation.value > 0.9) {
              currentStatus = 'FERMesh ready!';
            }

            return Text(
              currentStatus,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppTheme.textSecondaryDark
                    : AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            );
          },
        ),
      ],
    );
  }
}

/// Custom painter for mesh network visualization
class MeshNetworkPainter extends CustomPainter {
  final List<NetworkNode> nodes;
  final List<NetworkConnection> connections;
  final double nodeProgress;
  final double connectionProgress;
  final Color accentColor;
  final bool isDark;

  MeshNetworkPainter({
    required this.nodes,
    required this.connections,
    required this.nodeProgress,
    required this.connectionProgress,
    required this.accentColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Draw connections
    final connectionPaint = Paint()
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (final connection in connections) {
      final progress = math.max(0.0,
          math.min(1.0, (connectionProgress * 2) - (connection.delay / 2000)));

      if (progress > 0) {
        connectionPaint.color = accentColor.withValues(
          alpha: progress * connection.strength * 0.6,
        );

        final start = center + Offset(connection.from.x, connection.from.y);
        final end = center + Offset(connection.to.x, connection.to.y);

        canvas.drawLine(start, end, connectionPaint);
      }
    }

    // Draw nodes
    final nodePaint = Paint()..style = PaintingStyle.fill;
    final nodeOutlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (final node in nodes) {
      final progress = math.max(
          0.0, math.min(1.0, (nodeProgress * 2) - (node.delay / 3000)));

      if (progress > 0) {
        final nodeCenter = center + Offset(node.x, node.y);
        final radius = 6.0 * progress;

        // Node fill
        nodePaint.color = node.isActive
            ? accentColor.withValues(alpha: progress)
            : (isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary)
                .withValues(alpha: progress * 0.6);

        canvas.drawCircle(nodeCenter, radius, nodePaint);

        // Node outline
        nodeOutlinePaint.color = accentColor.withValues(alpha: progress * 0.8);
        canvas.drawCircle(nodeCenter, radius, nodeOutlinePaint);

        // Active node glow
        if (node.isActive && progress > 0.8) {
          final glowPaint = Paint()
            ..color = accentColor.withValues(alpha: 0.3)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

          canvas.drawCircle(nodeCenter, radius * 1.5, glowPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Data class for network nodes
class NetworkNode {
  final int id;
  final double x;
  final double y;
  final bool isActive;
  final double delay;

  NetworkNode({
    required this.id,
    required this.x,
    required this.y,
    required this.isActive,
    required this.delay,
  });
}

/// Data class for network connections
class NetworkConnection {
  final NetworkNode from;
  final NetworkNode to;
  final double strength;
  final double delay;

  NetworkConnection({
    required this.from,
    required this.to,
    required this.strength,
    required this.delay,
  });
}
