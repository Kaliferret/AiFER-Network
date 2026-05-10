import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

/// Google Sign-In Button Widget with Material Design styling
class GoogleSignInButtonWidget extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isSignedIn;

  const GoogleSignInButtonWidget({
    Key? key,
    required this.onPressed,
    this.isLoading = false,
    this.isSignedIn = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      height: 14.w,
      child: ElevatedButton(
        onPressed: isLoading || isSignedIn ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isSignedIn
              ? Colors.green
              : Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.white,
          foregroundColor: isSignedIn
              ? Colors.white
              : Theme.of(context).brightness == Brightness.dark
                  ? Colors.black87
                  : Colors.black87,
          elevation: isLoading ? 0 : 2,
          shadowColor: Theme.of(context).primaryColor.withAlpha(77),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isSignedIn
                  ? Colors.green.withAlpha(77)
                  : Theme.of(context).dividerColor.withAlpha(51),
              width: 1,
            ),
          ),
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
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    'Authenticating...',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!isSignedIn) ...[
                    Image.network(
                      'https://developers.google.com/identity/images/g-logo.png',
                      width: 6.w,
                      height: 6.w,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.g_mobiledata,
                        size: 6.w,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(width: 3.w),
                  ] else ...[
                    Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 6.w,
                    ),
                    SizedBox(width: 3.w),
                  ],
                  Text(
                    isSignedIn
                        ? 'Signed in with Google'
                        : 'Sign in with Google',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: isSignedIn ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
