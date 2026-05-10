import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

/// Fallback Authentication Options Widget for offline access
class FallbackAuthOptionsWidget extends StatelessWidget {
  final VoidCallback onPinSetup;
  final VoidCallback onBiometricSetup;

  const FallbackAuthOptionsWidget({
    Key? key,
    required this.onPinSetup,
    required this.onBiometricSetup,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withAlpha(51),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Offline Access Options',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.titleMedium?.color,
            ),
          ),

          SizedBox(height: 1.w),

          Text(
            'Set up alternative authentication for offline network access',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),

          SizedBox(height: 4.w),

          // PIN Setup Option
          _buildAuthOption(
            context,
            title: 'PIN Authentication',
            description: 'Traditional 6-digit PIN for quick access',
            icon: Icons.pin,
            color: Colors.blue,
            onTap: onPinSetup,
          ),

          SizedBox(height: 3.w),

          // Biometric Setup Option
          _buildAuthOption(
            context,
            title: 'Biometric Authentication',
            description: 'Fingerprint or face recognition',
            icon: Icons.fingerprint,
            color: Colors.green,
            onTap: onBiometricSetup,
          ),

          SizedBox(height: 4.w),

          // Security Notice
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withAlpha(26),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).primaryColor,
                  size: 5.w,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    'Fallback methods maintain mesh network functionality during offline periods',
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthOption(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: color.withAlpha(13),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withAlpha(51),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 6.w,
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.titleMedium?.color,
                    ),
                  ),
                  SizedBox(height: 1.w),
                  Text(
                    description,
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: color,
              size: 4.w,
            ),
          ],
        ),
      ),
    );
  }
}
