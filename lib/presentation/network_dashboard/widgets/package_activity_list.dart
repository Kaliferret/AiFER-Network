import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class PackageActivityList extends StatelessWidget {
  final List<Map<String, dynamic>> packages;

  const PackageActivityList({
    super.key,
    required this.packages,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (packages.isEmpty) {
      return _buildEmptyState(context);
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? AppTheme.shadowDark.withValues(alpha: 0.1)
                : AppTheme.shadowLight.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.fromLTRB(4.w, 3.w, 4.w, 2.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recente Pakket Activiteit',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppTheme.textPrimaryDark
                        : AppTheme.textPrimary,
                  ),
                ),
                CustomIconWidget(
                  iconName: 'history',
                  color: AppTheme.accentColor,
                  size: 5.w,
                ),
              ],
            ),
          ),

          // Package list
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: packages.length > 5 ? 5 : packages.length,
            separatorBuilder: (context, index) => Divider(
              color: isDark
                  ? AppTheme.dividerDark.withValues(alpha: 0.3)
                  : AppTheme.dividerLight.withValues(alpha: 0.3),
              height: 1,
              indent: 4.w,
              endIndent: 4.w,
            ),
            itemBuilder: (context, index) {
              final package = packages[index];
              return _PackageItem(package: package);
            },
          ),

          // View all button
          if (packages.length > 5)
            Padding(
              padding: EdgeInsets.all(3.w),
              child: Center(
                child: TextButton(
                  onPressed: () {
                    // Navigate to full package history
                  },
                  child: Text(
                    'Bekijk Alle Pakketten',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: AppTheme.accentColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? AppTheme.shadowDark.withValues(alpha: 0.1)
                : AppTheme.shadowLight.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: 'inbox',
            color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
            size: 10.w,
          ),
          SizedBox(height: 2.h),
          Text(
            'Geen Pakket Activiteit',
            style: theme.textTheme.titleMedium?.copyWith(
              color:
                  isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Pakketten verschijnen hier zodra ze worden verzonden of ontvangen',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark
                  ? AppTheme.textSecondaryDark.withValues(alpha: 0.7)
                  : AppTheme.textSecondary.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _PackageItem extends StatelessWidget {
  final Map<String, dynamic> package;

  const _PackageItem({required this.package});

  Color _getPackageTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'aif':
        return AppTheme.accentColor;
      case 'aifp':
        return AppTheme.successColor;
      case 'ferg':
        return AppTheme.warningColor;
      default:
        return AppTheme.textSecondary;
    }
  }

  String _getPackageTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'aif':
        return 'message';
      case 'aifp':
        return 'lock';
      case 'ferg':
        return 'games';
      default:
        return 'package_2';
    }
  }

  String _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return 'check_circle';
      case 'sending':
        return 'schedule';
      case 'failed':
        return 'error';
      default:
        return 'radio_button_unchecked';
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return AppTheme.successColor;
      case 'sending':
        return AppTheme.warningColor;
      case 'failed':
        return AppTheme.errorColor;
      default:
        return AppTheme.textSecondary;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return 'Afgeleverd';
      case 'sending':
        return 'Verzenden...';
      case 'failed':
        return 'Mislukt';
      default:
        return 'Onbekend';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final packageType = package['type'] as String;
    final status = package['status'] as String;
    final typeColor = _getPackageTypeColor(packageType);
    final statusColor = _getStatusColor(status);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.w),
      child: Row(
        children: [
          // Package type indicator
          Container(
            width: 10.w,
            height: 10.w,
            decoration: BoxDecoration(
              color: typeColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: _getPackageTypeIcon(packageType),
                color: typeColor,
                size: 5.w,
              ),
            ),
          ),

          SizedBox(width: 3.w),

          // Package details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '.${packageType.toUpperCase()}',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: typeColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      package['direction'] == 'sent' ? 'naar' : 'van',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppTheme.textSecondaryDark
                            : AppTheme.textSecondary,
                      ),
                    ),
                    SizedBox(width: 1.w),
                    Expanded(
                      child: Text(
                        package['recipient'] as String,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AppTheme.textPrimaryDark
                              : AppTheme.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 0.5.h),
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: _getStatusIcon(status),
                      color: statusColor,
                      size: 3.w,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      _getStatusText(status),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      package['timestamp'] as String,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppTheme.textSecondaryDark.withValues(alpha: 0.7)
                            : AppTheme.textSecondary.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Size indicator
          Text(
            package['size'] as String,
            style: theme.textTheme.bodySmall?.copyWith(
              color:
                  isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
