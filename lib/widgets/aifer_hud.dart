import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

/// AiFERHUD - Heads-Up Display overlay for system status
/// This is a placeholder widget for future implementation
class AiFERHUD extends StatefulWidget {
  final bool isVisible;
  final VoidCallback? onTap;

  const AiFERHUD({
    Key? key,
    this.isVisible = false,
    this.onTap,
  }) : super(key: key);

  @override
  State<AiFERHUD> createState() => _AiFERHUDState();
}

class _AiFERHUDState extends State<AiFERHUD>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;

  Timer? _statusUpdateTimer;

  // Mock status data
  int _batteryLevel = 85;
  int _networkStrength = 92;
  int _meshNodes = 42;
  String _securityStatus = 'Quantum Secure';

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));

    if (widget.isVisible) {
      _startAnimations();
      _startStatusUpdates();
    }
  }

  @override
  void didUpdateWidget(AiFERHUD oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _slideController.forward();
        _startAnimations();
        _startStatusUpdates();
      } else {
        _slideController.reverse();
        _stopAnimations();
        _stopStatusUpdates();
      }
    }
  }

  void _startAnimations() {
    _pulseController.repeat(reverse: true);
  }

  void _stopAnimations() {
    _pulseController.stop();
  }

  void _startStatusUpdates() {
    // Simulate periodic status updates
    _statusUpdateTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          _batteryLevel = (_batteryLevel + (Random().nextInt(3) - 1))
              .clamp(0, 100);
          _networkStrength = (_networkStrength + (Random().nextInt(5) - 2))
              .clamp(0, 100);
          _meshNodes = (_meshNodes + (Random().nextInt(3) - 1)).clamp(0, 100);
        });
      }
    });
  }

  void _stopStatusUpdates() {
    _statusUpdateTimer?.cancel();
  }

  void _handleTap() {
    widget.onTap?.call();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    _statusUpdateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SafeArea(
      child: SlideTransition(
        position: _slideAnimation,
        child: GestureDetector(
          onTap: _handleTap,
          child: Container(
            margin: EdgeInsets.all(2.w),
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: (isDark ? Color(0xFF1A1A1A) : Colors.white)
                  .withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(3.w),
              border: Border.all(
                color: Color(0xFF39FF14).withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 15,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with AiFER branding
                Row(
                  children: [
                    Text(
                      '🦦',
                      style: TextStyle(fontSize: 5.w),
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'AiFER HUD',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF39FF14),
                      ),
                    ),
                    Expanded(child: SizedBox()),
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Container(
                          width: 2.w,
                          height: 2.w,
                          decoration: BoxDecoration(
                            color: Color(0xFF39FF14),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF39FF14).withValues(
                                    alpha: _pulseAnimation.value * 0.5),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(height: 2.h),

                // System status indicators
                _buildStatusIndicator(
                  icon: Icons.battery_charging_full,
                  label: 'Battery',
                  value: '$_batteryLevel%',
                  color: _batteryLevel > 50 ? Color(0xFF39FF14) : Color(0xFFFF5252),
                  isDark: isDark,
                ),
                SizedBox(height: 1.5.h),

                _buildStatusIndicator(
                  icon: Icons.wifi,
                  label: 'Network',
                  value: '$_networkStrength%',
                  color: _networkStrength > 70 ? Color(0xFF00E5FF) : Color(0xFFFFAB40),
                  isDark: isDark,
                ),
                SizedBox(height: 1.5.h),

                _buildStatusIndicator(
                  icon: Icons.hub,
                  label: 'Mesh Nodes',
                  value: '$_meshNodes active',
                  color: Color(0xFFB388FF),
                  isDark: isDark,
                ),
                SizedBox(height: 1.5.h),

                _buildStatusIndicator(
                  icon: Icons.security,
                  label: 'Security',
                  value: _securityStatus,
                  color: Color(0xFF39FF14),
                  isDark: isDark,
                ),
                SizedBox(height: 2.h),

                // Quick actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildQuickActionButton(
                      icon: Icons.refresh,
                      label: 'Refresh',
                      onTap: () {},
                    ),
                    _buildQuickActionButton(
                      icon: Icons.settings,
                      label: 'Settings',
                      onTap: () => Navigator.pushNamed(context, '/settings'),
                    ),
                    _buildQuickActionButton(
                      icon: Icons.info_outline,
                      label: 'Info',
                      onTap: () {},
                    ),
                  ],
                ),

                // Footer
                SizedBox(height: 1.5.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 1.h),
                  decoration: BoxDecoration(
                    color: Color(0xFF39FF14).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(2.w),
                  ),
                  child: Text(
                    'AiFER OS v11 • Connected',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF39FF14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Row(
      children: [
        Container(
          width: 8.w,
          height: 8.w,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(2.w),
          ),
          child: Icon(
            icon,
            color: color,
            size: 4.w,
          ),
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w400,
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 10.w,
            height: 10.w,
            decoration: BoxDecoration(
              color: Color(0xFF39FF14).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(2.w),
            ),
            child: Icon(
              icon,
              color: Color(0xFF39FF14),
              size: 5.w,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 9.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// A screen that shows the AiFERHUD (for testing)
class AiFERHUDDemoScreen extends StatefulWidget {
  const AiFERHUDDemoScreen({Key? key}) : super(key: key);

  @override
  State<AiFERHUDDemoScreen> createState() => _AiFERHUDDemoScreenState();
}

class _AiFERHUDDemoScreenState extends State<AiFERHUDDemoScreen> {
  bool _hudVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AiFERHUD Demo'),
        actions: [
          IconButton(
            icon: Icon(Icons.visibility),
            onPressed: () {
              setState(() {
                _hudVisible = !_hudVisible;
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.touch_app,
                  size: 15.w,
                  color: Colors.grey,
                ),
                SizedBox(height: 2.h),
                Text(
                  'Toggle HUD visibility',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          
          // AiFERHUD overlay
          AiFERHUD(
            isVisible: _hudVisible,
            onTap: () {
              print('HUD tapped!');
            },
          ),
        ],
      ),
    );
  }
}