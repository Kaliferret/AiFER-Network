import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class ChatMessageItem extends StatefulWidget {
  final Map<String, dynamic> message;
  final bool isCurrentUser;
  final VoidCallback? onLongPress;
  final Function(String)? onCopy;
  final Function(Map<String, dynamic>)? onForward;
  final Function(String)? onViewOnChain;
  final VoidCallback? onDelete;

  const ChatMessageItem({
    super.key,
    required this.message,
    required this.isCurrentUser,
    this.onLongPress,
    this.onCopy,
    this.onForward,
    this.onViewOnChain,
    this.onDelete,
  });

  @override
  State<ChatMessageItem> createState() => _ChatMessageItemState();
}

class _ChatMessageItemState extends State<ChatMessageItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _showContextMenu = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleLongPress() {
    HapticFeedback.mediumImpact();
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
    setState(() {
      _showContextMenu = true;
    });
    widget.onLongPress?.call();
    _showMessageContextMenu();
  }

  void _showMessageContextMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _MessageContextMenu(
        message: widget.message,
        onCopy: widget.onCopy,
        onForward: widget.onForward,
        onViewOnChain: widget.onViewOnChain,
        onDelete: widget.onDelete,
        onClose: () {
          setState(() {
            _showContextMenu = false;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isAiFp = widget.message['packageType'] == '.AiFp';

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: EdgeInsets.symmetric(
              horizontal: 4.w,
              vertical: 1.h,
            ),
            child: Row(
              mainAxisAlignment: widget.isCurrentUser
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Avatar for received messages
                if (!widget.isCurrentUser) ...[
                  Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.accentColor.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: ClipOval(
                      child: CustomImageWidget(
                        imageUrl: widget.message['senderAvatar'] ?? '',
                        width: 8.w,
                        height: 8.w,
                        fit: BoxFit.cover,
                        semanticLabel:
                            widget.message['senderAvatarSemanticLabel'] ??
                                'Sender profile picture',
                      ),
                    ),
                  ),
                  SizedBox(width: 2.w),
                ],

                // Message bubble
                Flexible(
                  child: GestureDetector(
                    onLongPress: _handleLongPress,
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: 75.w,
                        minWidth: 20.w,
                      ),
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: widget.isCurrentUser
                            ? AppTheme.accentColor
                            : (isDark ? AppTheme.cardDark : AppTheme.cardLight),
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: widget.isCurrentUser
                              ? const Radius.circular(16)
                              : const Radius.circular(4),
                          bottomRight: widget.isCurrentUser
                              ? const Radius.circular(4)
                              : const Radius.circular(16),
                        ),
                        border: isAiFp
                            ? Border.all(
                                color: AppTheme.warningColor
                                    .withValues(alpha: 0.5),
                                width: 1,
                              )
                            : null,
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? AppTheme.shadowDark.withValues(alpha: 0.1)
                                : AppTheme.shadowLight.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Package type indicator
                          if (widget.message['packageType'] != null) ...[
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 2.w,
                                    vertical: 0.5.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.getPackageTypeColor(
                                      widget.message['packageType'],
                                    ).withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    widget.message['packageType'],
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: AppTheme.getPackageTypeColor(
                                        widget.message['packageType'],
                                      ),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),

                                // Self-destruct timer for .AiFp
                                if (isAiFp &&
                                    widget.message['destructTimer'] !=
                                        null) ...[
                                  SizedBox(width: 2.w),
                                  CustomIconWidget(
                                    iconName: 'timer',
                                    color: AppTheme.warningColor,
                                    size: 14,
                                  ),
                                  SizedBox(width: 1.w),
                                  Text(
                                    '${widget.message['destructTimer']}s',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: AppTheme.warningColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            SizedBox(height: 1.h),
                          ],

                          // Message content
                          if (widget.message['type'] == 'text') ...[
                            Text(
                              widget.message['content'] ?? '',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: widget.isCurrentUser
                                    ? AppTheme.primaryLight
                                    : (isDark
                                        ? AppTheme.textPrimaryDark
                                        : AppTheme.textPrimary),
                              ),
                            ),
                          ] else if (widget.message['type'] == 'voice') ...[
                            _VoiceMessageWidget(
                              message: widget.message,
                              isCurrentUser: widget.isCurrentUser,
                            ),
                          ] else if (widget.message['type'] == 'image') ...[
                            _ImageMessageWidget(
                              message: widget.message,
                            ),
                          ],

                          SizedBox(height: 1.h),

                          // Message metadata
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Timestamp
                              Text(
                                widget.message['timestamp'] ?? '',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: widget.isCurrentUser
                                      ? AppTheme.primaryLight
                                          .withValues(alpha: 0.7)
                                      : (isDark
                                          ? AppTheme.textSecondaryDark
                                              .withValues(alpha: 0.7)
                                          : AppTheme.textSecondary
                                              .withValues(alpha: 0.7)),
                                ),
                              ),

                              // Delivery status for sent messages
                              if (widget.isCurrentUser &&
                                  widget.message['deliveryStatus'] != null) ...[
                                SizedBox(width: 2.w),
                                CustomIconWidget(
                                  iconName: _getDeliveryStatusIcon(
                                    widget.message['deliveryStatus'],
                                  ),
                                  color: _getDeliveryStatusColor(
                                    widget.message['deliveryStatus'],
                                  ),
                                  size: 14,
                                ),
                              ],

                              // Blockchain hash indicator
                              if (widget.message['blockchainHash'] != null) ...[
                                SizedBox(width: 2.w),
                                GestureDetector(
                                  onTap: () => widget.onViewOnChain?.call(
                                    widget.message['blockchainHash'],
                                  ),
                                  child: CustomIconWidget(
                                    iconName: 'link',
                                    color: AppTheme.accentColor,
                                    size: 14,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Spacing for sent messages
                if (widget.isCurrentUser) SizedBox(width: 2.w),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getDeliveryStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'sent':
        return 'check';
      case 'delivered':
        return 'done_all';
      case 'read':
        return 'done_all';
      case 'failed':
        return 'error_outline';
      case 'pending':
        return 'schedule';
      default:
        return 'schedule';
    }
  }

  Color _getDeliveryStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'sent':
        return AppTheme.primaryLight.withValues(alpha: 0.7);
      case 'delivered':
        return AppTheme.primaryLight.withValues(alpha: 0.7);
      case 'read':
        return AppTheme.successColor;
      case 'failed':
        return AppTheme.errorColor;
      case 'pending':
        return AppTheme.warningColor;
      default:
        return AppTheme.primaryLight.withValues(alpha: 0.7);
    }
  }
}

class _VoiceMessageWidget extends StatefulWidget {
  final Map<String, dynamic> message;
  final bool isCurrentUser;

  const _VoiceMessageWidget({
    required this.message,
    required this.isCurrentUser,
  });

  @override
  State<_VoiceMessageWidget> createState() => _VoiceMessageWidgetState();
}

class _VoiceMessageWidgetState extends State<_VoiceMessageWidget> {
  bool _isPlaying = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(2.w),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _isPlaying = !_isPlaying;
              });
            },
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: widget.isCurrentUser
                    ? AppTheme.primaryLight.withValues(alpha: 0.2)
                    : AppTheme.accentColor.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: _isPlaying ? 'pause' : 'play_arrow',
                color: widget.isCurrentUser
                    ? AppTheme.primaryLight
                    : AppTheme.accentColor,
                size: 20,
              ),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Waveform visualization
                Container(
                  height: 3.h,
                  child: Row(
                    children: List.generate(20, (index) {
                      return Container(
                        width: 0.5.w,
                        height: (index % 4 + 1) * 0.75.h,
                        margin: EdgeInsets.symmetric(horizontal: 0.2.w),
                        decoration: BoxDecoration(
                          color: widget.isCurrentUser
                              ? AppTheme.primaryLight.withValues(alpha: 0.6)
                              : AppTheme.accentColor.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      );
                    }),
                  ),
                ),

                SizedBox(height: 0.5.h),

                Text(
                  widget.message['duration'] ?? '0:00',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: widget.isCurrentUser
                        ? AppTheme.primaryLight.withValues(alpha: 0.7)
                        : (isDark
                            ? AppTheme.textSecondaryDark.withValues(alpha: 0.7)
                            : AppTheme.textSecondary.withValues(alpha: 0.7)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageMessageWidget extends StatelessWidget {
  final Map<String, dynamic> message;

  const _ImageMessageWidget({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: 60.w,
        maxHeight: 40.h,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CustomImageWidget(
          imageUrl: message['imageUrl'] ?? '',
          width: double.infinity,
          height: 30.h,
          fit: BoxFit.cover,
          semanticLabel:
              message['imageSemanticLabel'] ?? 'Shared image in conversation',
        ),
      ),
    );
  }
}

class _MessageContextMenu extends StatelessWidget {
  final Map<String, dynamic> message;
  final Function(String)? onCopy;
  final Function(Map<String, dynamic>)? onForward;
  final Function(String)? onViewOnChain;
  final VoidCallback? onDelete;
  final VoidCallback onClose;

  const _MessageContextMenu({
    required this.message,
    this.onCopy,
    this.onForward,
    this.onViewOnChain,
    this.onDelete,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? AppTheme.shadowDark.withValues(alpha: 0.2)
                : AppTheme.shadowLight.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 10.w,
            height: 0.5.h,
            margin: EdgeInsets.symmetric(vertical: 2.h),
            decoration: BoxDecoration(
              color: isDark
                  ? AppTheme.textSecondaryDark.withValues(alpha: 0.3)
                  : AppTheme.textSecondary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Menu items
          _buildMenuItem(
            context,
            icon: 'content_copy',
            title: 'Copy',
            onTap: () {
              onCopy?.call(message['content'] ?? '');
              onClose();
            },
          ),

          _buildMenuItem(
            context,
            icon: 'forward',
            title: 'Forward',
            onTap: () {
              onForward?.call(message);
              onClose();
            },
          ),

          if (message['blockchainHash'] != null)
            _buildMenuItem(
              context,
              icon: 'link',
              title: 'View on FERChain',
              onTap: () {
                onViewOnChain?.call(message['blockchainHash']);
                onClose();
              },
            ),

          _buildMenuItem(
            context,
            icon: 'delete',
            title: 'Delete',
            isDestructive: true,
            onTap: () {
              onDelete?.call();
              onClose();
            },
          ),

          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required String icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: 4.w,
            vertical: 3.h,
          ),
          child: Row(
            children: [
              CustomIconWidget(
                iconName: icon,
                color: isDestructive
                    ? AppTheme.errorColor
                    : (isDark
                        ? AppTheme.textPrimaryDark
                        : AppTheme.textPrimary),
                size: 24,
              ),
              SizedBox(width: 4.w),
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDestructive
                      ? AppTheme.errorColor
                      : (isDark
                          ? AppTheme.textPrimaryDark
                          : AppTheme.textPrimary),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
