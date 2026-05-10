import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../services/renewed_auth_service.dart';

class LoginMethodSelectorWidget extends StatefulWidget {
  final Function(AuthMethod) onMethodSelected;
  final AuthMethod? selectedMethod;
  final Map<String, dynamic> authStats;

  const LoginMethodSelectorWidget({
    super.key,
    required this.onMethodSelected,
    this.selectedMethod,
    this.authStats = const {},
  });

  @override
  State<LoginMethodSelectorWidget> createState() =>
      _LoginMethodSelectorWidgetState();
}

class _LoginMethodSelectorWidgetState extends State<LoginMethodSelectorWidget>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _selectMethod(AuthMethod method) {
    HapticFeedback.selectionClick();
    _scaleController.forward().then((_) {
      _scaleController.reverse();
      widget.onMethodSelected(method);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 90.w,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.accentColor.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentColor.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(isDark),
          SizedBox(height: 3.h),
          _buildMethodGrid(isDark),
          SizedBox(height: 2.h),
          _buildSecurityInfo(isDark),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(2.5.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.accentColor,
                AppTheme.accentColor.withValues(alpha: 0.8),
              ],
            ),
            shape: BoxShape.circle,
          ),
          child: CustomIconWidget(
            iconName: 'security',
            color: AppTheme.primaryLight,
            size: 20,
          ),
        ),
        SizedBox(height: 1.5.h),
        Text(
          'Choose Login Method',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          'Select your preferred authentication method',
          style: GoogleFonts.inter(
            fontSize: 11.sp,
            color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildMethodGrid(bool isDark) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMethodCard(
                method: AuthMethod.aiferid,
                icon: 'account_balance_wallet',
                title: 'AiFERiD',
                subtitle: 'Blockchain Wallet',
                isAvailable: true,
                isRecommended: true,
                isDark: isDark,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: _buildMethodCard(
                method: AuthMethod.email,
                icon: 'email',
                title: 'Email',
                subtitle: 'Email & Password',
                isAvailable: true,
                isRecommended: false,
                isDark: isDark,
              ),
            ),
          ],
        ),
        SizedBox(height: 3.w),
        Row(
          children: [
            Expanded(
              child: _buildMethodCard(
                method: AuthMethod.biometric,
                icon: 'fingerprint',
                title: 'Biometric',
                subtitle: 'Fingerprint/Face',
                isAvailable: widget.authStats['biometric_enabled'] == true,
                isRecommended: false,
                isDark: isDark,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: _buildMethodCard(
                method: AuthMethod.quickLogin,
                icon: 'flash_on',
                title: 'Quick Login',
                subtitle: 'Saved Session',
                isAvailable: widget.authStats['quick_login_enabled'] == true,
                isRecommended: false,
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMethodCard({
    required AuthMethod method,
    required String icon,
    required String title,
    required String subtitle,
    required bool isAvailable,
    required bool isRecommended,
    required bool isDark,
  }) {
    final isSelected = widget.selectedMethod == method;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: isSelected ? _scaleAnimation.value : 1.0,
          child: GestureDetector(
            onTap: isAvailable ? () => _selectMethod(method) : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? AppTheme.accentColor.withValues(alpha: 0.1)
                        : (isDark
                            ? AppTheme.backgroundDark.withValues(alpha: 0.7)
                            : AppTheme.backgroundLight.withValues(alpha: 0.7)),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      isSelected
                          ? AppTheme.accentColor
                          : (isAvailable
                              ? AppTheme.accentColor.withValues(alpha: 0.3)
                              : Colors.grey.withValues(alpha: 0.3)),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow:
                    isSelected
                        ? [
                          BoxShadow(
                            color: AppTheme.accentColor.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                        : null,
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        padding: EdgeInsets.all(3.w),
                        decoration: BoxDecoration(
                          color:
                              isAvailable
                                  ? (isSelected
                                      ? AppTheme.accentColor
                                      : AppTheme.accentColor.withValues(
                                        alpha: 0.2,
                                      ))
                                  : Colors.grey.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: CustomIconWidget(
                          iconName: isAvailable ? icon : 'lock',
                          color:
                              isAvailable
                                  ? (isSelected
                                      ? AppTheme.primaryLight
                                      : AppTheme.accentColor)
                                  : Colors.grey,
                          size: 16,
                        ),
                      ),
                      if (isRecommended)
                        Positioned(
                          top: -2,
                          right: -2,
                          child: Container(
                            padding: EdgeInsets.all(1.w),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                            child: CustomIconWidget(
                              iconName: 'star',
                              color: AppTheme.primaryLight,
                              size: 8,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color:
                          isAvailable
                              ? (isDark
                                  ? AppTheme.textPrimaryDark
                                  : AppTheme.textPrimary)
                              : Colors.grey,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 9.sp,
                      color:
                          isAvailable
                              ? (isDark
                                  ? AppTheme.textSecondaryDark
                                  : AppTheme.textSecondary)
                              : Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (!isAvailable) ...[
                    SizedBox(height: 1.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 2.w,
                        vertical: 0.5.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Not Available',
                        style: GoogleFonts.inter(
                          fontSize: 8.sp,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSecurityInfo(bool isDark) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.accentColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.accentColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'shield',
            color: AppTheme.accentColor,
            size: 14,
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enhanced Security',
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.accentColor,
                  ),
                ),
                Text(
                  'All authentication methods use end-to-end encryption and blockchain verification',
                  style: GoogleFonts.inter(
                    fontSize: 9.sp,
                    color:
                        isDark
                            ? AppTheme.textSecondaryDark
                            : AppTheme.textSecondary,
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
