import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FallbackAuthOptions extends StatelessWidget {
  const FallbackAuthOptions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Divider with text
        Row(
          children: [
            Expanded(
              child: Divider(
                color: Theme.of(context).dividerColor.withAlpha(128),
                thickness: 1,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                'or continue with',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  color: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.color
                      ?.withAlpha(153),
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: Theme.of(context).dividerColor.withAlpha(128),
                thickness: 1,
              ),
            ),
          ],
        ),

        SizedBox(height: 4.h),

        // Fallback options
        Row(
          children: [
            // PIN Setup
            Expanded(
              child: _buildFallbackOption(
                context: context,
                icon: Icons.pin_outlined,
                title: 'PIN Setup',
                subtitle: 'Create secure PIN',
                color: Color(0xFFFF9800),
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.authenticationSetup);
                },
              ),
            ),

            SizedBox(width: 3.w),

            // Biometric Setup
            Expanded(
              child: _buildFallbackOption(
                context: context,
                icon: Icons.fingerprint,
                title: 'Biometric',
                subtitle: 'Fingerprint/Face ID',
                color: Color(0xFF9C27B0),
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.authenticationSetup);
                },
              ),
            ),
          ],
        ),

        SizedBox(height: 3.h),

        // Skip option
        TextButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, AppRoutes.networkDashboard);
          },
          child: Text(
            'Skip for now',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color:
                  Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(179),
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFallbackOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 15.h,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(
          color: Theme.of(context).dividerColor.withAlpha(77),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(3.w),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(3.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    color: color.withAlpha(26),
                    borderRadius: BorderRadius.circular(6.w),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 6.w,
                  ),
                ),
                SizedBox(height: 1.5.h),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.titleMedium?.color,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    color: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.color
                        ?.withAlpha(179),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
