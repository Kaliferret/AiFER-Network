import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class MeshNetworkingScreen extends StatefulWidget {
  const MeshNetworkingScreen({super.key});

  @override
  State<MeshNetworkingScreen> createState() => _MeshNetworkingScreenState();
}

class _MeshNetworkingScreenState extends State<MeshNetworkingScreen>
    with SingleTickerProviderStateMixin {
  bool _isConnected = false;
  int _connectedPeers = 0;
  double _networkStrength = 0.0;
  List<MeshNode> _nearbyNodes = [];
  String _connectionStatus = 'Scanning...';
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat();
    _startScanning();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _startScanning() {
    setState(() {
      _connectionStatus = 'Scanning for nearby nodes...';
      _nearbyNodes.clear();
    });

    // Simulate discovering nodes
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _connectionStatus = 'Nodes discovered';
        _nearbyNodes = _generateRandomNodes();
      });
    });
  }

  void _connectToMesh() {
    setState(() {
      _connectionStatus = 'Establishing secure connection...';
    });

    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _isConnected = true;
        _connectionStatus = 'Connected to Mesh Network';
        _connectedPeers = _nearbyNodes.length;
        _networkStrength = 0.85 + (Random().nextDouble() * 0.14);
      });
    });
  }

  void _disconnectFromMesh() {
    setState(() {
      _isConnected = false;
      _connectionStatus = 'Disconnected - Scan again to reconnect';
      _connectedPeers = 0;
      _networkStrength = 0.0;
    });
  }

  List<MeshNode> _generateRandomNodes() {
    final random = Random();
    final names = [
      'Ferret_Alpha', 'Ferret_Beta', 'Ferret_Gamma', 'Ferret_Delta',
      'Ferret_Epsilon', 'Ferret_Zeta', 'Ferret_Eta', 'Ferret_Theta',
    ];
    
    return List.generate(5, (index) {
      final seed = random.nextDouble();
      return MeshNode(
        id: 'node_${index + 1}',
        name: names[index],
        distance: (random.nextDouble() * 50 + 10).toInt(),
        signalStrength: (random.nextDouble() * 100).toInt(),
        latency: (random.nextDouble() * 50 + 5).toInt(),
        isOnline: random.nextDouble() > 0.2,
        nodeType: _getNodeType(random.nextDouble()),
      );
    });
  }

  NodeType _getNodeType(double value) {
    if (value < 0.33) return NodeType.relay;
    if (value < 0.66) return NodeType.storage;
    return NodeType.validator;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF39FF14)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(
              'Mesh Networking',
              style: GoogleFonts.inter(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF39FF14),
              ),
            ),
            Text(
              'WebRTC P2P Protocol',
              style: GoogleFonts.inter(
                fontSize: 10.sp,
                color: const Color(0xFF9E9E9E),
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Color(0xFF9E9E9E)),
            onPressed: () => _showSettingsDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatusCard(),
          Expanded(
            child: TabBarView(
              children: [
                _buildNetworkTab(),
                _buildPeersTab(),
                _buildStatisticsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      margin: EdgeInsets.all(4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _isConnected
              ? [
                  const Color(0xFF39FF14).withOpacity(0.2),
                  const Color(0xFF1E1E1E),
                ]
              : [
                  const Color(0xFF1E1E1E),
                  const Color(0xFF2A2A2A),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isConnected
              ? const Color(0xFF39FF14)
              : const Color(0xFF39FF14).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + (_pulseAnimation.value * 0.2),
                    child: Container(
                      width: 8.w,
                      height: 8.w,
                      decoration: BoxDecoration(
                        color: _isConnected
                            ? const Color(0xFF39FF14)
                            : const Color(0xFFFFD740),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (_isConnected
                                    ? const Color(0xFF39FF14)
                                    : const Color(0xFFFFD740))
                                .withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        _isConnected ? Icons.hub : Icons.wifi_find,
                        color: Colors.black,
                        size: 4.w,
                      ),
                    ),
                  );
                },
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _connectionStatus,
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: _isConnected
                            ? const Color(0xFF39FF14)
                            : const Color(0xFFFFD740),
                      ),
                    ),
                    Text(
                      'WebRTC Secure P2P Connection',
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        color: const Color(0xFF9E9E9E),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Peers', _connectedPeers.toString(), Icons.people),
              _buildStatItem(
                  'Strength', '${(_networkStrength * 100).toInt()}%', Icons.signal_cellular_alt),
              _buildStatItem('Protocol', 'WebRTC', Icons.link),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isConnected ? _disconnectFromMesh : _connectToMesh,
                  icon: Icon(_isConnected ? Icons.power_off : Icons.power_settings_new),
                  label: Text(_isConnected ? 'Disconnect' : 'Connect'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isConnected
                        ? const Color(0xFFFF5252)
                        : const Color(0xFF39FF14),
                    foregroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 4.w, color: const Color(0xFF39FF14)),
        SizedBox(height: 0.5.h),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10.sp,
            color: const Color(0xFF9E9E9E),
          ),
        ),
      ],
    );
  }

  Widget _buildNetworkTab() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 2.h),
            child: Text(
              'Network Overview',
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          _buildNetworkMetric(
            'Encryption',
            'Quantum-Resistant',
            Icons.lock,
            const Color(0xFF39FF14),
            'Lattice-based 256-bit',
          ),
          _buildNetworkMetric(
            'Protocol',
            'WebRTC',
            Icons.swap_horiz,
            const Color(0xFF00E5FF),
            'Direct P2P with STUN/TURN',
          ),
          _buildNetworkMetric(
            'Bandwidth',
            '${_isConnected ? '50-200' : '0'} Mbps',
            Icons.speed,
            const Color(0xFF7B61FF),
            'Dynamic mesh routing',
          ),
          _buildNetworkMetric(
            'Latency',
            _isConnected ? '5-15ms' : 'N/A',
            Icons.timer,
            const Color(0xFFFFD740),
            'Ultra-low priority queuing',
          ),
          SizedBox(height: 2.h),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 1.h),
            child: Text(
              'Network Topology',
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          _buildTopologyVisualization(),
        ],
      ),
    );
  }

  Widget _buildNetworkMetric(
    String label,
    String value,
    IconData icon,
    Color color,
    String description,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 10.w,
            height: 10.w,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 5.w),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: const Color(0xFF9E9E9E),
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    color: const Color(0xFF6B6B6B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopologyVisualization() {
    return Container(
      height: 30.h,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF39FF14).withOpacity(0.3)),
      ),
      child: CustomPaint(
        painter: MeshTopologyPainter(
          isConnected: _isConnected,
          nodeCount: _connectedPeers,
        ),
      ),
    );
  }

  Widget _buildPeersTab() {
    if (_nearbyNodes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_find,
              size: 20.w,
              color: const Color(0xFF9E9E9E),
            ),
            SizedBox(height: 2.h),
            Text(
              'No nodes found',
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 1.h),
            ElevatedButton(
              onPressed: _startScanning,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF39FF14),
                foregroundColor: Colors.black,
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              ),
              child: Text(
                'Scan Nearby',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      itemCount: _nearbyNodes.length,
      itemBuilder: (context, index) {
        return _buildPeerCard(_nearbyNodes[index]);
      },
    );
  }

  Widget _buildPeerCard(MeshNode node) {
    Color typeColor;
    String typeLabel;
    switch (node.nodeType) {
      case NodeType.relay:
        typeColor = const Color(0xFF00E5FF);
        typeLabel = 'RELAY';
        break;
      case NodeType.storage:
        typeColor = const Color(0xFF7B61FF);
        typeLabel = 'STORAGE';
        break;
      case NodeType.validator:
        typeColor = const Color(0xFF39FF14);
        typeLabel = 'VALIDATOR';
        break;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 1.5.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: node.isOnline
              ? const Color(0xFF39FF14).withOpacity(0.5)
              : const Color(0xFFFF5252).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: node.isOnline ? typeColor : const Color(0xFF6B6B6B),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              node.nodeType == NodeType.relay
                  ? Icons.swap_horiz
                  : node.nodeType == NodeType.storage
                      ? Icons.storage
                      : Icons.verified,
              color: Colors.black,
              size: 6.w,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      node.name,
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 1.w),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.3.h),
                      decoration: BoxDecoration(
                        color: typeColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: typeColor, width: 1),
                      ),
                      child: Text(
                        typeLabel,
                        style: GoogleFonts.inter(
                          fontSize: 8.sp,
                          fontWeight: FontWeight.bold,
                          color: typeColor,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  'ID: ${node.id}',
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    color: const Color(0xFF9E9E9E),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Icon(Icons.signal_cellular_alt, size: 10.sp, color: const Color(0xFF39FF14)),
                  SizedBox(width: 0.5.w),
                  Text(
                    '${node.signalStrength}%',
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.network_ping, size: 10.sp, color: const Color(0xFF00E5FF)),
                  SizedBox(width: 0.5.w),
                  Text(
                    '${node.latency}ms',
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.location_on, size: 10.sp, color: const Color(0xFF7B61FF)),
                  SizedBox(width: 0.5.w),
                  Text(
                    '${node.distance}m',
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsTab() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 2.h),
            child: Text(
              'Network Statistics',
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          _buildStatisticsCard(
            'Total Data Transferred',
            '12.4 GB',
            Icons.data_usage,
            const Color(0xFF39FF14),
            'Last 24 hours',
          ),
          _buildStatisticsCard(
            'Active Connections',
            _isConnected ? 'Active' : 'Inactive',
            Icons.link,
            const Color(0xFF00E5FF),
            'WebRTC P2P Tunnel',
          ),
          _buildStatisticsCard(
            'Packet Loss',
            '0.02%',
            Icons.network_check,
            const Color(0xFF69F0AE),
            'Excellent connection quality',
          ),
          _buildStatisticsCard(
            'Uptime',
            _isConnected ? '2h 34m' : '0m',
            Icons.access_time,
            const Color(0xFFFFD740),
            'Current session duration',
          ),
          SizedBox(height: 2.h),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 1.h),
            child: Text(
              'Security',
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF39FF14).withOpacity(0.1),
                  const Color(0xFF1E1E1E),
                ],
              ),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color(0xFF39FF14)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.security, color: const Color(0xFF39FF14), size: 5.w),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        'End-to-End Encryption',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF39FF14),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
                Text(
                  'All mesh communications are encrypted using quantum-resistant lattice-based cryptography with 256-bit security level. Zero-knowledge proofs verify node identity without exposing private data.',
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    color: const Color(0xFFBDBDBD),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCard(
    String label,
    String value,
    IconData icon,
    Color color,
    String description,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 10.w,
            height: 10.w,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 5.w),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    color: const Color(0xFF9E9E9E),
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    color: const Color(0xFF6B6B6B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(
          'Mesh Network Settings',
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSettingItem('Auto-connect', true),
            _buildSettingItem('Low bandwidth mode', false),
            _buildSettingItem('Debug mode', false),
            _buildSettingItem('Background sync', true),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Color(0xFF9E9E9E))),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(String label, bool value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: Colors.white,
            ),
          ),
          Switch(
            value: value,
            onChanged: (val) {},
            activeColor: const Color(0xFF39FF14),
          ),
        ],
      ),
    );
  }
}

