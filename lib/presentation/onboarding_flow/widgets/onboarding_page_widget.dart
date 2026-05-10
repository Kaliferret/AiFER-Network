import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

// Enhanced onboarding page widget with backward compatibility
class OnboardingPageWidget extends StatelessWidget {
  final String title;
  final String description;
  final String animationAsset;
  final Widget animationWidget;
  final bool isLastPage;

  const OnboardingPageWidget({
    super.key,
    required this.title,
    required this.description,
    required this.animationAsset,
    required this.animationWidget,
    this.isLastPage = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 100.w,
      height: 100.h,
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
      child: Column(
        children: [
          // Animation area with enhanced styling
          Expanded(
            flex: 6,
            child: Container(
              width: 100.w,
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.accentColor.withValues(alpha: 0.05),
                    Colors.transparent,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.accentColor.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: animationWidget,
              ),
            ),
          ),

          // Enhanced content area
          Expanded(
            flex: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Enhanced title styling
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? AppTheme.textPrimaryDark
                        : AppTheme.primaryLight,
                    letterSpacing: -0.8,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: 2.h),

                // Enhanced description with better container
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Text(
                    description,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: isDark
                          ? AppTheme.textSecondaryDark
                          : AppTheme.textSecondary,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                SizedBox(height: 3.h),

                // Enhanced CTA for last page
                if (isLastPage)
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: Duration(milliseconds: 800),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: 0.8 + (0.2 * value),
                        child: Container(
                          width: 85.w,
                          height: 6.h,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.accentColor,
                                AppTheme.accentColor.withValues(alpha: 0.8),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppTheme.accentColor.withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/authentication-setup',
                                (route) => false,
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CustomIconWidget(
                                      iconName: 'rocket_launch',
                                      color: AppTheme.primaryLight,
                                      size: 22,
                                    ),
                                    SizedBox(width: 3.w),
                                    Text(
                                      'Start Meshing',
                                      style: GoogleFonts.inter(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.primaryLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
