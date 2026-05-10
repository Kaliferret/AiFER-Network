import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';

class GoogleSignInButton extends StatelessWidget {
  final VoidCallback onPressed;

  const GoogleSignInButton({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 12.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3.w),
        gradient: LinearGradient(
          colors: [
            Color(0xFF4285F4),
            Color(0xFF34A853),
          ],
          stops: [0.0, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF4285F4).withAlpha(77),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(3.w),
          onTap: onPressed,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Google Logo
                Container(
                  width: 6.w,
                  height: 6.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(1.w),
                  ),
                  child: Center(
                    child: Text(
                      'G',
                      style: GoogleFonts.inter(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4285F4),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 4.w),
                // Button text
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Continue with Google',
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        'Secure OAuth integration',
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          color: Colors.white.withAlpha(204),
                        ),
                      ),
                    ],
                  ),
                ),
                // Arrow icon
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 4.w,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
