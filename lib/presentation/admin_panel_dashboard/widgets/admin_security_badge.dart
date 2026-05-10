import 'package:flutter/material.dart';
import '../../../core/color_polyfill.dart';
import 'package:sizer/sizer.dart';

import '../../../theme/app_theme.dart';

/// Admin Security Badge showing admin privileges and email
class AdminSecurityBadge extends StatelessWidget {
  final String adminEmail;

  const AdminSecurityBadge({
    super.key,
    required this.adminEmail,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.only(right: 2.w),
      padding: EdgeInsets.symmetric(
        horizontal: 3.w,
        vertical: 1.5.w,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.accentColor,
            AppTheme.accentColor.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentColor.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.admin_panel_settings,
            color: Colors.white,
            size: 4.w,
          ),
          SizedBox(width: 2.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'ADMIN',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 8.sp,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                adminEmail.split('@')[0],
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 7.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
