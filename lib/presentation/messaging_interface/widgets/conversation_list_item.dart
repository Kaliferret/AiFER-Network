import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class ConversationListItem extends StatelessWidget {
  final Map<String, dynamic> conversation;
  final VoidCallback onTap;
  final VoidCallback onArchive;
  final VoidCallback onDelete;

  const ConversationListItem({
    super.key,
    required this.conversation,
    required this.onTap,
    required this.onArchive,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dismissible(
      key: Key(conversation['id'].toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        decoration: BoxDecoration(
          color: AppTheme.errorColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: onArchive,
              child: Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: AppTheme.warningColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: 'archive',
                  color: AppTheme.surfaceLight,
                  size: 20,
                ),
              ),
            ),
            SizedBox(width: 3.w),
            GestureDetector(
              onTap: onDelete,
              child: Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: 'delete',
                  color: AppTheme.surfaceLight,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? AppTheme.shadowDark.withValues(alpha: 0.1)
                  : AppTheme.shadowLight.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 12.w,
                    height: 12.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.accentColor.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: CustomImageWidget(
                        imageUrl: conversation['avatar'] ?? '',
                        width: 12.w,
                        height: 12.w,
                        fit: BoxFit.cover,
                        semanticLabel: conversation['avatarSemanticLabel'] ??
                            'Contact profile picture',
                      ),
                    ),
                  ),

                  SizedBox(width: 3.w),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                conversation['name'] ?? 'Unknown Contact',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppTheme.textPrimaryDark
                                      : AppTheme.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),

                            // Network status indicator
                            if (conversation['networkStatus'] != null) ...[
                              SizedBox(width: 2.w),
                              Container(
                                width: 2.w,
                                height: 2.w,
                                decoration: BoxDecoration(
                                  color: AppTheme.getNetworkStatusColor(
                                    conversation['networkStatus'],
                                  ),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                        SizedBox(height: 0.5.h),
                        Row(
                          children: [
                            // Package type indicator
                            if (conversation['packageType'] != null) ...[
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 2.w,
                                  vertical: 0.5.h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.getPackageTypeColor(
                                    conversation['packageType'],
                                  ).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  conversation['packageType'],
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: AppTheme.getPackageTypeColor(
                                      conversation['packageType'],
                                    ),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              SizedBox(width: 2.w),
                            ],

                            // Last message preview
                            Expanded(
                              child: Text(
                                conversation['lastMessage'] ??
                                    'No messages yet',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isDark
                                      ? AppTheme.textSecondaryDark
                                          .withValues(alpha: 0.8)
                                      : AppTheme.textSecondary
                                          .withValues(alpha: 0.8),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(width: 2.w),

                  // Right side info
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Timestamp
                      Text(
                        conversation['timestamp'] ?? '',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: isDark
                              ? AppTheme.textSecondaryDark
                                  .withValues(alpha: 0.6)
                              : AppTheme.textSecondary.withValues(alpha: 0.6),
                        ),
                      ),

                      SizedBox(height: 1.h),

                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Delivery status
                          if (conversation['deliveryStatus'] != null) ...[
                            CustomIconWidget(
                              iconName: _getDeliveryStatusIcon(
                                conversation['deliveryStatus'],
                              ),
                              color: _getDeliveryStatusColor(
                                conversation['deliveryStatus'],
                                isDark,
                              ),
                              size: 16,
                            ),
                            SizedBox(width: 1.w),
                          ],

                          // Unread count
                          if (conversation['unreadCount'] != null &&
                              conversation['unreadCount'] > 0) ...[
                            Container(
                              constraints: BoxConstraints(
                                minWidth: 5.w,
                                minHeight: 5.w,
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 1.5.w,
                                vertical: 0.5.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.accentColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                conversation['unreadCount'] > 99
                                    ? '99+'
                                    : conversation['unreadCount'].toString(),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: AppTheme.primaryLight,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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

  Color _getDeliveryStatusColor(String status, bool isDark) {
    switch (status.toLowerCase()) {
      case 'sent':
        return isDark
            ? AppTheme.textSecondaryDark.withValues(alpha: 0.6)
            : AppTheme.textSecondary.withValues(alpha: 0.6);
      case 'delivered':
        return AppTheme.accentColor;
      case 'read':
        return AppTheme.successColor;
      case 'failed':
        return AppTheme.errorColor;
      case 'pending':
        return AppTheme.warningColor;
      default:
        return isDark
            ? AppTheme.textSecondaryDark.withValues(alpha: 0.6)
            : AppTheme.textSecondary.withValues(alpha: 0.6);
    }
  }
}
