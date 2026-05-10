import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class PageIndicatorWidget extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final ValueChanged<int>? onPageTap;

  const PageIndicatorWidget({
    super.key,
    required this.currentPage,
    required this.totalPages,
    this.onPageTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 6.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(totalPages, (index) {
          return GestureDetector(
            onTap: onPageTap != null ? () => onPageTap!(index) : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: EdgeInsets.symmetric(horizontal: 1.w),
              width: index == currentPage ? 8.w : 3.w,
              height: 1.h,
              decoration: BoxDecoration(
                color: index == currentPage
                    ? AppTheme.accentColor
                    : (isDark
                            ? AppTheme.textSecondaryDark
                            : AppTheme.textSecondary)
                        .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(0.5.h),
                boxShadow: index == currentPage
                    ? [
                        BoxShadow(
                          color: AppTheme.accentColor.withValues(alpha: 0.4),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
            ),
          );
        }),
      ),
    );
  }
}
