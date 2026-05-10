import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class NearbyDevicesList extends StatelessWidget {
  final List<Map<String, dynamic>> devices;
  final Function(Map<String, dynamic>) onDeviceTap;
  final Function(Map<String, dynamic>) onDirectMessage;
  final Function(Map<String, dynamic>) onVoiceCall;
  final Function(Map<String, dynamic>) onAddTrusted;

  const NearbyDevicesList({
    super.key,
    required this.devices,
    required this.onDeviceTap,
    required this.onDirectMessage,
    required this.onVoiceCall,
    required this.onAddTrusted,
  });

  @override
  Widget build(BuildContext context) {
    if (devices.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: devices.length,
      separatorBuilder: (context, index) => SizedBox(height: 1.h),
      itemBuilder: (context, index) {
        final device = devices[index];
        return _DeviceCard(
          device: device,
          onTap: () => onDeviceTap(device),
          onDirectMessage: () => onDirectMessage(device),
          onVoiceCall: () => onVoiceCall(device),
          onAddTrusted: () => onAddTrusted(device),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(8.w),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: 'search_off',
            color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
            size: 12.w,
          ),
          SizedBox(height: 2.h),
          Text(
            'Geen FERMesh Apparaten Gevonden',
            style: theme.textTheme.titleMedium?.copyWith(
              color:
                  isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 1.h),
          Text(
            'Trek naar beneden om opnieuw te scannen of gebruik de scan knop',
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

class _DeviceCard extends StatefulWidget {
  final Map<String, dynamic> device;
  final VoidCallback onTap;
  final VoidCallback onDirectMessage;
  final VoidCallback onVoiceCall;
  final VoidCallback onAddTrusted;

  const _DeviceCard({
    required this.device,
    required this.onTap,
    required this.onDirectMessage,
    required this.onVoiceCall,
    required this.onAddTrusted,
  });

  @override
  State<_DeviceCard> createState() => _DeviceCardState();
}

class _DeviceCardState extends State<_DeviceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _slideController.forward();
      } else {
        _slideController.reverse();
      }
    });
  }

  Color _getConnectionQualityColor(String quality) {
    switch (quality.toLowerCase()) {
      case 'excellent':
        return AppTheme.successColor;
      case 'good':
        return AppTheme.accentColor;
      case 'fair':
        return AppTheme.warningColor;
      case 'poor':
        return AppTheme.errorColor;
      default:
        return AppTheme.textSecondary;
    }
  }

  String _getConnectionQualityText(String quality) {
    switch (quality.toLowerCase()) {
      case 'excellent':
        return 'Uitstekend';
      case 'good':
        return 'Goed';
      case 'fair':
        return 'Redelijk';
      case 'poor':
        return 'Slecht';
      default:
        return 'Onbekend';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final device = widget.device;
    final qualityColor =
        _getConnectionQualityColor(device['connectionQuality'] as String);

    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: _toggleExpanded,
      child: Container(
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
          children: [
            // Main device info
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Row(
                children: [
                  // Device avatar
                  Container(
                    width: 12.w,
                    height: 12.w,
                    decoration: BoxDecoration(
                      color: qualityColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: CustomIconWidget(
                        iconName: device['deviceType'] == 'mobile'
                            ? 'smartphone'
                            : 'computer',
                        color: qualityColor,
                        size: 6.w,
                      ),
                    ),
                  ),

                  SizedBox(width: 3.w),

                  // Device details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          device['name'] as String,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppTheme.textPrimaryDark
                                : AppTheme.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 0.5.h),
                        Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'location_on',
                              color: AppTheme.accentColor,
                              size: 3.w,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              '${device['distance']}m',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDark
                                    ? AppTheme.textSecondaryDark
                                    : AppTheme.textSecondary,
                              ),
                            ),
                            SizedBox(width: 3.w),
                            Container(
                              width: 2.w,
                              height: 2.w,
                              decoration: BoxDecoration(
                                color: qualityColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              _getConnectionQualityText(
                                  device['connectionQuality'] as String),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: qualityColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Services indicator
                  Column(
                    children: [
                      if ((device['services'] as List).contains('messaging'))
                        Container(
                          margin: EdgeInsets.only(bottom: 0.5.h),
                          child: CustomIconWidget(
                            iconName: 'message',
                            color: AppTheme.accentColor,
                            size: 4.w,
                          ),
                        ),
                      if ((device['services'] as List).contains('calling'))
                        CustomIconWidget(
                          iconName: 'call',
                          color: AppTheme.successColor,
                          size: 4.w,
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // Quick actions (slide in from right)
            if (_isExpanded)
              SlideTransition(
                position: _slideAnimation,
                child: Container(
                  padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 3.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActionButton(
                        context,
                        'Bericht',
                        'message',
                        AppTheme.accentColor,
                        widget.onDirectMessage,
                      ),
                      _buildActionButton(
                        context,
                        'Bellen',
                        'call',
                        AppTheme.successColor,
                        widget.onVoiceCall,
                      ),
                      _buildActionButton(
                        context,
                        'Vertrouwd',
                        'verified_user',
                        AppTheme.warningColor,
                        widget.onAddTrusted,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    String iconName,
    Color color,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            CustomIconWidget(
              iconName: iconName,
              color: color,
              size: 5.w,
            ),
            SizedBox(height: 0.5.h),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
