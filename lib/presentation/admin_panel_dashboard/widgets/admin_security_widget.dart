import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

/// Admin Security Widget for session monitoring and security status
class AdminSecurityWidget extends StatelessWidget {
  const AdminSecurityWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Security Status Indicator
        Container(
          width: 3.w,
          height: 3.w,
          decoration: const BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 2.w),

        Text(
          'Secure Session',
          style: GoogleFonts.inter(
            fontSize: 10.sp,
            fontWeight: FontWeight.w600,
            color: Colors.green,
          ),
        ),

        SizedBox(width: 3.w),

        // Session Timer
        Container(
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.w),
          decoration: BoxDecoration(
            color: Colors.red.withAlpha(51),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '45:23',
            style: GoogleFonts.inter(
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              color: Colors.red,
            ),
          ),
        ),
      ],
    );
  }
}