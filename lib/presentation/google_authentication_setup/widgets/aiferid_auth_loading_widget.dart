import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AiFERiDAuthLoadingWidget extends StatefulWidget {
  const AiFERiDAuthLoadingWidget({Key? key}) : super(key: key);

  @override
  State<AiFERiDAuthLoadingWidget> createState() =>
      _AiFERiDAuthLoadingWidgetState();
}

class _AiFERiDAuthLoadingWidgetState extends State<AiFERiDAuthLoadingWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Animated AiFERiD Authentication Icon
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: 25.w,
                height: 25.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF6C63FF),
                      Color(0xFF3F51B5),
                      Color(0xFF2196F3),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12.w),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF6C63FF).withAlpha(102),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: Icon(
                        Icons.verified_user_outlined,
                        color: Colors.white,
                        size: 12.w,
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),

        SizedBox(height: 6.h),

        // Title
        Text(
          'Authenticating AiFERiD',
          style: GoogleFonts.inter(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.headlineMedium?.color,
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: 2.h),

        // Subtitle
        Text(
          'Verifying your blockchain identity...',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            color:
                Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(179),
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: 5.h),

        // Authentication Steps
        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(3.w),
            border: Border.all(
              color: Theme.of(context).dividerColor.withAlpha(77),
            ),
          ),
          child: Column(
            children: [
              _buildAuthStep(
                icon: Icons.search_outlined,
                title: 'Locating AiFERiD in network',
                isActive: true,
              ),
              SizedBox(height: 2.h),
              _buildAuthStep(
                icon: Icons.vpn_key_outlined,
                title: 'Verifying cryptographic signature',
                isActive: true,
              ),
              SizedBox(height: 2.h),
              _buildAuthStep(
                icon: Icons.security_outlined,
                title: 'Establishing secure session',
                isActive: false,
              ),
              SizedBox(height: 2.h),
              _buildAuthStep(
                icon: Icons.done_outline,
                title: 'Granting network access',
                isActive: false,
              ),
            ],
          ),
        ),

        SizedBox(height: 5.h),

        // Security Features
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildSecurityFeature(
              icon: Icons.lock_outline,
              label: 'Encrypted',
            ),
            _buildSecurityFeature(
              icon: Icons.fingerprint_outlined,
              label: 'Biometric',
            ),
            _buildSecurityFeature(
              icon: Icons.shield_outlined,
              label: 'Secure',
            ),
          ],
        ),

        SizedBox(height: 5.h),

        // Progress Indicator
        Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: Color(0xFF6C63FF).withAlpha(26),
            borderRadius: BorderRadius.circular(2.w),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 5.w,
                height: 5.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Color(0xFF6C63FF),
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Text(
                'Authenticating your AiFERiD identity...',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  color: Color(0xFF6C63FF),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAuthStep({
    required IconData icon,
    required String title,
    required bool isActive,
  }) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: isActive ? _fadeAnimation.value : 0.5,
          child: Row(
            children: [
              Container(
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(
                  color: isActive
                      ? Color(0xFF6C63FF)
                      : Theme.of(context).dividerColor.withAlpha(128),
                  borderRadius: BorderRadius.circular(4.w),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 4.w,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                    color: isActive
                        ? Theme.of(context).textTheme.bodyLarge?.color
                        : Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color
                            ?.withAlpha(128),
                  ),
                ),
              ),
              if (isActive) ...[
                SizedBox(
                  width: 4.w,
                  height: 4.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildSecurityFeature({
    required IconData icon,
    required String label,
  }) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Column(
            children: [
              Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  color: Color(0xFF6C63FF).withAlpha(26),
                  borderRadius: BorderRadius.circular(6.w),
                ),
                child: Icon(
                  icon,
                  color: Color(0xFF6C63FF),
                  size: 6.w,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 10.sp,
                  color: Color(0xFF6C63FF),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
