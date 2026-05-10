import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class EmergencyModeToggle extends StatefulWidget {
  final bool isEmergencyMode;
  final ValueChanged<bool> onToggle;

  const EmergencyModeToggle({
    super.key,
    required this.isEmergencyMode,
    required this.onToggle,
  });

  @override
  State<EmergencyModeToggle> createState() => _EmergencyModeToggleState();
}

class _EmergencyModeToggleState extends State<EmergencyModeToggle>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    if (widget.isEmergencyMode) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(EmergencyModeToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isEmergencyMode != oldWidget.isEmergencyMode) {
      if (widget.isEmergencyMode) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.reset();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _showEmergencyDialog() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppTheme.dialogDark : AppTheme.dialogLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'warning',
              color: AppTheme.warningColor,
              size: 6.w,
            ),
            SizedBox(width: 3.w),
            Text(
              'Noodmodus',
              style: theme.textTheme.titleLarge?.copyWith(
                color: AppTheme.warningColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.isEmergencyMode
                  ? 'Noodmodus uitschakelen?'
                  : 'Noodmodus inschakelen?',
              style: theme.textTheme.titleMedium?.copyWith(
                color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            if (!widget.isEmergencyMode) ...[
              _buildFeatureItem(
                context,
                'Verhoogd bereik voor noodcommunicatie',
                'signal_cellular_alt',
              ),
              _buildFeatureItem(
                context,
                'Batterij optimalisatie voor langere werking',
                'battery_saver',
              ),
              _buildFeatureItem(
                context,
                'Prioriteit voor noodberichten',
                'priority_high',
              ),
              _buildFeatureItem(
                context,
                'Automatische locatie delen',
                'location_on',
              ),
            ] else ...[
              Text(
                'Hiermee wordt de noodmodus uitgeschakeld en keren alle instellingen terug naar normaal.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? AppTheme.textSecondaryDark
                      : AppTheme.textSecondary,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annuleren',
              style: theme.textTheme.labelLarge?.copyWith(
                color: isDark
                    ? AppTheme.textSecondaryDark
                    : AppTheme.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onToggle(!widget.isEmergencyMode);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.isEmergencyMode
                  ? AppTheme.successColor
                  : AppTheme.warningColor,
              foregroundColor: AppTheme.surfaceLight,
            ),
            child: Text(
              widget.isEmergencyMode ? 'Uitschakelen' : 'Inschakelen',
              style: theme.textTheme.labelLarge?.copyWith(
                color: AppTheme.surfaceLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(BuildContext context, String text, String iconName) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: iconName,
            color: AppTheme.accentColor,
            size: 4.w,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? AppTheme.textSecondaryDark
                    : AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: _showEmergencyDialog,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.isEmergencyMode ? _pulseAnimation.value : 1.0,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: widget.isEmergencyMode
                    ? AppTheme.warningColor.withValues(alpha: 0.1)
                    : (isDark ? AppTheme.cardDark : AppTheme.cardLight),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.isEmergencyMode
                      ? AppTheme.warningColor
                      : Colors.transparent,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.isEmergencyMode
                        ? AppTheme.warningColor.withValues(alpha: 0.3)
                        : (isDark
                            ? AppTheme.shadowDark.withValues(alpha: 0.1)
                            : AppTheme.shadowLight.withValues(alpha: 0.05)),
                    blurRadius: widget.isEmergencyMode ? 8 : 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Emergency icon
                  Container(
                    width: 12.w,
                    height: 12.w,
                    decoration: BoxDecoration(
                      color: widget.isEmergencyMode
                          ? AppTheme.warningColor.withValues(alpha: 0.2)
                          : AppTheme.accentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: CustomIconWidget(
                        iconName:
                            widget.isEmergencyMode ? 'emergency' : 'shield',
                        color: widget.isEmergencyMode
                            ? AppTheme.warningColor
                            : AppTheme.accentColor,
                        size: 6.w,
                      ),
                    ),
                  ),

                  SizedBox(width: 4.w),

                  // Text content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.isEmergencyMode
                              ? 'Noodmodus Actief'
                              : 'Noodmodus',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: widget.isEmergencyMode
                                ? AppTheme.warningColor
                                : (isDark
                                    ? AppTheme.textPrimaryDark
                                    : AppTheme.textPrimary),
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          widget.isEmergencyMode
                              ? 'Verhoogd bereik en batterij optimalisatie'
                              : 'Tik om noodcommunicatie in te schakelen',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: widget.isEmergencyMode
                                ? AppTheme.warningColor.withValues(alpha: 0.8)
                                : (isDark
                                    ? AppTheme.textSecondaryDark
                                    : AppTheme.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Toggle indicator
                  Container(
                    width: 6.w,
                    height: 6.w,
                    decoration: BoxDecoration(
                      color: widget.isEmergencyMode
                          ? AppTheme.warningColor
                          : (isDark
                              ? AppTheme.textSecondaryDark
                                  .withValues(alpha: 0.3)
                              : AppTheme.textSecondary.withValues(alpha: 0.3)),
                      shape: BoxShape.circle,
                    ),
                    child: widget.isEmergencyMode
                        ? Center(
                            child: CustomIconWidget(
                              iconName: 'check',
                              color: AppTheme.surfaceLight,
                              size: 3.w,
                            ),
                          )
                        : null,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
