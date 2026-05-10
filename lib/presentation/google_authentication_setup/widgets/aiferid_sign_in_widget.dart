import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AiFERiDSignInWidget extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const AiFERiDSignInWidget({
    Key? key,
    required this.onPressed,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF6C63FF),
          foregroundColor: Colors.white,
          padding: EdgeInsets.all(4.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2.w),
          ),
          elevation: 2,
          shadowColor: Color(0xFF6C63FF).withAlpha(77),
        ),
        child: isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 5.w,
                    height: 5.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    'Authenticating...',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 6.w,
                    height: 6.w,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(51),
                      borderRadius: BorderRadius.circular(3.w),
                    ),
                    child: Icon(
                      Icons.account_balance_wallet_outlined,
                      color: Colors.white,
                      size: 3.5.w,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    'Sign in with AiFERiD',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
