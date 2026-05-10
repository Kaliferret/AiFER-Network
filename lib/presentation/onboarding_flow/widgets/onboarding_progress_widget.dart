import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class OnboardingProgressWidget extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback onSkip;
  final bool isDark;

  const OnboardingProgressWidget({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onSkip,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100.w,
      height: 10.h,
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Enhanced logo with network status
          Expanded(
            flex: 2,
            child: Row(
              children: [
                // Animated logo
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 1000),
                  builder: (context, value, child) {
                    return Transform.rotate(
                      angle: value * 0.1,
                      child: Container(
                        width: 10.w,
                        height: 10.w,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.accentColor,
                              AppTheme.accentColor.withValues(alpha: 0.8),
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color:
                                  AppTheme.accentColor.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: CustomIconWidget(
                            iconName: 'hub',
                            color: AppTheme.primaryLight,
                            size: 24,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(width: 3.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'FERNetwork',
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppTheme.textPrimaryDark
                            : AppTheme.primaryLight,
                      ),
                    ),
                    Text(
                      'Setup ${currentPage + 1}/$totalPages',
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w400,
                        color: isDark
                            ? AppTheme.textSecondaryDark
                            : AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Progress bar in center
          Expanded(
            flex: 3,
            child: Container(
              height: 0.8.h,
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              decoration: BoxDecoration(
                color: (isDark
                        ? AppTheme.textSecondaryDark
                        : AppTheme.textSecondary)
                    .withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Stack(
                children: [
                  // Progress fill with animation
                  TweenAnimationBuilder<double>(
                    tween: Tween(
                      begin: 0.0,
                      end: (currentPage + 1) / totalPages,
                    ),
                    duration: Duration(milliseconds: 600),
                    curve: Curves.easeInOutCubic,
                    builder: (context, value, child) {
                      return Container(
                        width: 100.w * value,
                        height: 0.8.h,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.accentColor,
                              AppTheme.accentColor.withValues(alpha: 0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    },
                  ),
                  // Shimmer effect
                  if (currentPage < totalPages - 1)
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: -1.0, end: 1.0),
                      duration: Duration(milliseconds: 1500),
                      builder: (context, value, child) {
                        return Positioned(
                          left: value * 100.w,
                          child: Container(
                            width: 20.w,
                            height: 0.8.h,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Colors.white.withValues(alpha: 0.3),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),

          // Skip button with enhanced styling
          if (currentPage < totalPages - 1)
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 500),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 0.8 + (0.2 * value),
                  child: Container(
                    decoration: BoxDecoration(
                      color: (isDark
                              ? AppTheme.textSecondaryDark
                              : AppTheme.textSecondary)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: (isDark
                                ? AppTheme.textSecondaryDark
                                : AppTheme.textSecondary)
                            .withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: TextButton(
                      onPressed: onSkip,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            horizontal: 4.w, vertical: 1.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Skip',
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? AppTheme.textSecondaryDark
                                  : AppTheme.textSecondary,
                            ),
                          ),
                          SizedBox(width: 1.w),
                          CustomIconWidget(
                            iconName: 'fast_forward',
                            color: isDark
                                ? AppTheme.textSecondaryDark
                                : AppTheme.textSecondary,
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            )
          else
            const SizedBox.shrink(),
        ],
      ),
    );
  }
}
