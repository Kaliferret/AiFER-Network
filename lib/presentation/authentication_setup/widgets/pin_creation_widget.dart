import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PinCreationWidget extends StatefulWidget {
  final Function(String) onPinCreated;
  final VoidCallback onBack;

  const PinCreationWidget({
    super.key,
    required this.onPinCreated,
    required this.onBack,
  });

  @override
  State<PinCreationWidget> createState() => _PinCreationWidgetState();
}

class _PinCreationWidgetState extends State<PinCreationWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _shakeController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _shakeAnimation;

  String _currentPin = '';
  String _confirmPin = '';
  bool _isConfirmingPin = false;
  bool _isCreating = false;
  String? _errorMessage;

  final int _pinLength = 6;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _shakeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticIn,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _onNumberPressed(String number) {
    HapticFeedback.lightImpact();

    setState(() {
      _errorMessage = null;

      if (_isConfirmingPin) {
        if (_confirmPin.length < _pinLength) {
          _confirmPin += number;

          if (_confirmPin.length == _pinLength) {
            _validatePins();
          }
        }
      } else {
        if (_currentPin.length < _pinLength) {
          _currentPin += number;

          if (_currentPin.length == _pinLength) {
            _proceedToConfirmation();
          }
        }
      }
    });
  }

  void _onDeletePressed() {
    HapticFeedback.lightImpact();

    setState(() {
      _errorMessage = null;

      if (_isConfirmingPin) {
        if (_confirmPin.isNotEmpty) {
          _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
        }
      } else {
        if (_currentPin.isNotEmpty) {
          _currentPin = _currentPin.substring(0, _currentPin.length - 1);
        }
      }
    });
  }

  void _proceedToConfirmation() {
    // Check for weak PIN patterns
    if (_isWeakPin(_currentPin)) {
      _showError('Zwakke PIN gedetecteerd. Kies een veiligere combinatie.');
      _shakeController.forward().then((_) => _shakeController.reset());
      setState(() {
        _currentPin = '';
      });
      return;
    }

    setState(() {
      _isConfirmingPin = true;
    });

    HapticFeedback.mediumImpact();
  }

  bool _isWeakPin(String pin) {
    // Check for common weak patterns
    final weakPatterns = [
      '123456',
      '654321',
      '111111',
      '222222',
      '333333',
      '444444',
      '555555',
      '666666',
      '777777',
      '888888',
      '999999',
      '000000',
      '012345',
      '543210',
      '101010',
      '121212',
      '131313',
      '141414',
      '151515',
      '161616',
      '171717',
      '181818',
      '191919',
      '202020'
    ];

    return weakPatterns.contains(pin);
  }

  void _validatePins() {
    if (_currentPin == _confirmPin) {
      _createPin();
    } else {
      _showError('PIN codes komen niet overeen. Probeer opnieuw.');
      _shakeController.forward().then((_) => _shakeController.reset());
      setState(() {
        _confirmPin = '';
      });
    }
  }

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
    });

    HapticFeedback.heavyImpact();

    // Clear error after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _errorMessage = null;
        });
      }
    });
  }

  Future<void> _createPin() async {
    setState(() {
      _isCreating = true;
    });

    // Simulate PIN creation process
    await Future.delayed(const Duration(milliseconds: 1500));

    setState(() {
      _isCreating = false;
    });

    HapticFeedback.mediumImpact();
    widget.onPinCreated(_currentPin);
  }

  void _resetPin() {
    setState(() {
      _currentPin = '';
      _confirmPin = '';
      _isConfirmingPin = false;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          // Header
          Row(
            children: [
              GestureDetector(
                onTap: widget.onBack,
                child: Container(
                  width: 10.w,
                  height: 10.w,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppTheme.surfaceDark.withValues(alpha: 0.8)
                        : AppTheme.surfaceLight.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? AppTheme.dividerDark.withValues(alpha: 0.3)
                          : AppTheme.dividerLight.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: 'arrow_back_ios',
                      color: isDark
                          ? AppTheme.textPrimaryDark
                          : AppTheme.textPrimary,
                      size: 5.w,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  _isConfirmingPin ? 'PIN Bevestigen' : 'PIN Aanmaken',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppTheme.textPrimaryDark
                        : AppTheme.textPrimary,
                  ),
                ),
              ),
              if (_isConfirmingPin)
                GestureDetector(
                  onTap: _resetPin,
                  child: Text(
                    'Opnieuw',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.accentColor,
                    ),
                  ),
                ),
            ],
          ),

          SizedBox(height: 4.h),

          // Security Icon
          Container(
            width: 16.w,
            height: 16.w,
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
                  color: AppTheme.accentColor.withValues(alpha: 0.3),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: _isConfirmingPin ? 'verified_user' : 'lock',
                color: isDark ? AppTheme.primaryLight : AppTheme.surfaceLight,
                size: 8.w,
              ),
            ),
          ),

          SizedBox(height: 3.h),

          // Title and Description
          Text(
            _isConfirmingPin ? 'Bevestig je PIN' : 'Maak een veilige PIN aan',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 1.h),

          Text(
            _isConfirmingPin
                ? 'Voer je PIN opnieuw in ter bevestiging'
                : 'Deze PIN wordt gebruikt om je FERMesh wallet te beveiligen',
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              fontWeight: FontWeight.w400,
              color:
                  isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 4.h),

          // PIN Display
          AnimatedBuilder(
            animation: _shakeAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(
                  _shakeAnimation.value *
                      10 *
                      ((_shakeController.value * 4).floor() % 2 == 0 ? 1 : -1),
                  0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_pinLength, (index) {
                    final currentPinToShow =
                        _isConfirmingPin ? _confirmPin : _currentPin;
                    final isActive = index < currentPinToShow.length;

                    return Container(
                      width: 8.w,
                      height: 8.w,
                      margin: EdgeInsets.symmetric(horizontal: 1.w),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppTheme.accentColor
                            : (isDark
                                ? AppTheme.surfaceDark.withValues(alpha: 0.5)
                                : AppTheme.surfaceLight.withValues(alpha: 0.8)),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isActive
                              ? AppTheme.accentColor
                              : (isDark
                                  ? AppTheme.dividerDark.withValues(alpha: 0.3)
                                  : AppTheme.dividerLight
                                      .withValues(alpha: 0.3)),
                          width: 2,
                        ),
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color: AppTheme.accentColor
                                      .withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),
                      child: isActive
                          ? Center(
                              child: Container(
                                width: 3.w,
                                height: 3.w,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppTheme.primaryLight
                                      : AppTheme.surfaceLight,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            )
                          : null,
                    );
                  }),
                ),
              );
            },
          ),

          // Error Message
          if (_errorMessage != null) ...[
            SizedBox(height: 2.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.errorColor.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'error',
                    color: AppTheme.errorColor,
                    size: 4.w,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.errorColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          SizedBox(height: 4.h),

          // Loading Indicator
          if (_isCreating) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 5.w,
                  height: 5.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.accentColor,
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Text(
                  'PIN wordt aangemaakt...',
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppTheme.textSecondaryDark
                        : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),
          ],

          // Number Pad
          Expanded(
            child: _buildNumberPad(isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberPad(bool isDark) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.2,
      mainAxisSpacing: 2.h,
      crossAxisSpacing: 4.w,
      children: [
        // Numbers 1-9
        ...List.generate(9, (index) {
          final number = (index + 1).toString();
          return _buildNumberButton(number, isDark);
        }),

        // Empty space
        const SizedBox.shrink(),

        // Number 0
        _buildNumberButton('0', isDark),

        // Delete button
        _buildDeleteButton(isDark),
      ],
    );
  }

  Widget _buildNumberButton(String number, bool isDark) {
    return GestureDetector(
      onTap: _isCreating ? null : () => _onNumberPressed(number),
      child: Container(
        decoration: BoxDecoration(
          color: isDark
              ? AppTheme.surfaceDark.withValues(alpha: 0.8)
              : AppTheme.surfaceLight.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: isDark
                ? AppTheme.dividerDark.withValues(alpha: 0.3)
                : AppTheme.dividerLight.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? AppTheme.shadowDark.withValues(alpha: 0.1)
                  : AppTheme.shadowLight.withValues(alpha: 0.1),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Center(
          child: Text(
            number,
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton(bool isDark) {
    return GestureDetector(
      onTap: _isCreating ? null : _onDeletePressed,
      child: Container(
        decoration: BoxDecoration(
          color: isDark
              ? AppTheme.surfaceDark.withValues(alpha: 0.8)
              : AppTheme.surfaceLight.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: isDark
                ? AppTheme.dividerDark.withValues(alpha: 0.3)
                : AppTheme.dividerLight.withValues(alpha: 0.3),
          ),
        ),
        child: Center(
          child: CustomIconWidget(
            iconName: 'backspace',
            color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
            size: 6.w,
          ),
        ),
      ),
    );
  }
}
