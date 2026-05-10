import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/renewed_auth_service.dart';
import './widgets/login_method_selector_widget.dart';
import './widgets/renewed_login_widget.dart';

class AuthenticationSetup extends StatefulWidget {
  const AuthenticationSetup({super.key});

  @override
  State<AuthenticationSetup> createState() => _AuthenticationSetupState();
}

class _AuthenticationSetupState extends State<AuthenticationSetup>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final _renewedAuthService = RenewedAuthService.instance;

  bool _isLoading = true;
  bool _showLoginForm = false;
  AuthMethod? _selectedMethod;
  Map<String, dynamic> _authStats = {};
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeAuthService();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  Future<void> _initializeAuthService() async {
    try {
      await _renewedAuthService.initialize();

      // Check if user is already authenticated
      final isAuthenticated = await _renewedAuthService.isAuthenticated();
      if (isAuthenticated) {
        _navigateToMainApp();
        return;
      }

      // Load authentication statistics
      final stats = await _renewedAuthService.getAuthStats();

      if (mounted) {
        setState(() {
          _authStats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Failed to initialize auth service: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to initialize authentication service';
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _handleMethodSelected(AuthMethod method) {
    setState(() {
      _selectedMethod = method;
      _showLoginForm = true;
      _errorMessage = null;
    });

    // Show login form with animation
    _slideController.reset();
    _slideController.forward();
  }

  void _handleLoginResult(AuthResult result) {
    if (result.success) {
      HapticFeedback.mediumImpact();
      _navigateToMainApp();
    } else {
      HapticFeedback.vibrate();
      setState(() {
        _errorMessage = result.error;
      });
    }
  }

  void _navigateToMainApp() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.networkDashboard,
      (route) => false,
    );
  }

  void _goBack() {
    setState(() {
      _showLoginForm = false;
      _selectedMethod = null;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            width: 100.w,
            height: 100.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
                  isDark
                      ? AppTheme.backgroundDark.withValues(alpha: 0.8)
                      : AppTheme.backgroundLight.withValues(alpha: 0.8),
                  AppTheme.accentColor.withValues(alpha: 0.05),
                ],
              ),
            ),
            child:
                _isLoading
                    ? _buildLoadingView(isDark)
                    : SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        children: [
                          _buildHeader(isDark),
                          Expanded(
                            child: SingleChildScrollView(
                              padding: EdgeInsets.symmetric(horizontal: 5.w),
                              child: Column(
                                children: [
                                  SizedBox(height: 4.h),
                                  if (_errorMessage != null) ...[
                                    _buildErrorBanner(isDark),
                                    SizedBox(height: 3.h),
                                  ],
                                  if (!_showLoginForm)
                                    LoginMethodSelectorWidget(
                                      onMethodSelected: _handleMethodSelected,
                                      selectedMethod: _selectedMethod,
                                      authStats: _authStats,
                                    )
                                  else
                                    RenewedLoginWidget(
                                      onLoginResult: _handleLoginResult,
                                      showQuickLogin:
                                          _authStats['quick_login_enabled'] ==
                                          true,
                                      showBiometric:
                                          _authStats['biometric_enabled'] ==
                                          true,
                                    ),
                                  SizedBox(height: 4.h),
                                  _buildFooter(isDark),
                                  SizedBox(height: 2.h),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingView(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(seconds: 2),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.8 + (0.2 * value),
                child: Container(
                  padding: EdgeInsets.all(4.w),
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
                    size: 32,
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 4.h),
          CircularProgressIndicator(
            color: AppTheme.accentColor,
            strokeWidth: 3,
          ),
          SizedBox(height: 3.h),
          Text(
            'Initializing Authentication...',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      width: 100.w,
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
      child: Row(
        children: [
          if (_showLoginForm)
            GestureDetector(
              onTap: _goBack,
              child: Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppTheme.accentColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: CustomIconWidget(
                  iconName: 'arrow_back',
                  color: AppTheme.accentColor,
                  size: 16,
                ),
              ),
            ),
          if (_showLoginForm) SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FERNetwork',
                  style: GoogleFonts.inter(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color:
                        isDark
                            ? AppTheme.textPrimaryDark
                            : AppTheme.textPrimary,
                  ),
                ),
                Text(
                  _showLoginForm ? 'Sign In' : 'Authentication Setup',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
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

  Widget _buildErrorBanner(bool isDark) {
    return Container(
      width: 90.w,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        children: [
          CustomIconWidget(iconName: 'error', color: Colors.red, size: 20),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Authentication Error',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),
                Text(
                  _errorMessage!,
                  style: GoogleFonts.inter(fontSize: 10.sp, color: Colors.red),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _errorMessage = null;
              });
            },
            child: CustomIconWidget(
              iconName: 'close',
              color: Colors.red,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(bool isDark) {
    return Column(
      children: [
        Container(
          width: 80.w,
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: AppTheme.accentColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.accentColor.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: 'info',
                    color: AppTheme.accentColor,
                    size: 14,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Secure Authentication',
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.accentColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.h),
              Text(
                'Your credentials are protected with blockchain technology and end-to-end encryption.',
                style: GoogleFonts.inter(
                  fontSize: 9.sp,
                  color:
                      isDark
                          ? AppTheme.textSecondaryDark
                          : AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        SizedBox(height: 2.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'shield',
              color: AppTheme.accentColor.withValues(alpha: 0.7),
              size: 12,
            ),
            SizedBox(width: 2.w),
            Text(
              'Powered by FERChain Security',
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
      ],
    );
  }
}