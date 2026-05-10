import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../core/app_export.dart';
import '../../services/enhanced_supabase_service.dart';
import './widgets/cloud_sync_pulse_animation_widget.dart';
import './widgets/holographic_connectivity_animation_widget.dart';
import './widgets/modern_onboarding_page_widget.dart';
import './widgets/neural_mesh_animation_widget.dart';
import './widgets/privacy_shield_animation_widget.dart';
import './widgets/quantum_security_animation_widget.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _globalAnimationController;
  late AnimationController _parallaxController;
  late AnimationController _particleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _parallaxAnimation;

  int _currentPage = 0;
  final int _totalPages = 5;
  bool _isConnectingToSupabase = false;
  String? _connectionStatus;
  bool _showParticleEffect = true;

  final List<ModernOnboardingPageData> _pages = [
    ModernOnboardingPageData(
      title: 'FER Neural Network',
      subtitle: 'Quantum Mesh Communications',
      description:
          'Experience true peer-to-peer connectivity with our revolutionary neural mesh network. Every device becomes a quantum node in the decentralized future.',
      animationAsset: 'neural_mesh',
      features: ['Quantum Mesh', 'Neural Routing', 'Zero-Trust Architecture'],
      category: 'network',
      primaryColor: const Color(0xFF00F5FF), // Cyan quantum
      gradientColors: [
        const Color(0xFF00F5FF),
        const Color(0xFF0080FF),
      ],
    ),
    ModernOnboardingPageData(
      title: 'Quantum Cryptography',
      subtitle: 'Unbreakable Security Layer',
      description:
          'Messages protected by quantum encryption and blockchain verification. .AiF packets self-destruct after reading, ensuring perfect forward secrecy.',
      animationAsset: 'quantum_security',
      features: [
        'Quantum Encryption',
        'Self-Destructing Messages',
        'Blockchain Verified'
      ],
      category: 'security',
      primaryColor: const Color(0xFF00FF88), // Emerald quantum
      gradientColors: [
        const Color(0xFF00FF88),
        const Color(0xFF00CC66),
      ],
    ),
    ModernOnboardingPageData(
      title: 'Holographic Connectivity',
      subtitle: 'Multi-Dimensional Routing',
      description:
          'AI-powered routing across all radio spectrums. 5G, WiFi, Bluetooth, and GPS harmonize to create the ultimate communication matrix.',
      animationAsset: 'holographic_connectivity',
      features: ['AI Routing Matrix', 'Spectrum Harmony', 'Adaptive Protocols'],
      category: 'connectivity',
      primaryColor: const Color(0xFFFF00FF), // Magenta holographic
      gradientColors: [
        const Color(0xFFFF00FF),
        const Color(0xFFCC00CC),
      ],
    ),
    ModernOnboardingPageData(
      title: 'Privacy Shield',
      subtitle: 'Anonymous & Untraceable',
      description:
          'Frequency-bouncing technology creates untraceable communication paths. .AiFp packets ensure complete anonymity in the mesh network.',
      animationAsset: 'privacy_shield',
      features: ['Frequency Bouncing', 'Anonymous Routing', 'Zero Metadata'],
      category: 'privacy',
      primaryColor: const Color(0xFFFFAA00), // Amber shield
      gradientColors: [
        const Color(0xFFFFAA00),
        const Color(0xFFFF8800),
      ],
    ),
    ModernOnboardingPageData(
      title: 'Cloud Synchronization',
      subtitle: 'Hybrid Mesh-Cloud Architecture',
      description:
          'Seamlessly bridge quantum mesh networking with cloud infrastructure. Sync your neural patterns across dimensions.',
      animationAsset: 'cloud_sync_pulse',
      features: ['Hybrid Architecture', 'Neural Sync', 'Dimensional Bridge'],
      category: 'setup',
      primaryColor: AppTheme.accentColor,
      gradientColors: [
        AppTheme.accentColor,
        AppTheme.successColor,
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _checkSupabaseConnection();
    _startParticleAnimation();
  }

  void _initializeControllers() {
    _pageController = PageController();

    // Global animation controller
    _globalAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Parallax effect controller
    _parallaxController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Particle effect controller
    _particleController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );

    // Animations
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _globalAnimationController,
      curve: Curves.easeOutExpo,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _globalAnimationController,
      curve: Curves.elasticOut,
    ));

    _parallaxAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _parallaxController,
      curve: Curves.easeOutCubic,
    ));

    // Start animations
    _globalAnimationController.forward();
    _parallaxController.forward();
  }

  void _startParticleAnimation() {
    _particleController.repeat();
  }

  Future<void> _checkSupabaseConnection() async {
    setState(() {
      _isConnectingToSupabase = true;
      _connectionStatus = null;
    });

    try {
      final service = EnhancedSupabaseService.instance;

      // Perform comprehensive health check
      final healthStatus = await service.checkConnectionHealth();
      final isAuthenticated = service.isAuthenticated;

      setState(() {
        if (healthStatus['status'] == 'healthy') {
          _connectionStatus =
              isAuthenticated ? 'connected' : 'ready_to_connect';
        } else {
          _connectionStatus = 'connection_failed';
        }
        _isConnectingToSupabase = false;
      });

      debugPrint('✅ Supabase health check: ${healthStatus}');
    } catch (e) {
      setState(() {
        _connectionStatus = 'connection_failed';
        _isConnectingToSupabase = false;
      });
      debugPrint('❌ Supabase connection check failed: $e');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _globalAnimationController.dispose();
    _parallaxController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });

    // Restart animations for new page
    _parallaxController.reset();
    _parallaxController.forward();

    // Advanced haptic feedback
    HapticFeedback.selectionClick();

    // Additional light impact for modern feel
    Future.delayed(const Duration(milliseconds: 100), () {
      HapticFeedback.lightImpact();
    });
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutExpo,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.animateToPage(
        _currentPage - 1,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutExpo,
      );
    }
  }

  void _skipOnboarding() {
    HapticFeedback.mediumImpact();
    _completeOnboarding(skipSetup: true);
  }

  void _completeOnboarding({bool skipSetup = false}) {
    // Enhanced haptic feedback sequence
    HapticFeedback.mediumImpact();
    Future.delayed(const Duration(milliseconds: 50), () {
      HapticFeedback.lightImpact();
    });

    // Navigate based on connection and preference
    if (skipSetup || _connectionStatus == 'connection_failed') {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/offline-authentication',
        (route) => false,
      );
    } else {
      // Phase 5: primary flow is the AiFERiD login screen.
      // The old `/authentication-setup` selector is kept as a secondary
      // entry point but no longer on the onboarding path.
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/aiferid-login',
        (route) => false,
      );
    }
  }

  Widget _getAnimationWidget(String animationAsset) {
    switch (animationAsset) {
      case 'neural_mesh':
        return NeuralMeshAnimationWidget(
          controller: _particleController,
          color: _pages[_currentPage].primaryColor,
        );
      case 'quantum_security':
        return QuantumSecurityAnimationWidget(
          controller: _particleController,
          color: _pages[_currentPage].primaryColor,
        );
      case 'holographic_connectivity':
        return HolographicConnectivityAnimationWidget(
          controller: _particleController,
          color: _pages[_currentPage].primaryColor,
        );
      case 'privacy_shield':
        return PrivacyShieldAnimationWidget(
          controller: _particleController,
          color: _pages[_currentPage].primaryColor,
        );
      case 'cloud_sync_pulse':
        return CloudSyncPulseAnimationWidget(
          controller: _particleController,
          color: _pages[_currentPage].primaryColor,
          connectionStatus: _connectionStatus,
          isConnecting: _isConnectingToSupabase,
        );
      default:
        return NeuralMeshAnimationWidget(
          controller: _particleController,
          color: _pages[_currentPage].primaryColor,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentPageData = _pages[_currentPage];

    return Scaffold(
      backgroundColor: Colors.black, // Pure black for quantum feel
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.5,
            colors: [
              currentPageData.primaryColor.withValues(alpha: 0.1),
              Colors.black.withValues(alpha: 0.95),
              Colors.black,
            ],
            stops: const [0.0, 0.3, 1.0],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: Column(
                    children: [
                      // Modern header with quantum styling
                      _buildQuantumHeader(isDark),

                      // Main content with parallax effect
                      Expanded(
                        child: AnimatedBuilder(
                          animation: _parallaxAnimation,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(
                                0,
                                (1 - _parallaxAnimation.value) * 50,
                              ),
                              child: PageView.builder(
                                controller: _pageController,
                                onPageChanged: _onPageChanged,
                                itemCount: _totalPages,
                                itemBuilder: (context, index) {
                                  final page = _pages[index];
                                  return ModernOnboardingPageWidget(
                                    pageData: page,
                                    animationWidget: _getAnimationWidget(
                                        page.animationAsset),
                                    isLastPage: index == _totalPages - 1,
                                    connectionStatus: _connectionStatus,
                                    isConnecting: _isConnectingToSupabase,
                                    onComplete: _completeOnboarding,
                                    onSkipSetup: () =>
                                        _completeOnboarding(skipSetup: true),
                                    parallaxAnimation: _parallaxAnimation,
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),

                      // Modern bottom navigation
                      _buildQuantumBottomNavigation(isDark),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildQuantumHeader(bool isDark) {
    final currentPageData = _pages[_currentPage];

    return Container(
      width: 100.w,
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Quantum logo with glow effect
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  currentPageData.primaryColor.withValues(alpha: 0.3),
                  Colors.transparent,
                ],
              ),
              border: Border.all(
                color: currentPageData.primaryColor.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: CustomIconWidget(
              iconName: 'hub',
              color: currentPageData.primaryColor,
              size: 24,
            ),
          ),

          // Progress indicator with quantum dots
          Row(
            children: List.generate(_totalPages, (index) {
              final isActive = index <= _currentPage;
              final isCurrent = index == _currentPage;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                margin: EdgeInsets.symmetric(horizontal: 0.5.w),
                width: isCurrent ? 8.w : 2.w,
                height: 0.8.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: isActive
                      ? LinearGradient(
                          colors: [
                            currentPageData.primaryColor,
                            currentPageData.primaryColor.withValues(alpha: 0.6),
                          ],
                        )
                      : null,
                  color: isActive
                      ? null
                      : currentPageData.primaryColor.withValues(alpha: 0.2),
                  boxShadow: isCurrent
                      ? [
                          BoxShadow(
                            color: currentPageData.primaryColor
                                .withValues(alpha: 0.5),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
              );
            }),
          ),

          // Skip button with quantum styling
          GestureDetector(
            onTap: _skipOnboarding,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: currentPageData.primaryColor.withValues(alpha: 0.3),
                  width: 1,
                ),
                gradient: LinearGradient(
                  colors: [
                    currentPageData.primaryColor.withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Text(
                'Skip',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: currentPageData.primaryColor,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantumBottomNavigation(bool isDark) {
    final currentPageData = _pages[_currentPage];
    final isLastPage = _currentPage == _totalPages - 1;

    return Container(
      width: 100.w,
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
      child: Column(
        children: [
          // Enhanced page indicator with quantum effects
          AnimatedBuilder(
            animation: _parallaxAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: 0.95 + (0.05 * _parallaxAnimation.value),
                child: SmoothPageIndicator(
                  controller: _pageController,
                  count: _totalPages,
                  effect: CustomizableEffect(
                    activeDotDecoration: DotDecoration(
                      width: 6.w,
                      height: 1.2.h,
                      color: currentPageData.primaryColor,
                      rotationAngle: 0,
                      verticalOffset: 0,
                      borderRadius: BorderRadius.circular(10),
                      dotBorder: DotBorder(
                        padding: 2,
                        width: 1,
                        color:
                            currentPageData.primaryColor.withValues(alpha: 0.5),
                      ),
                    ),
                    dotDecoration: DotDecoration(
                      width: 2.w,
                      height: 1.2.h,
                      color:
                          currentPageData.primaryColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    spacing: 2.w,
                  ),
                ),
              );
            },
          ),

          SizedBox(height: 4.h),

          // Navigation buttons with quantum styling
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back button
              if (_currentPage > 0)
                _buildQuantumButton(
                  onTap: _previousPage,
                  label: 'Back',
                  icon: 'arrow_back_ios',
                  isPrimary: false,
                  color: currentPageData.primaryColor,
                )
              else
                const SizedBox(width: 120), // Placeholder for alignment

              // Next/Complete button
              _buildQuantumButton(
                onTap: _nextPage,
                label: isLastPage ? 'Launch' : 'Next',
                icon: isLastPage ? 'rocket_launch' : 'arrow_forward_ios',
                isPrimary: true,
                color: currentPageData.primaryColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuantumButton({
    required VoidCallback onTap,
    required String label,
    required String icon,
    required bool isPrimary,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(
          horizontal: isPrimary ? 8.w : 6.w,
          vertical: 2.5.h,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: isPrimary
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color,
                    color.withValues(alpha: 0.8),
                  ],
                )
              : null,
          border: Border.all(
            color:
                isPrimary ? Colors.transparent : color.withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon == 'arrow_back_ios') ...[
              CustomIconWidget(
                iconName: icon,
                color: isPrimary ? Colors.black : color,
                size: 18,
              ),
              SizedBox(width: 2.w),
            ],
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: isPrimary ? FontWeight.w700 : FontWeight.w500,
                color: isPrimary ? Colors.black : color,
                letterSpacing: 0.5,
              ),
            ),
            if (icon != 'arrow_back_ios') ...[
              SizedBox(width: 2.w),
              CustomIconWidget(
                iconName: icon,
                color: isPrimary ? Colors.black : color,
                size: 18,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Enhanced data model for modern onboarding
class ModernOnboardingPageData {
  final String title;
  final String subtitle;
  final String description;
  final String animationAsset;
  final List<String> features;
  final String category;
  final Color primaryColor;
  final List<Color> gradientColors;

  ModernOnboardingPageData({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.animationAsset,
    required this.features,
    required this.category,
    required this.primaryColor,
    required this.gradientColors,
  });
}
