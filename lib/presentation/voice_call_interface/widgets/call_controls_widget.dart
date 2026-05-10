import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CallControlsWidget extends StatefulWidget {
  final bool isMuted;
  final bool isSpeakerOn;
  final bool isOnHold;
  final VoidCallback onMuteToggle;
  final VoidCallback onSpeakerToggle;
  final VoidCallback onHoldToggle;
  final VoidCallback onEndCall;
  final VoidCallback onSwitchToVideo;
  final VoidCallback onSendMessage;
  final VoidCallback onViewContact;
  final VoidCallback onAddParticipant;

  const CallControlsWidget({
    super.key,
    required this.isMuted,
    required this.isSpeakerOn,
    required this.isOnHold,
    required this.onMuteToggle,
    required this.onSpeakerToggle,
    required this.onHoldToggle,
    required this.onEndCall,
    required this.onSwitchToVideo,
    required this.onSendMessage,
    required this.onViewContact,
    required this.onAddParticipant,
  });

  @override
  State<CallControlsWidget> createState() => _CallControlsWidgetState();
}

class _CallControlsWidgetState extends State<CallControlsWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? AppTheme.shadowDark.withValues(alpha: 0.3)
                : AppTheme.shadowLight.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Primary controls row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildControlButton(
                icon: widget.isMuted ? 'mic_off' : 'mic',
                isActive: widget.isMuted,
                onTap: widget.onMuteToggle,
                label: widget.isMuted ? 'Unmute' : 'Mute',
                isDark: isDark,
              ),
              _buildControlButton(
                icon: widget.isSpeakerOn ? 'volume_up' : 'volume_down',
                isActive: widget.isSpeakerOn,
                onTap: widget.onSpeakerToggle,
                label: widget.isSpeakerOn ? 'Speaker Off' : 'Speaker On',
                isDark: isDark,
              ),
              _buildControlButton(
                icon: widget.isOnHold ? 'play_arrow' : 'pause',
                isActive: widget.isOnHold,
                onTap: widget.onHoldToggle,
                label: widget.isOnHold ? 'Resume' : 'Hold',
                isDark: isDark,
              ),
              _buildControlButton(
                icon: 'person_add',
                isActive: false,
                onTap: widget.onAddParticipant,
                label: 'Add',
                isDark: isDark,
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // End call button with pulse animation
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: GestureDetector(
                  onTap: widget.onEndCall,
                  child: Container(
                    width: 20.w,
                    height: 20.w,
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
              );
            },
          ),

          SizedBox(height: 2.h),

          // Secondary actions row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSecondaryAction(
                icon: 'videocam',
                label: 'Video',
                onTap: widget.onSwitchToVideo,
                isDark: isDark,
              ),
              _buildSecondaryAction(
                icon: 'message',
                label: 'Message',
                onTap: widget.onSendMessage,
                isDark: isDark,
              ),
              _buildSecondaryAction(
                icon: 'contact_page',
                label: 'Contact',
                onTap: widget.onViewContact,
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required String icon,
    required bool isActive,
    required VoidCallback onTap,
    required String label,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 15.w,
        height: 15.w,
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.accentColor.withValues(alpha: 0.2)
              : (isDark
                  ? AppTheme.primaryDark.withValues(alpha: 0.3)
                  : AppTheme.primaryLight.withValues(alpha: 0.1)),
          shape: BoxShape.circle,
          border: Border.all(
            color: isActive
                ? AppTheme.accentColor
                : (isDark
                    ? AppTheme.textSecondaryDark.withValues(alpha: 0.3)
                    : AppTheme.textSecondary.withValues(alpha: 0.3)),
            width: 1.5,
          ),
        ),
        child: CustomIconWidget(
          iconName: icon,
          color: isActive
              ? AppTheme.accentColor
              : (isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary),
          size: 6.w,
        ),
      ),
    );
  }

  Widget _buildSecondaryAction({
    required String icon,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: isDark
                  ? AppTheme.primaryDark.withValues(alpha: 0.3)
                  : AppTheme.primaryLight.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: CustomIconWidget(
              iconName: icon,
              color:
                  isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
              size: 5.w,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            label,
            style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
              color:
                  isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
              fontSize: 10.sp,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
