import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../core/app_export.dart';

/// Base44-styled loading skeleton.
///
/// Dark-mode shimmer tuned to the fernetwork palette: a `#2A2A2A` base with a
/// subtle green highlight sweep (`AppTheme.primary` @ 10% alpha). Use as a
/// drop-in placeholder while async data loads.
///
/// Example:
/// ```dart
/// if (_loading) return ShimmerBox(width: 40.w, height: 2.h);
/// ```
class ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? margin;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
    this.margin,
  });

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin,
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
        child: AnimatedBuilder(
          animation: _c,
          builder: (_, __) {
            return Stack(
              children: [
                Positioned(
                  left: _c.value * widget.width * 1.6 - widget.width * 0.4,
                  top: 0,
                  bottom: 0,
                  width: widget.width * 0.4,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          AppTheme.surfaceElevated,
                          AppTheme.primary.withValues(alpha: 0.10),
                          AppTheme.surfaceElevated,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// A stack of skeleton rows mimicking a list item card.
class ShimmerListItem extends StatelessWidget {
  final double? height;

  const ShimmerListItem({super.key, this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.04),
        ),
      ),
      child: Row(
        children: [
          ShimmerBox(
            width: 11.w,
            height: 11.w,
            borderRadius: BorderRadius.circular(12),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: 50.w, height: 1.6.h),
                SizedBox(height: 1.h),
                ShimmerBox(width: 70.w, height: 1.2.h),
                SizedBox(height: 0.8.h),
                ShimmerBox(width: 35.w, height: 1.2.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Inline error card with friendly copy + retry.
///
/// Centered card suitable for dropping into an empty list area when a fetch
/// fails. Styled base44 dark; uses the pink accent so it reads as urgent
/// without being alarming.
class ErrorStateView extends StatelessWidget {
  final String title;
  final String? message;
  final IconData icon;
  final VoidCallback? onRetry;
  final String retryLabel;

  const ErrorStateView({
    super.key,
    required this.title,
    this.message,
    this.icon = Icons.cloud_off_rounded,
    this.onRetry,
    this.retryLabel = 'Try again',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 18.w,
              height: 18.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accent.withValues(alpha: 0.12),
                border: Border.all(
                  color: AppTheme.accent.withValues(alpha: 0.35),
                  width: 1.5,
                ),
              ),
              child: Icon(
                icon,
                color: AppTheme.accent,
                size: 9.w,
              ),
            ),
            SizedBox(height: 2.5.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (message != null) ...[
              SizedBox(height: 1.h),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12.sp,
                  height: 1.4,
                ),
              ),
            ],
            if (onRetry != null) ...[
              SizedBox(height: 3.h),
              ElevatedButton.icon(
                onPressed: () {
                  // Small haptic/visual cue — Material ripple is enough.
                  onRetry!();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(
                    horizontal: 6.w,
                    vertical: 1.6.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(
                  retryLabel,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Empty-state card: friendly placeholder when a list is empty but not errored.
class EmptyStateView extends StatelessWidget {
  final String title;
  final String? message;
  final IconData icon;
  final Widget? action;

  const EmptyStateView({
    super.key,
    required this.title,
    this.message,
    this.icon = Icons.inbox_outlined,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 18.w,
              height: 18.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primary.withValues(alpha: 0.10),
                border: Border.all(
                  color: AppTheme.primary.withValues(alpha: 0.30),
                  width: 1.5,
                ),
              ),
              child: Icon(
                icon,
                color: AppTheme.primary,
                size: 9.w,
              ),
            ),
            SizedBox(height: 2.5.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (message != null) ...[
              SizedBox(height: 1.h),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12.sp,
                  height: 1.4,
                ),
              ),
            ],
            if (action != null) ...[
              SizedBox(height: 3.h),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Scale + haptic wrapper for any tap target. Use on dashboard tiles or any
/// "primary CTA" card so the user gets satisfying physical feedback.
class TapScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final Duration duration;
  final String? semanticsLabel;

  const TapScale({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 0.96,
    this.duration = const Duration(milliseconds: 110),
    this.semanticsLabel,
  });

  @override
  State<TapScale> createState() => _TapScaleState();
}

class _TapScaleState extends State<TapScale> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final child = AnimatedScale(
      scale: _down ? widget.scale : 1.0,
      duration: widget.duration,
      curve: Curves.easeOut,
      child: widget.child,
    );
    return Semantics(
      button: widget.onTap != null,
      label: widget.semanticsLabel,
      child: GestureDetector(
        onTapDown: widget.onTap == null
            ? null
            : (_) => setState(() => _down = true),
        onTapUp: widget.onTap == null
            ? null
            : (_) => setState(() => _down = false),
        onTapCancel: widget.onTap == null
            ? null
            : () => setState(() => _down = false),
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: child,
      ),
    );
  }
}