enum NodeType { relay, storage, validator }

class MeshNode {
  final String id;
  final String name;
  final int distance;
  final int signalStrength;
  final int latency;
  final bool isOnline;
  final NodeType nodeType;

  MeshNode({
    required this.id,
    required this.name,
    required this.distance,
    required this.signalStrength,
    required this.latency,
    required this.isOnline,
    required this.nodeType,
  });
}

class MeshTopologyPainter extends CustomPainter {
  final bool isConnected;
  final int nodeCount;

  MeshTopologyPainter({required this.isConnected, required this.nodeCount});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    if (!isConnected || nodeCount == 0) {
      // Draw disconnected state
      final paint = Paint()
        ..color = const Color(0xFF6B6B6B)
        ..strokeWidth = 2;
      canvas.drawCircle(center, 30, paint);
      final textPainter = TextPainter(
        text: const TextSpan(
          text: 'No Connection',
          style: TextStyle(color: Color(0xFF6B6B6B), fontSize: 14),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
          canvas, Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height / 2));
      return;
    }

    // Draw mesh network topology
    final nodes = <Offset>[];
    final radius = min(size.width, size.height) * 0.35;

    // Generate node positions in circular topology
    for (int i = 0; i < nodeCount; i++) {
      final angle = (i / nodeCount) * 2 * pi - pi / 2;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);
      nodes.add(Offset(x, y));
    }

    // Draw connections
    final linePaint = Paint()
      ..color = const Color(0xFF39FF14).withOpacity(0.3)
      ..strokeWidth = 2;

    for (int i = 0; i < nodes.length; i++) {
      for (int j = i + 1; j < nodes.length; j++) {
        // Connect nearby nodes
        final distance = (nodes[i] - nodes[j]).distance;
        if (distance < radius * 1.5) {
          canvas.drawLine(nodes[i], nodes[j], linePaint);
        }
      }
      // Connect to center
      canvas.drawLine(nodes[i], center, linePaint);
    }

    // Draw center node
    final centerPaint = Paint()
      ..color = const Color(0xFF39FF14)
      ..style = PaintingStyle.fill;
    final centerStroke = Paint()
      ..color = const Color(0xFF39FF14)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, 20, centerPaint);
    canvas.drawCircle(center, 20, centerStroke);

    // Draw mesh nodes
    final nodePaint = Paint()
      ..color = const Color(0xFF00E5FF)
      ..style = PaintingStyle.fill;
    final nodeStroke = Paint()
      ..color = const Color(0xFF00E5FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (int i = 0; i < nodes.length; i++) {
      canvas.drawCircle(nodes[i], 12, nodePaint);
      canvas.drawCircle(nodes[i], 12, nodeStroke);
    }
  }

  @override
  bool shouldRepaint(MeshTopologyPainter oldDelegate) {
    return isConnected != oldDelegate.isConnected || nodeCount != oldDelegate.nodeCount;
  }
}