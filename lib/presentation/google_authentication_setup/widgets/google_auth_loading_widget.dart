import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';

class GoogleAuthLoadingWidget extends StatefulWidget {
  const GoogleAuthLoadingWidget({Key? key}) : super(key: key);

  @override
  State<GoogleAuthLoadingWidget> createState() =>
      _GoogleAuthLoadingWidgetState();
}

class _GoogleAuthLoadingWidgetState extends State<GoogleAuthLoadingWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Animated Google OAuth icon
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform.scale(
              scale: 0.8 + (_animation.value * 0.4),
              child: Container(
                width: 20.w,
                height: 20.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF4285F4),
                      Color(0xFF34A853),
                      Color(0xFFEA4335),
                      Color(0xFFFBBC05),
                    ],
                    stops: [0.0, 0.33, 0.66, 1.0],
                  ),
                  borderRadius: BorderRadius.circular(10.w),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF4285F4)
                          .withOpacity(0.3 + (_animation.value * 0.2)),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'G',
                    style: GoogleFonts.inter(
                      fontSize: 30.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        SizedBox(height: 4.h),

        // Loading text
        Text(
          'Authenticating with Google',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),

        SizedBox(height: 2.h),

        // Progress description
        Text(
          'Securely connecting to your Google account...',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            color:
                Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(179),
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: 4.h),

        // Loading indicator
        Container(
          width: 60.w,
          child: LinearProgressIndicator(
            backgroundColor: Theme.of(context).dividerColor.withAlpha(77),
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4285F4)),
          ),
        ),

        SizedBox(height: 2.h),

        // Security note
        Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(2.w),
            border: Border.all(
              color: Color(0xFF4285F4).withAlpha(77),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.shield_outlined,
                color: Color(0xFF4285F4),
                size: 4.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'OAuth 2.0 secured connection',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  color: Color(0xFF4285F4),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
