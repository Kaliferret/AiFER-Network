import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

class FerTradeScreen extends StatefulWidget {
  const FerTradeScreen({super.key});

  @override
  State<FerTradeScreen> createState() => _FerTradeScreenState();
}

class _FerTradeScreenState extends State<FerTradeScreen>
    with TickerProviderStateMixin {
  int _selectedTab = 0; // 0: Dashboard, 1: Trade, 2: Portfolio
  double _ferPrice = 247.53;
  double _priceChange = 5.23;
  bool _isPriceIncreasing = true;

  late AnimationController _chartController;
  late Animation<double> _chartAnimation;

  @override
  void initState() {
    super.initState();
    _startPriceUpdates();

    _chartController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _chartAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _chartController, curve: Curves.easeOut),
    );
  }

  void _startPriceUpdates() {
    Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) return;
      setState(() {
        final change = (DateTime.now().millisecond % 200 - 100) / 10;
        _ferPrice += change;
        _priceChange = change;
        _isPriceIncreasing = change >= 0;
      });
    });
  }

  @override
  void dispose() {
    _chartController.dispose();
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
          '🦦 FERTrade',
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
            icon: Icon(Icons.notifications, size: 5.w, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications coming soon')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab Bar
          _buildTabBar(),
          // Content
          Expanded(
            child: [
              _buildDashboard(),
              _buildTrade(),
              _buildPortfolio(),
            ][_selectedTab],
          ),
        ],
      ),
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
          _buildTabButton(0, 'Dashboard'),
          _buildTabButton(1, 'Trade'),
          _buildTabButton(2, 'Portfolio'),
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

  Widget _buildDashboard() {
    return ListView(
      padding: EdgeInsets.all(4.w),
      children: [
        // FER Price Card
        _buildPriceCard(),
        SizedBox(height: 3.h),
        // Market Overview
        _buildMarketOverview(),
        SizedBox(height: 3.h),
        // AI Predictions
        _buildAiPredictions(),
        SizedBox(height: 3.h),
        // Recent Transactions
        _buildRecentTransactions(),
      ],
    );
  }

  Widget _buildPriceCard() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF39FF14).withOpacity(0.15),
            const Color(0xFF00E5FF).withOpacity(0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF39FF14), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF39FF14).withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'FER Token',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[400],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: _isPriceIncreasing
                      ? const Color(0xFF69F0AE).withOpacity(0.2)
                      : const Color(0xFFFF5252).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _isPriceIncreasing
                        ? const Color(0xFF69F0AE)
                        : const Color(0xFFFF5252),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isPriceIncreasing ? Icons.arrow_upward : Icons.arrow_downward,
                      color: _isPriceIncreasing ? const Color(0xFF69F0AE) : const Color(0xFFFF5252),
                      size: 3.w,
                    ),
                    SizedBox(width: 0.5.w),
                    Text(
                      '${_priceChange.abs().toStringAsFixed(2)}%',
                      style: GoogleFonts.firaCode(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w700,
                        color: _isPriceIncreasing ? const Color(0xFF69F0AE) : const Color(0xFFFF5252),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            '\$${_ferPrice.toStringAsFixed(2)}',
            style: GoogleFonts.poppins(
              fontSize: 32.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 1.h),
          _buildMiniChart(),
        ],
      ),
    );
  }

  Widget _buildMiniChart() {
    return Container(
      height: 10.h,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: CustomPaint(
        painter: _ChartPainter(
          isIncreasing: _isPriceIncreasing,
          animation: _chartAnimation,
        ),
      ),
    );
  }

  Widget _buildMarketOverview() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF39FF14), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Market Overview',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 2.h),
          _buildMarketItem('BTC/USD', '67,432.18', '+2.34%', true),
          _buildMarketItem('ETH/USD', '3,521.47', '+1.87%', true),
          _buildMarketItem('SOL/USD', '142.89', '-0.56%', false),
          _buildMarketItem('FER/USD', '\$${_ferPrice.toStringAsFixed(2)}', '${_priceChange > 0 ? '+' : ''}${_priceChange.toStringAsFixed(2)}%', _priceChange > 0),
        ],
      ),
    );
  }

  Widget _buildMarketItem(String pair, String price, String change, bool isPositive) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            pair,
            style: GoogleFonts.firaCode(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          Row(
            children: [
              Text(
                '\$$price',
                style: GoogleFonts.firaCode(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[300],
                ),
              ),
              SizedBox(width: 2.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.3.h),
                decoration: BoxDecoration(
                  color: isPositive
                      ? const Color(0xFF69F0AE).withOpacity(0.2)
                      : const Color(0xFFFF5252).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  change,
                  style: GoogleFonts.firaCode(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    color: isPositive ? const Color(0xFF69F0AE) : const Color(0xFFFF5252),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAiPredictions() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF00E5FF).withOpacity(0.1),
            const Color(0xFF7B61FF).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF00E5FF), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: const Color(0xFF00E5FF), size: 5.w),
              SizedBox(width: 1.w),
              Text(
                '🤖 FER AI Predictions',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF00E5FF),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          _buildPredictionItem('BTC', 'Bullish trend expected', 87),
          _buildPredictionItem('ETH', 'Consolidation phase', 65),
          _buildPredictionItem('FER', 'Strong buy signal', 92),
          SizedBox(height: 1.h),
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'AI Confidence: 89% based on quantum sentiment analysis and on-chain metrics',
              style: GoogleFonts.inter(
                fontSize: 10.sp,
                color: Colors.grey[400],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionItem(String asset, String prediction, int confidence) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        children: [
          Text(
            asset,
            style: GoogleFonts.firaCode(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              prediction,
              style: GoogleFonts.inter(
                fontSize: 11.sp,
                color: Colors.grey[300],
              ),
            ),
          ),
          Container(
            width: 15.w,
            height: 0.8.h,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: confidence / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: confidence > 80
                      ? const Color(0xFF39FF14)
                      : confidence > 60
                          ? const Color(0xFFFFD740)
                          : const Color(0xFFFF5252),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          SizedBox(width: 1.w),
          Text(
            '$confidence%',
            style: GoogleFonts.firaCode(
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              color: confidence > 80
                  ? const Color(0xFF39FF14)
                  : confidence > 60
                      ? const Color(0xFFFFD740)
                      : const Color(0xFFFF5252),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF39FF14), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Transactions',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 2.h),
          _buildTransactionItem('BUY', 'FER', '500 FER', '\$123,765.00', '+1.45%'),
          _buildTransactionItem('SELL', 'BTC', '0.05 BTC', '\$3,371.61', '+2.34%'),
          _buildTransactionItem('BUY', 'ETH', '0.5 ETH', '\$1,760.74', '-0.23%'),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(String type, String asset, String amount, String value, String change) {
    final isBuy = type == 'BUY';
    return Container(
      padding: EdgeInsets.symmetric(vertical: 1.5.h),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[800]!, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 10.w,
            height: 10.w,
            decoration: BoxDecoration(
              color: isBuy
                  ? const Color(0xFF69F0AE).withOpacity(0.2)
                  : const Color(0xFFFF5252).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(
                isBuy ? Icons.arrow_upward : Icons.arrow_downward,
                color: isBuy ? const Color(0xFF69F0AE) : const Color(0xFFFF5252),
                size: 5.w,
              ),
            ),
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$type $asset',
                  style: GoogleFonts.firaCode(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  amount,
                  style: GoogleFonts.firaCode(
                    fontSize: 10.sp,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: GoogleFonts.firaCode(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text(
                change,
                style: GoogleFonts.firaCode(
                  fontSize: 10.sp,
                  color: change.startsWith('+')
                      ? const Color(0xFF69F0AE)
                      : const Color(0xFFFF5252),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrade() {
    return Center(
      child: Container(
        padding: EdgeInsets.all(4.w),
        margin: EdgeInsets.all(5.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF39FF14).withOpacity(0.1),
              const Color(0xFF00E5FF).withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF39FF14), width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.send, size: 15.w, color: const Color(0xFF39FF14)),
            SizedBox(height: 3.h),
            Text(
              'Advanced Trading',
              style: GoogleFonts.inter(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF39FF14),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Full order book, limit orders, stop-loss,\nmargin trading, and futures contracts\ncoming in Phase 7',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                color: Colors.grey[300],
                height: 1.5,
              ),
            ),
            SizedBox(height: 3.h),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Advanced trading features coming soon!'),
                    backgroundColor: Color(0xFF39FF14),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF39FF14),
                foregroundColor: Colors.black,
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                'Stay Tuned',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPortfolio() {
    return ListView(
      padding: EdgeInsets.all(4.w),
      children: [
        _buildPortfolioSummary(),
        SizedBox(height: 3.h),
        _buildPortfolioHoldings(),
      ],
    );
  }

  Widget _buildPortfolioSummary() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF7B61FF).withOpacity(0.2),
            const Color(0xFF00E5FF).withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF7B61FF), width: 2),
      ),
      child: Column(
        children: [
          Text(
            'Total Portfolio Value',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[400],
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            '\$187,453.21',
            style: GoogleFonts.poppins(
              fontSize: 28.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 1.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.trending_up, color: const Color(0xFF69F0AE), size: 4.w),
              SizedBox(width: 1.w),
              Text(
                '+\$12,847.32 (+7.36%)',
                style: GoogleFonts.firaCode(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF69F0AE),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioHoldings() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF39FF14), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Holdings',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 2.h),
          _buildHoldingItem('FER', '12,500 FER', '\$3,094,125.00', '+1.45%', const Color(0xFF39FF14)),
          _buildHoldingItem('BTC', '0.25 BTC', '\$16,858.05', '+2.34%', const Color(0xFFF7931A)),
          _buildHoldingItem('ETH', '2.5 ETH', '\$8,803.68', '-0.23%', const Color(0xFF627EEA)),
          _buildHoldingItem('SOL', '100 SOL', '\$14,289.00', '+5.67%', const Color(0xFF00FFBD)),
        ],
      ),
    );
  }

  Widget _buildHoldingItem(String asset, String amount, String value, String change, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.5.h),
      child: Row(
        children: [
          Container(
            width: 10.w,
            height: 10.w,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                asset.substring(0, 1),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ),
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  asset,
                  style: GoogleFonts.firaCode(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  amount,
                  style: GoogleFonts.firaCode(
                    fontSize: 10.sp,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: GoogleFonts.firaCode(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text(
                change,
                style: GoogleFonts.firaCode(
                  fontSize: 10.sp,
                  color: change.startsWith('+')
                      ? const Color(0xFF69F0AE)
                      : const Color(0xFFFF5252),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final bool isIncreasing;
  final Animation<double> animation;

  _ChartPainter({required this.isIncreasing, required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final points = <Offset>[
      Offset(0, size.height * 0.7),
      Offset(size.width * 0.2, size.height * 0.6),
      Offset(size.width * 0.4, size.height * 0.75),
      Offset(size.width * 0.6, size.height * 0.5),
      Offset(size.width * 0.8, size.height * 0.6),
      Offset(size.width, size.height * 0.4),
    ];

    final paint = Paint()
      ..color = isIncreasing ? const Color(0xFF69F0AE) : const Color(0xFFFF5252)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);

    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    canvas.drawPath(path, paint);

    // Draw gradient fill
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          (isIncreasing ? const Color(0xFF69F0AE) : const Color(0xFFFF5252)).withOpacity(0.3),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    final fillPath = Path()
      ..moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      fillPath.lineTo(points[i].dx, points[i].dy);
    }
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();
    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}