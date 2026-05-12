import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

class FerChainScreen extends StatefulWidget {
  const FerChainScreen({super.key});

  @override
  State<FerChainScreen> createState() => _FerChainScreenState();
}

class _FerChainScreenState extends State<FerChainScreen>
    with TickerProviderStateMixin {
  int _selectedTab = 0; // 0: Explorer, 1: Network Stats, 2: Validators
  final List<Block> _blocks = [];
  bool _isLoading = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _loadBlocks();
    _startLiveUpdates();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);
  }

  void _loadBlocks() {
    setState(() {
      _isLoading = true;
    });

    // Simulate loading blocks
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() {
        _blocks.addAll([
          Block(
            height: 1847529,
            hash: '0x8a2f...4c9d',
            timestamp: DateTime.now().subtract(const Duration(seconds: 12)),
            transactions: 42,
            validator: '0x7a3b...9f2e',
            size: '2.4 MB',
            gas_used: '15.2M',
          ),
          Block(
            height: 1847528,
            hash: '0x7b1e...3d8c',
            timestamp: DateTime.now().subtract(const Duration(seconds: 24)),
            transactions: 38,
            validator: '0x9c4d...1e3a',
            size: '1.9 MB',
            gas_used: '13.8M',
          ),
          Block(
            height: 1847527,
            hash: '0x5d3f...7b2a',
            timestamp: DateTime.now().subtract(const Duration(seconds: 36)),
            transactions: 55,
            validator: '0x2e5c...8d1b',
            size: '3.1 MB',
            gas_used: '19.5M',
          ),
          Block(
            height: 1847526,
            hash: '0x3c4e...6a19',
            timestamp: DateTime.now().subtract(const Duration(seconds: 48)),
            transactions: 29,
            validator: '0x1f5b...7c0a',
            size: '1.7 MB',
            gas_used: '11.2M',
          ),
        ]);
        _isLoading = false;
      });
    });
  }

  void _startLiveUpdates() {
    Timer.periodic(const Duration(seconds: 15), (timer) {
      if (!mounted) return;
      _addNewBlock();
    });
  }

  void _addNewBlock() {
    final newBlock = Block(
      height: _blocks.isNotEmpty ? _blocks.first.height + 1 : 1847530,
      hash: _generateHash(),
      timestamp: DateTime.now(),
      transactions: (DateTime.now().millisecond % 50) + 20,
      validator: _generateValidator(),
      size: '${((DateTime.now().millisecond % 200) + 150) / 100} MB',
      gas_used: '${((DateTime.now().millisecond % 100) + 100) / 10}M',
    );

    setState(() {
      _blocks.insert(0, newBlock);
      if (_blocks.length > 20) {
        _blocks.removeLast();
      }
    });
  }

  String _generateHash() {
    final chars = '0123456789abcdef';
    final random = DateTime.now().millisecond;
    var hash = '0x';
    for (int i = 0; i < 8; i++) {
      hash += chars[(random + i * 17) % 16];
    }
    return hash;
  }

  String _generateValidator() {
    final chars = '0123456789abcdef';
    final random = DateTime.now().millisecond;
    var validator = '0x';
    for (int i = 0; i < 6; i++) {
      validator += chars[(random + i * 23) % 16];
    }
    return validator;
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        title: Text(
          '🦦 FERChain',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 6.w, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, size: 5.w, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Search by block height, hash, or address')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats Bar
          _buildStatsBar(),
          // Tab Bar
          _buildTabBar(),
          // Content
          Expanded(
            child: [
              _buildExplorer(),
              _buildNetworkStats(),
              _buildValidators(),
            ][_selectedTab],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBar() {
    return Container(
      margin: EdgeInsets.all(4.w),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF39FF14).withOpacity(0.15),
            const Color(0xFF00E5FF).withOpacity(0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF39FF14), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Block Height', '#${_blocks.isNotEmpty ? _blocks.first.height : "1847529"}', const Color(0xFF39FF14)),
          _buildStatItem('TPS', '2,847', const Color(0xFF00E5FF)),
          _buildStatItem('Validators', '127', const Color(0xFF7B61FF)),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 9.sp,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        SizedBox(height: 0.5.h),
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Text(
                value,
                style: GoogleFonts.firaCode(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        border: Border(
          bottom: BorderSide(color: const Color(0xFF39FF14), width: 1),
        ),
      ),
      child: Row(
        children: [
          _buildTabButton(0, 'Explorer'),
          _buildTabButton(1, 'Network'),
          _buildTabButton(2, 'Validators'),
        ],
      ),
    );
  }

  Widget _buildTabButton(int index, String label) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = index;
          });
        },
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 1.w),
          padding: EdgeInsets.symmetric(vertical: 1.5.h),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF39FF14).withOpacity(0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? const Color(0xFF39FF14) : Colors.transparent,
              width: 2,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? const Color(0xFF39FF14) : Colors.grey[400],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExplorer() {
    return _isLoading
        ? const Center(
            child: CircularProgressIndicator(color: Color(0xFF39FF14)),
          )
        : ListView.builder(
            padding: EdgeInsets.all(4.w),
            itemCount: _blocks.length,
            itemBuilder: (context, index) {
              return _buildBlockCard(_blocks[index], index == 0);
            },
          );
  }

  Widget _buildBlockCard(Block block, bool isNew) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        gradient: isNew
            ? LinearGradient(
                colors: [
                  const Color(0xFF39FF14).withOpacity(0.2),
                  const Color(0xFF00E5FF).withOpacity(0.2),
                ],
              )
            : null,
        color: isNew ? null : const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isNew ? const Color(0xFF39FF14) : Colors.grey[800]!,
          width: isNew ? 2 : 1,
        ),
        boxShadow: isNew
            ? [
                BoxShadow(
                  color: const Color(0xFF39FF14).withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.block,
                    color: const Color(0xFF39FF14),
                    size: 5.w,
                  ),
                  SizedBox(width: 1.5.w),
                  Text(
                    'Block #${block.height}',
                    style: GoogleFonts.firaCode(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              if (isNew)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF39FF14).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFF39FF14), width: 1),
                  ),
                  child: Text(
                    'NEW',
                    style: GoogleFonts.firaCode(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF39FF14),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 1.5.h),
          _buildBlockDetail('Hash', block.hash),
          _buildBlockDetail('Timestamp', _formatTimestamp(block.timestamp)),
          _buildBlockDetail('Transactions', '${block.transactions} txns'),
          _buildBlockDetail('Validator', block.validator),
          SizedBox(height: 1.h),
          Row(
            children: [
              _buildMiniStat('Size', block.size, const Color(0xFF00E5FF)),
              SizedBox(width: 2.w),
              _buildMiniStat('Gas Used', block.gas_used, const Color(0xFF7B61FF)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBlockDetail(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        children: [
          SizedBox(
            width: 25.w,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey[400],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.firaCode(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.firaCode(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 9.sp,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else {
      return '${difference.inHours}h ago';
    }
  }

  Widget _buildNetworkStats() {
    return ListView(
      padding: EdgeInsets.all(4.w),
      children: [
        _buildNetworkStatCard('Network Hash Rate', '847.2 TH/s', '+12.3%', Icons.speed),
        _buildNetworkStatCard('Total Transactions', '847,293,847', '+3.2%', Icons.swap_horiz),
        _buildNetworkStatCard('Circulating Supply', '847,293,847 FER', '+0.01%', Icons.monetization_on),
        _buildNetworkStatCard('Market Cap', '\$209,847,293', '+8.7%', Icons.trending_up),
        SizedBox(height: 3.h),
        _buildSecurityInfo(),
      ],
    );
  }

  Widget _buildNetworkStatCard(String title, String value, String change, IconData icon) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF39FF14), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: const Color(0xFF39FF14).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF39FF14), size: 6.w),
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[400],
                  ),
                ),
                SizedBox(height: 0.5.h),
                Row(
                  children: [
                    Text(
                      value,
                      style: GoogleFonts.firaCode(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 1.5.w),
                    Icon(
                      Icons.arrow_upward,
                      color: const Color(0xFF69F0AE),
                      size: 3.5.w,
                    ),
                    Text(
                      change,
                      style: GoogleFonts.firaCode(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF69F0AE),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityInfo() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF00E5FF).withOpacity(0.1),
            const Color(0xFF39FF14).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF00E5FF), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.security, color: const Color(0xFF00E5FF), size: 6.w),
              SizedBox(width: 2.w),
              Text(
                '🔐 Quantum Security',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF00E5FF),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          _buildSecurityFeature('Lattice-based Encryption', 'Post-quantum secure'),
          _buildSecurityFeature('256-bit Security Level', 'NIST-approved parameters'),
          _buildSecurityFeature('Zero-Knowledge Proofs', 'Privacy-preserving transactions'),
          _buildSecurityFeature('Mesh Network Resilience', 'Decentralized consensus'),
          SizedBox(height: 2.h),
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'FERChain is secured against quantum computing attacks using lattice-based cryptography',
              style: GoogleFonts.inter(
                fontSize: 11.sp,
                color: Colors.grey[300],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityFeature(String title, String description) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: const Color(0xFF39FF14), size: 4.w),
          SizedBox(width: 1.5.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValidators() {
    return ListView(
      padding: EdgeInsets.all(4.w),
      children: [
        _buildValidatorCard('0x7a3b...9f2e', 'North America', 98.7, 15.2),
        _buildValidatorCard('0x9c4d...1e3a', 'Europe', 97.3, 14.8),
        _buildValidatorCard('0x2e5c...8d1b', 'Asia Pacific', 99.1, 16.3),
        _buildValidatorCard('0x1f5b...7c0a', 'South America', 96.5, 13.9),
        SizedBox(height: 3.h),
        Center(
          child: Text(
            '127 Active Validators',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[400],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildValidatorCard(String address, String region, double uptime, double stake) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF39FF14).withOpacity(0.5), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                address,
                style: GoogleFonts.firaCode(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF39FF14).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '$uptime% Uptime',
                  style: GoogleFonts.firaCode(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF39FF14),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.5.h),
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.grey[400], size: 4.w),
              SizedBox(width: 1.w),
              Text(
                region,
                style: GoogleFonts.inter(
                  fontSize: 11.sp,
                  color: Colors.grey[400],
                ),
              ),
              const Spacer(),
              Text(
                '$stake FER',
                style: GoogleFonts.firaCode(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF39FF14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class Block {
  final int height;
  final String hash;
  final DateTime timestamp;
  final int transactions;
  final String validator;
  final String size;
  final String gas_used;

  Block({
    required this.height,
    required this.hash,
    required this.timestamp,
    required this.transactions,
    required this.validator,
    required this.size,
    required this.gas_used,
  });
}