import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class BiometricSetupWidget extends StatefulWidget {
  final VoidCallback onSetupComplete;
  final VoidCallback onSkip;

  const BiometricSetupWidget({
    super.key,
    required onSetupComplete,
    required onSkip,
  })  : onSetupComplete = onSetupComplete,
        onSkip = onSkip;

  @override
  State<BiometricSetupWidget> createState() => _BiometricSetupWidgetState();
}

class _BiometricSetupWidgetState extends State<BiometricSetupWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  bool _isEnrolling = false;
  bool _isAvailable = true;
  String _biometricType = 'fingerprint'; // fingerprint, face, iris
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkBiometricAvailability();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _checkBiometricAvailability() async {
    // Simulate checking device biometric capabilities
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock platform detection for biometric type
    setState(() {
      // Simulate different biometric types based on mock platform
      final mockPlatforms = ['ios_face', 'android_fingerprint', 'android_face'];
      final selectedPlatform = mockPlatforms[DateTime.now().millisecond % 3];

      switch (selectedPlatform) {
        case 'ios_face':
          _biometricType = 'face';
          break;
        case 'android_face':
          _biometricType = 'face';
          break;
        default:
          _biometricType = 'fingerprint';
      }

      _isAvailable = true;
    });
  }

  Future<void> _enrollBiometric() async {
    setState(() {
      _isEnrolling = true;
      _errorMessage = null;
    });

    try {
      // Simulate biometric enrollment process
      await Future.delayed(const Duration(milliseconds: 2000));

      // Mock success/failure (90% success rate)
      final isSuccess = DateTime.now().millisecond % 10 != 0;

      if (isSuccess) {
        HapticFeedback.mediumImpact();
        widget.onSetupComplete();
      } else {
        throw Exception('Biometric enrollment failed');
      }
    } catch (e) {
      setState(() {
        _errorMessage = _getBiometricErrorMessage();
      });
      HapticFeedback.heavyImpact();
    } finally {
      setState(() {
        _isEnrolling = false;
      });
    }
  }

  String _getBiometricErrorMessage() {
    switch (_biometricType) {
      case 'face':
        return 'Gezichtsherkenning instellen mislukt. Zorg ervoor dat je gezicht goed zichtbaar is.';
      case 'iris':
        return 'Iris scan instellen mislukt. Probeer opnieuw met betere verlichting.';
      default:
        return 'Vingerafdruk instellen mislukt. Zorg ervoor dat je vinger schoon en droog is.';
    }
  }

  String _getBiometricTitle() {
    switch (_biometricType) {
      case 'face':
        return 'Gezichtsherkenning Instellen';
      case 'iris':
        return 'Iris Scan Instellen';
      default:
        return 'Vingerafdruk Instellen';
    }
  }

  String _getBiometricDescription() {
    switch (_biometricType) {
      case 'face':
        return 'Gebruik je gezicht om snel en veilig in te loggen op je FERMesh wallet';
      case 'iris':
        return 'Gebruik je iris om snel en veilig in te loggen op je FERMesh wallet';
      default:
        return 'Gebruik je vingerafdruk om snel en veilig in te loggen op je FERMesh wallet';
    }
  }

  IconData _getBiometricIcon() {
    switch (_biometricType) {
      case 'face':
        return Icons.face;
      case 'iris':
        return Icons.visibility;
      default:
        return Icons.fingerprint;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _getBiometricTitle(),
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppTheme.textPrimaryDark
                            : AppTheme.textPrimary,
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.onSkip,
                      child: Text(
                        'Overslaan',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.accentColor,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 6.h),

                // Biometric Icon with Pulse Animation
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        width: 25.w,
                        height: 25.w,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppTheme.accentColor,
                              AppTheme.accentColor.withValues(alpha: 0.7),
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color:
                                  AppTheme.accentColor.withValues(alpha: 0.4),
                              blurRadius: 25,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Center(
                          child: CustomIconWidget(
                            iconName: _getBiometricIcon().codePoint.toString(),
                            color: isDark
                                ? AppTheme.primaryLight
                                : AppTheme.surfaceLight,
                            size: 12.w,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                SizedBox(height: 4.h),

                // Title and Description
                Text(
                  'Biometrische Beveiliging',
                  style: GoogleFonts.inter(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppTheme.textPrimaryDark
                        : AppTheme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 1.h),

                Text(
                  _getBiometricDescription(),
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: isDark
                        ? AppTheme.textSecondaryDark
                        : AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 4.h),

                // Security Features
                _buildSecurityFeatures(isDark),

                SizedBox(height: 4.h),

                // Error Message
                if (_errorMessage != null) ...[
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(4.w),
                    margin: EdgeInsets.only(bottom: 3.h),
                    decoration: BoxDecoration(
                      color: AppTheme.errorColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.errorColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'error',
                          color: AppTheme.errorColor,
                          size: 5.w,
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: GoogleFonts.inter(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.errorColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Action Buttons
                Column(
                  children: [
                    // Enable Biometric Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isEnrolling || !_isAvailable
                            ? null
                            : _enrollBiometric,
                        child: _isEnrolling
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 4.w,
                                    height: 4.w,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppTheme.surfaceLight,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 3.w),
                                  Text(
                                    'Instellen...',
                                    style: GoogleFonts.inter(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CustomIconWidget(
                                    iconName: _getBiometricIcon()
                                        .codePoint
                                        .toString(),
                                    color: AppTheme.surfaceLight,
                                    size: 5.w,
                                  ),
                                  SizedBox(width: 3.w),
                                  Text(
                                    'Biometrie Inschakelen',
                                    style: GoogleFonts.inter(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentColor,
                          foregroundColor: AppTheme.surfaceLight,
                          padding: EdgeInsets.symmetric(vertical: 2.5.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 2.h),

                    // Skip Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _isEnrolling ? null : widget.onSkip,
                        child: Text(
                          'Later Instellen',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isDark
                              ? AppTheme.textSecondaryDark
                              : AppTheme.textSecondary,
                          side: BorderSide(
                            color: isDark
                                ? AppTheme.dividerDark.withValues(alpha: 0.5)
                                : AppTheme.dividerLight.withValues(alpha: 0.5),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 2.5.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSecurityFeatures(bool isDark) {
    final features = [
      {
        'icon': 'speed',
        'title': 'Snelle Toegang',
        'description': 'Log binnen seconden in zonder PIN',
      },
      {
        'icon': 'security',
        'title': 'Extra Beveiliging',
        'description': 'Biometrische data blijft op je apparaat',
      },
      {
        'icon': 'privacy_tip',
        'title': 'Privacy Beschermd',
        'description': 'Geen biometrische data wordt gedeeld',
      },
    ];

    return Column(
      children: features.map((feature) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(3.w),
          margin: EdgeInsets.only(bottom: 2.h),
          decoration: BoxDecoration(
            color: isDark
                ? AppTheme.surfaceDark.withValues(alpha: 0.5)
                : AppTheme.surfaceLight.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? AppTheme.dividerDark.withValues(alpha: 0.3)
                  : AppTheme.dividerLight.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 10.w,
                height: 10.w,
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: CustomIconWidget(
                    iconName: feature['icon']!,
                    color: AppTheme.accentColor,
                    size: 5.w,
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feature['title']!,
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppTheme.textPrimaryDark
                            : AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      feature['description']!,
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w400,
                        color: isDark
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
      }).toList(),
    );
  }
}
