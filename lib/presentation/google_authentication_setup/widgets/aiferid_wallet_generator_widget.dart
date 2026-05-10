import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AiFERiDWalletGeneratorWidget extends StatefulWidget {
  const AiFERiDWalletGeneratorWidget({Key? key}) : super(key: key);

  @override
  State<AiFERiDWalletGeneratorWidget> createState() =>
      _AiFERiDWalletGeneratorWidgetState();
}

class _AiFERiDWalletGeneratorWidgetState
    extends State<AiFERiDWalletGeneratorWidget> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    )..repeat();

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * 3.14159,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Animated Wallet Generation Icon
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotationAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: 20.w,
                  height: 20.w,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF6C63FF),
                        Color(0xFF3F51B5),
                        Color(0xFF2196F3),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10.w),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF6C63FF).withAlpha(77),
                        blurRadius: 15,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.account_balance_wallet_outlined,
                    color: Colors.white,
                    size: 8.w,
                  ),
                ),
              ),
            );
          },
        ),

        SizedBox(height: 5.h),

        // Title
        Text(
          'Creating Your AiFERiD',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.headlineMedium?.color,
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: 2.h),

        // Subtitle
        Text(
          'Generating secure blockchain wallet address...',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            color:
                Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(179),
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: 4.h),

        // Progress Steps
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
              _buildProgressStep(
                icon: Icons.vpn_key_outlined,
                title: 'Generating cryptographic keys',
                isActive: true,
                isCompleted: false,
              ),
              SizedBox(height: 2.h),
              _buildProgressStep(
                icon: Icons.security_outlined,
                title: 'Creating secure wallet address',
                isActive: true,
                isCompleted: false,
              ),
              SizedBox(height: 2.h),
              _buildProgressStep(
                icon: Icons.fingerprint_outlined,
                title: 'Establishing AiFERiD identity',
                isActive: true,
                isCompleted: false,
              ),
              SizedBox(height: 2.h),
              _buildProgressStep(
                icon: Icons.cloud_upload_outlined,
                title: 'Registering with AiFER Network',
                isActive: false,
                isCompleted: false,
              ),
            ],
          ),
        ),

        SizedBox(height: 4.h),

        // Security Notice
        Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: Colors.amber.withAlpha(26),
            borderRadius: BorderRadius.circular(2.w),
            border: Border.all(color: Colors.amber.withAlpha(77)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.amber[800],
                size: 5.w,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Secure Generation',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.amber[800],
                      ),
                    ),
                    Text(
                      'Your private keys are generated locally and encrypted. Never share your recovery phrase with anyone.',
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        color: Colors.amber[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 4.h),

        // Loading indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 6.w,
              height: 6.w,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color(0xFF6C63FF),
                ),
              ),
            ),
            SizedBox(width: 4.w),
            Text(
              'Please wait...',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: Color(0xFF6C63FF),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressStep({
    required IconData icon,
    required String title,
    required bool isActive,
    required bool isCompleted,
  }) {
    return Row(
      children: [
        Container(
          width: 8.w,
          height: 8.w,
          decoration: BoxDecoration(
            color: isCompleted
                ? Colors.green
                : isActive
                    ? Color(0xFF6C63FF)
                    : Theme.of(context).dividerColor.withAlpha(128),
            borderRadius: BorderRadius.circular(4.w),
          ),
          child: Icon(
            isCompleted ? Icons.check : icon,
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
        if (isActive && !isCompleted) ...[
          SizedBox(
            width: 4.w,
            height: 4.w,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
            ),
          ),
        ],
      ],
    );
  }
}
