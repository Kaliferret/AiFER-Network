import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CallHeaderWidget extends StatefulWidget {
  final String contactName;
  final String contactNumber;
  final String? contactAvatar;
  final Duration callDuration;
  final String callStatus;
  final bool isIncoming;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;

  const CallHeaderWidget({
    super.key,
    required this.contactName,
    required this.contactNumber,
    this.contactAvatar,
    required this.callDuration,
    required this.callStatus,
    this.isIncoming = false,
    this.onAccept,
    this.onDecline,
  });

  @override
  State<CallHeaderWidget> createState() => _CallHeaderWidgetState();
}

class _CallHeaderWidgetState extends State<CallHeaderWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    if (widget.isIncoming) {
      _pulseController.repeat(reverse: true);
    }
    _slideController.forward();
  }

  @override
  void didUpdateWidget(CallHeaderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isIncoming && !oldWidget.isIncoming) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isIncoming && oldWidget.isIncoming) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
        child: Column(
          children: [
            // Contact avatar with pulse animation for incoming calls
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: widget.isIncoming ? _pulseAnimation.value : 1.0,
                  child: Container(
                    width: 35.w,
                    height: 35.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: widget.isIncoming
                            ? AppTheme.accentColor
                            : (isDark
                                ? AppTheme.textSecondaryDark
                                    .withValues(alpha: 0.3)
                                : AppTheme.textSecondary
                                    .withValues(alpha: 0.3)),
                        width: 3,
                      ),
                      boxShadow: [
                        if (widget.isIncoming)
                          BoxShadow(
                            color: AppTheme.accentColor.withValues(alpha: 0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                      ],
                    ),
                    child: ClipOval(
                      child: widget.contactAvatar != null
                          ? CustomImageWidget(
                              imageUrl: widget.contactAvatar!,
                              width: 35.w,
                              height: 35.w,
                              fit: BoxFit.cover,
                              semanticLabel:
                                  "Profile photo of ${widget.contactName}",
                            )
                          : Container(
                              color: isDark
                                  ? AppTheme.primaryDark
                                  : AppTheme.primaryLight
                                      .withValues(alpha: 0.1),
                              child: CustomIconWidget(
                                iconName: 'person',
                                color: isDark
                                    ? AppTheme.textSecondaryDark
                                    : AppTheme.textSecondary,
                                size: 15.w,
                              ),
                            ),
                    ),
                  ),
                );
              },
            ),

            SizedBox(height: 3.h),

            // Contact name
            Text(
              widget.contactName,
              style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 20.sp,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            SizedBox(height: 1.h),

            // Contact number
            Text(
              widget.contactNumber,
              style: AppTheme.getMonospaceStyle(
                isLight: !isDark,
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 2.h),

            // Call status and duration
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: isDark
                    ? AppTheme.surfaceDark.withValues(alpha: 0.6)
                    : AppTheme.surfaceLight.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark
                      ? AppTheme.textSecondaryDark.withValues(alpha: 0.2)
                      : AppTheme.textSecondary.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: widget.isIncoming ? 'call_received' : 'call_made',
                    color: widget.isIncoming
                        ? AppTheme.accentColor
                        : AppTheme.successColor,
                    size: 4.w,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    widget.isIncoming
                        ? widget.callStatus
                        : _formatDuration(widget.callDuration),
                    style: AppTheme.getMonospaceStyle(
                      isLight: !isDark,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Incoming call buttons
            if (widget.isIncoming &&
                widget.onAccept != null &&
                widget.onDecline != null) ...[
              SizedBox(height: 4.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Decline button
                  GestureDetector(
                    onTap: widget.onDecline,
                    child: Container(
                      width: 18.w,
                      height: 18.w,
                      decoration: BoxDecoration(
                        color: AppTheme.errorColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.errorColor.withValues(alpha: 0.4),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: CustomIconWidget(
                        iconName: 'call_end',
                        color: AppTheme.surfaceLight,
                        size: 8.w,
                      ),
                    ),
                  ),

                  // Accept button
                  GestureDetector(
                    onTap: widget.onAccept,
                    child: Container(
                      width: 18.w,
                      height: 18.w,
                      decoration: BoxDecoration(
                        color: AppTheme.successColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.successColor.withValues(alpha: 0.4),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: CustomIconWidget(
                        iconName: 'call',
                        color: AppTheme.surfaceLight,
                        size: 8.w,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
