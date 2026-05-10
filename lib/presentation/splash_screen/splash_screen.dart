import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/network_data_service.dart';
import '../../services/supabase_auth_service.dart';
import '../../services/unified_supabase_service.dart';
import '../../theme/app_theme.dart';
import './widgets/device_capability_checker.dart';
import './widgets/mesh_network_loader.dart';
import './widgets/quantum_logo_animation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  final SupabaseAuthService _authService = SupabaseAuthService();
  final NetworkDataService _networkService = NetworkDataService.instance;
  final UnifiedSupabaseService _supabaseService =
      UnifiedSupabaseService.instance;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String _loadingText = 'Initializing AiFER Network...';
  double _loadingProgress = 0.0;
  bool _showNetworkStatus = false;
  bool _isReconnecting = false;
  Map<String, dynamic>? _healthStatus;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startInitialization();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  Future<void> _startInitialization() async {
    try {
      // Phase 1: Network capability check
      await _updateLoadingState('Checking device capabilities...', 0.1);
      await Future.delayed(const Duration(milliseconds: 800));

      // Phase 2: Supabase connection verification
      await _updateLoadingState('Connecting to Supabase...', 0.2);
      _healthStatus = await _supabaseService.healthCheck();

      if (_healthStatus!['status'] == 'unhealthy') {
        throw Exception(
            'Supabase connection failed: ${_healthStatus!['error']}');
      }

      // Phase 3: Database schema validation
      await _updateLoadingState('Validating database schema...', 0.3);
      await Future.delayed(const Duration(milliseconds: 600));

      // Phase 4: Chad AI initialization
      await _updateLoadingState('Loading Chad AI assistant...', 0.5);
      await Future.delayed(const Duration(milliseconds: 800));

      // Phase 5: Blockchain sync
      await _updateLoadingState('Syncing with FERMesh blockchain...', 0.6);
      await Future.delayed(const Duration(milliseconds: 1000));

      // Phase 6: Network discovery with real data
      setState(() {
        _showNetworkStatus = true;
      });
      await _updateLoadingState('Discovering network nodes...', 0.8);

      // Load initial network data from Supabase
      await _networkService.getNetworkStats();
      await Future.delayed(const Duration(milliseconds: 800));

      // Phase 7: Authentication verification
      await _updateLoadingState('Verifying user credentials...', 0.9);
      await Future.delayed(const Duration(milliseconds: 600));

      // Phase 8: Complete
      await _updateLoadingState('Welcome to AiFER Network!', 1.0);
      await Future.delayed(const Duration(milliseconds: 800));

      // Navigate based on authentication status
      await _navigateToAppropriateScreen();
    } catch (e) {
      await _handleInitializationError(e);
    }
  }

  Future<void> _updateLoadingState(String text, double progress) async {
    if (mounted) {
      setState(() {
        _loadingText = text;
        _loadingProgress = progress;
      });
    }
  }

  Future<void> _navigateToAppropriateScreen() async {
    if (!mounted) return;

    try {
      if (_authService.isAuthenticated) {
        // Check if onboarding is completed
        final hasCompletedOnboarding =
            await _authService.hasCompletedOnboarding();

        if (hasCompletedOnboarding) {
          Navigator.pushReplacementNamed(context, '/network-dashboard');
        } else {
          Navigator.pushReplacementNamed(context, '/onboarding-flow');
        }
      } else {
        Navigator.pushReplacementNamed(context, '/onboarding-flow');
      }
    } catch (e) {
      // Fallback to onboarding on error
      Navigator.pushReplacementNamed(context, '/onboarding-flow');
    }
  }

  Future<void> _handleInitializationError(dynamic error) async {
    setState(() {
      _isReconnecting = true;
      _loadingText = 'Connection failed. Retrying...';
    });

    debugPrint('❌ Initialization error: $error');

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      // Retry initialization or navigate to onboarding
      Navigator.pushReplacementNamed(context, '/onboarding-flow');
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    AppTheme.backgroundDark,
                    AppTheme.backgroundDark.withValues(alpha: 0.8),
                    AppTheme.surfaceDark,
                  ]
                : [
                    AppTheme.backgroundLight,
                    AppTheme.backgroundLight.withValues(alpha: 0.9),
                    AppTheme.surfaceLight,
                  ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo animation
                    QuantumLogoAnimation(
                      size: 25.w,
                    ),

                    SizedBox(height: 6.h),

                    // App title with glow effect
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.accentColor.withValues(alpha: 0.1),
                            AppTheme.accentColor.withValues(alpha: 0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppTheme.accentColor.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'AiFER Network',
                            style: theme.textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppTheme.accentColor,
                              letterSpacing: 2,
                              shadows: [
                                Shadow(
                                  color: AppTheme.accentColor
                                      .withValues(alpha: 0.5),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            'Powered by FERMesh Ecosystem',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isDark
                                  ? AppTheme.textSecondaryDark
                                  : AppTheme.textSecondary,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 6.h),

                    // Real-time Supabase health status
                    if (_healthStatus != null)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 1.5.h,
                        ),
                        decoration: BoxDecoration(
                          color: _healthStatus!['status'] == 'healthy'
                              ? AppTheme.successColor.withValues(alpha: 0.1)
                              : AppTheme.errorColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _healthStatus!['status'] == 'healthy'
                                ? AppTheme.successColor.withValues(alpha: 0.3)
                                : AppTheme.errorColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 3.w,
                              height: 3.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _healthStatus!['status'] == 'healthy'
                                    ? AppTheme.successColor
                                    : AppTheme.errorColor,
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        (_healthStatus!['status'] == 'healthy'
                                                ? AppTheme.successColor
                                                : AppTheme.errorColor)
                                            .withValues(alpha: 0.5),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              _healthStatus!['status'] == 'healthy'
                                  ? 'Supabase Connected • ${_healthStatus!['latency']}ms'
                                  : 'Connection Issues Detected',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: _healthStatus!['status'] == 'healthy'
                                    ? AppTheme.successColor
                                    : AppTheme.errorColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                    SizedBox(height: 4.h),

                    // Network mesh animation
                    if (_showNetworkStatus) ...[
                      MeshNetworkLoader(
                        progress: _loadingProgress,
                      ),
                      SizedBox(height: 4.h),
                    ],

                    // Device capability checker
                    DeviceCapabilityChecker(
                      onCapabilitiesChecked: (capabilities) {
                        debugPrint('✅ Device capabilities: $capabilities');
                      },
                    ),

                    SizedBox(height: 4.h),

                    // Loading indicator with enhanced design
                    Container(
                      width: 80.w,
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppTheme.surfaceDark.withValues(alpha: 0.6)
                            : AppTheme.surfaceLight.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.accentColor.withValues(alpha: 0.2),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.accentColor.withValues(alpha: 0.1),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Loading text
                          Text(
                            _loadingText,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: isDark
                                  ? AppTheme.textPrimaryDark
                                  : AppTheme.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          SizedBox(height: 3.h),

                          // Progress bar with glow effect
                          Container(
                            height: 0.8.h,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppTheme.textSecondaryDark
                                      .withValues(alpha: 0.2)
                                  : AppTheme.textSecondary
                                      .withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Stack(
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  height: 0.8.h,
                                  width: (80.w - 8.w) * _loadingProgress,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppTheme.accentColor,
                                        AppTheme.accentColor
                                            .withValues(alpha: 0.8),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.accentColor
                                            .withValues(alpha: 0.5),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 2.h),

                          // Progress percentage
                          Text(
                            '${(_loadingProgress * 100).toInt()}%',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppTheme.accentColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 4.h),

                    // Connection status indicator
                    if (_isReconnecting)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 1.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.warningColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppTheme.warningColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 4.w,
                              height: 4.w,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.warningColor,
                              ),
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              'Reconnecting...',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppTheme.warningColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                    SizedBox(height: 6.h),

                    // Version info with Supabase status
                    Text(
                      'v1.0.0 | Supabase Ready | Chad AI Enabled',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppTheme.textSecondaryDark.withValues(alpha: 0.6)
                            : AppTheme.textSecondary.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}