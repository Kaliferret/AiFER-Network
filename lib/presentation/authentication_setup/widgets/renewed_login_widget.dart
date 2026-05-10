import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../services/renewed_auth_service.dart';

class RenewedLoginWidget extends StatefulWidget {
  final Function(AuthResult) onLoginResult;
  final bool showQuickLogin;
  final bool showBiometric;

  const RenewedLoginWidget({
    super.key,
    required this.onLoginResult,
    this.showQuickLogin = true,
    this.showBiometric = true,
  });

  @override
  State<RenewedLoginWidget> createState() => _RenewedLoginWidgetState();
}

class _RenewedLoginWidgetState extends State<RenewedLoginWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final _aiferidController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _aiferidFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _isLoading = false;
  bool _obscurePassword = true;
  AuthMethod _selectedMethod = AuthMethod.aiferid;
  String? _errorMessage;
  Map<String, dynamic> _authStats = {};

  final _renewedAuthService = RenewedAuthService.instance;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadAuthStats();
  }

  void _initializeAnimations() {
    _tabController = TabController(length: 2, vsync: this);

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  Future<void> _loadAuthStats() async {
    try {
      final stats = await _renewedAuthService.getAuthStats();
      if (mounted) {
        setState(() {
          _authStats = stats;
        });
      }
    } catch (e) {
      debugPrint('❌ Failed to load auth stats: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _aiferidController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _aiferidFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      AuthResult result;

      switch (_selectedMethod) {
        case AuthMethod.aiferid:
          result = await _renewedAuthService.login(
            aiFERiD: _aiferidController.text.trim(),
            method: AuthMethod.aiferid,
          );
          break;
        case AuthMethod.email:
          result = await _renewedAuthService.login(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            method: AuthMethod.email,
          );
          break;
        case AuthMethod.biometric:
          result = await _renewedAuthService.login(
            biometricData: 'biometric_placeholder',
            method: AuthMethod.biometric,
          );
          break;
        case AuthMethod.quickLogin:
          result = await _renewedAuthService.login(
            method: AuthMethod.quickLogin,
          );
          break;
      }

      if (mounted) {
        widget.onLoginResult(result);

        if (result.success) {
          HapticFeedback.mediumImpact();
        } else {
          HapticFeedback.heavyImpact();
          setState(() {
            _errorMessage = result.error;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Login failed: ${e.toString()}';
        });
        HapticFeedback.heavyImpact();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleQuickLogin() async {
    setState(() {
      _selectedMethod = AuthMethod.quickLogin;
    });
    await _handleLogin();
  }

  Future<void> _handleBiometricLogin() async {
    setState(() {
      _selectedMethod = AuthMethod.biometric;
    });
    await _handleLogin();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          width: 90.w,
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.accentColor.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.accentColor.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(isDark),
              SizedBox(height: 4.h),
              _buildQuickLoginOptions(isDark),
              SizedBox(height: 4.h),
              _buildTabBar(isDark),
              SizedBox(height: 3.h),
              _buildLoginForms(isDark),
              if (_errorMessage != null) ...[
                SizedBox(height: 2.h),
                _buildErrorMessage(isDark),
              ],
              SizedBox(height: 4.h),
              _buildLoginButton(isDark),
              SizedBox(height: 2.h),
              _buildAuthStats(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(3.w),
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
            iconName: 'login',
            color: AppTheme.primaryLight,
            size: 24,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          'Welcome Back',
          style: GoogleFonts.inter(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          'Sign in to your FERNetwork account',
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickLoginOptions(bool isDark) {
    if (!widget.showQuickLogin && !widget.showBiometric) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        if (widget.showQuickLogin && _authStats['quick_login_enabled'] == true)
          Expanded(
            child: _buildQuickButton(
              icon: 'flash_on',
              label: 'Quick Login',
              onPressed: _handleQuickLogin,
              isDark: isDark,
            ),
          ),
        if (widget.showQuickLogin &&
            widget.showBiometric &&
            _authStats['quick_login_enabled'] == true &&
            _authStats['biometric_enabled'] == true)
          SizedBox(width: 4.w),
        if (widget.showBiometric && _authStats['biometric_enabled'] == true)
          Expanded(
            child: _buildQuickButton(
              icon: 'fingerprint',
              label: 'Biometric',
              onPressed: _handleBiometricLogin,
              isDark: isDark,
            ),
          ),
      ],
    );
  }

  Widget _buildQuickButton({
    required String icon,
    required String label,
    required VoidCallback onPressed,
    required bool isDark,
  }) {
    return OutlinedButton(
      onPressed: _isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 2.h),
        side: BorderSide(
          color: AppTheme.accentColor.withValues(alpha: 0.3),
          width: 1,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: icon,
            color: AppTheme.accentColor,
            size: 16,
          ),
          SizedBox(width: 2.w),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: AppTheme.accentColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color:
            isDark
                ? AppTheme.backgroundDark.withValues(alpha: 0.5)
                : AppTheme.backgroundLight.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.accentColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: TabBar(
        controller: _tabController,
        onTap: (index) {
          setState(() {
            _selectedMethod =
                index == 0 ? AuthMethod.aiferid : AuthMethod.email;
            _errorMessage = null;
          });
          HapticFeedback.selectionClick();
        },
        indicator: BoxDecoration(
          color: AppTheme.accentColor.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: AppTheme.accentColor,
        unselectedLabelColor:
            isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
        labelStyle: GoogleFonts.inter(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
        ),
        tabs: const [Tab(text: 'AiFERiD'), Tab(text: 'Email')],
      ),
    );
  }

  Widget _buildLoginForms(bool isDark) {
    return SizedBox(
      height: 20.h,
      child: TabBarView(
        controller: _tabController,
        children: [_buildAiFERiDForm(isDark), _buildEmailForm(isDark)],
      ),
    );
  }

  Widget _buildAiFERiDForm(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'AiFERiD Address',
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: _aiferidController,
          focusNode: _aiferidFocusNode,
          decoration: InputDecoration(
            hintText: 'FER0x...',
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'account_balance_wallet',
                color: AppTheme.accentColor,
                size: 16,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.accentColor.withValues(alpha: 0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.accentColor.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.accentColor, width: 2),
            ),
            filled: true,
            fillColor:
                isDark
                    ? AppTheme.backgroundDark.withValues(alpha: 0.5)
                    : AppTheme.backgroundLight.withValues(alpha: 0.5),
          ),
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
          ),
          onFieldSubmitted: (_) => _handleLogin(),
        ),
        SizedBox(height: 2.h),
        Text(
          'Enter your blockchain wallet address to authenticate',
          style: GoogleFonts.inter(
            fontSize: 10.sp,
            color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailForm(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _emailController,
                focusNode: _emailFocusNode,
                decoration: InputDecoration(
                  hintText: 'Email',
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(3.w),
                    child: CustomIconWidget(
                      iconName: 'email',
                      color: AppTheme.accentColor,
                      size: 16,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppTheme.accentColor.withValues(alpha: 0.3),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppTheme.accentColor.withValues(alpha: 0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppTheme.accentColor,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor:
                      isDark
                          ? AppTheme.backgroundDark.withValues(alpha: 0.5)
                          : AppTheme.backgroundLight.withValues(alpha: 0.5),
                ),
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color:
                      isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
                ),
                keyboardType: TextInputType.emailAddress,
                onFieldSubmitted: (_) => _passwordFocusNode.requestFocus(),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: TextFormField(
                controller: _passwordController,
                focusNode: _passwordFocusNode,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: 'Password',
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(3.w),
                    child: CustomIconWidget(
                      iconName: 'lock',
                      color: AppTheme.accentColor,
                      size: 16,
                    ),
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    icon: CustomIconWidget(
                      iconName:
                          _obscurePassword ? 'visibility' : 'visibility_off',
                      color: AppTheme.accentColor,
                      size: 16,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppTheme.accentColor.withValues(alpha: 0.3),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppTheme.accentColor.withValues(alpha: 0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppTheme.accentColor,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor:
                      isDark
                          ? AppTheme.backgroundDark.withValues(alpha: 0.5)
                          : AppTheme.backgroundLight.withValues(alpha: 0.5),
                ),
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color:
                      isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
                ),
                onFieldSubmitted: (_) => _handleLogin(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildErrorMessage(bool isDark) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        children: [
          CustomIconWidget(iconName: 'error', color: Colors.red, size: 16),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              _errorMessage!,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.accentColor,
            AppTheme.accentColor.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentColor.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: AppTheme.primaryLight,
          padding: EdgeInsets.symmetric(vertical: 2.5.h),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child:
            _isLoading
                ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryLight,
                    ),
                  ),
                )
                : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconWidget(
                      iconName:
                          _selectedMethod == AuthMethod.aiferid
                              ? 'account_balance_wallet'
                              : 'login',
                      color: AppTheme.primaryLight,
                      size: 16,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Sign In',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryLight,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  Widget _buildAuthStats(bool isDark) {
    if (_authStats.isEmpty) return const SizedBox.shrink();

    final isLocked = _authStats['account_locked'] == true;
    final failedAttempts = _authStats['failed_attempts'] ?? 0;

    return Column(
      children: [
        if (isLocked)
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.orange.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'lock',
                  color: Colors.orange,
                  size: 14,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    'Account temporarily locked',
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      color: Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          )
        else if (failedAttempts > 0)
          Text(
            'Failed attempts: $failedAttempts/5',
            style: GoogleFonts.inter(fontSize: 10.sp, color: Colors.orange),
          ),
      ],
    );
  }
}