import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../onboarding_flow.dart';

class ModernOnboardingPageWidget extends StatelessWidget {
  final ModernOnboardingPageData pageData;
  final Widget animationWidget;
  final bool isLastPage;
  final String? connectionStatus;
  final bool isConnecting;
  final VoidCallback onComplete;
  final VoidCallback onSkipSetup;
  final Animation<double> parallaxAnimation;

  const ModernOnboardingPageWidget({
    super.key,
    required this.pageData,
    required this.animationWidget,
    required this.isLastPage,
    this.connectionStatus,
    required this.isConnecting,
    required this.onComplete,
    required this.onSkipSetup,
    required this.parallaxAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100.w,
      height: 100.h,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        children: [
          // Quantum category badge with glow effect
          _buildQuantumCategoryBadge(),

          SizedBox(height: 3.h),

          // Enhanced animation area with holographic border
          Expanded(
            flex: 5,
            child: _buildHolographicAnimationContainer(),
          ),

          SizedBox(height: 2.h),

          // Modern content area with enhanced typography
          Expanded(
            flex: 4,
            child: _buildContentArea(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantumCategoryBadge() {
    return AnimatedBuilder(
      animation: parallaxAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - parallaxAnimation.value) * -20),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  pageData.primaryColor.withValues(alpha: 0.2),
                  pageData.primaryColor.withValues(alpha: 0.05),
                ],
              ),
              border: Border.all(
                color: pageData.primaryColor.withValues(alpha: 0.4),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: pageData.primaryColor.withValues(alpha: 0.3),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        pageData.primaryColor,
                        pageData.primaryColor.withValues(alpha: 0.6),
                      ],
                    ),
                  ),
                  child: CustomIconWidget(
                    iconName: _getCategoryIcon(),
                    color: Colors.black,
                    size: 16,
                  ),
                ),
                SizedBox(width: 3.w),
                Text(
                  pageData.category.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: pageData.primaryColor,
                    letterSpacing: 2.0,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHolographicAnimationContainer() {
    return AnimatedBuilder(
      animation: parallaxAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - parallaxAnimation.value) * 30),
          child: Container(
            width: 100.w,
            margin: EdgeInsets.symmetric(horizontal: 2.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.2,
                colors: [
                  pageData.primaryColor.withValues(alpha: 0.1),
                  pageData.primaryColor.withValues(alpha: 0.05),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
              border: Border.all(
                color: pageData.primaryColor.withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: pageData.primaryColor.withValues(alpha: 0.2),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Container(
              margin: EdgeInsets.all(1.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.black.withValues(alpha: 0.8),
                    Colors.black.withValues(alpha: 0.4),
                  ],
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: animationWidget,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContentArea() {
    return AnimatedBuilder(
      animation: parallaxAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - parallaxAnimation.value) * 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Subtitle with quantum glow
              Text(
                pageData.subtitle,
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: pageData.primaryColor.withValues(alpha: 0.8),
                  letterSpacing: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 1.h),

              // Main title with enhanced typography
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [
                    pageData.primaryColor,
                    pageData.primaryColor.withValues(alpha: 0.7),
                  ],
                ).createShader(bounds),
                child: Text(
                  pageData.title,
                  style: GoogleFonts.inter(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -1.0,
                    height: 1.1,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              SizedBox(height: 3.h),

              // Description with improved readability
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Text(
                  pageData.description,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withValues(alpha: 0.8),
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              SizedBox(height: 4.h),

              // Enhanced feature highlights with quantum styling
              _buildQuantumFeatures(),

              SizedBox(height: 4.h),

              // Setup options for last page
              if (isLastPage) _buildQuantumSetupOptions(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuantumFeatures() {
    return Wrap(
      spacing: 3.w,
      runSpacing: 1.5.h,
      alignment: WrapAlignment.center,
      children: pageData.features.asMap().entries.map((entry) {
        final index = entry.key;
        final feature = entry.value;

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 600 + (index * 200)),
          curve: Curves.easeOutBack,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      pageData.primaryColor.withValues(alpha: 0.2),
                      pageData.primaryColor.withValues(alpha: 0.1),
                    ],
                  ),
                  border: Border.all(
                    color: pageData.primaryColor.withValues(alpha: 0.4),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: pageData.primaryColor.withValues(alpha: 0.2),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            pageData.primaryColor,
                            pageData.primaryColor.withValues(alpha: 0.6),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: pageData.primaryColor.withValues(alpha: 0.6),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      feature,
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: pageData.primaryColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildQuantumSetupOptions() {
    return Column(
      children: [
        // Primary setup button with quantum effects
        _buildQuantumSetupButton(
          onTap: onComplete,
          label: _getPrimaryButtonLabel(),
          icon: _getPrimaryButtonIcon(),
          isPrimary: true,
        ),

        SizedBox(height: 2.h),

        // Secondary offline option
        _buildQuantumSetupButton(
          onTap: onSkipSetup,
          label: 'Use Offline Mode',
          icon: 'offline_bolt',
          isPrimary: false,
        ),

        SizedBox(height: 2.h),

        // Connection status indicator
        if (connectionStatus != null) _buildConnectionStatusIndicator(),
      ],
    );
  }

  Widget _buildQuantumSetupButton({
    required VoidCallback onTap,
    required String label,
    required String icon,
    required bool isPrimary,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 85.w,
        height: isPrimary ? 7.h : 6.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: isPrimary
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: pageData.gradientColors,
                )
              : null,
          border: Border.all(
            color: isPrimary
                ? Colors.transparent
                : pageData.primaryColor.withValues(alpha: 0.4),
            width: 1.5,
          ),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: pageData.primaryColor.withValues(alpha: 0.4),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(25),
            onTap: onTap,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isConnecting && isPrimary)
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isPrimary ? Colors.black : pageData.primaryColor,
                        ),
                      ),
                    )
                  else
                    CustomIconWidget(
                      iconName: icon,
                      color: isPrimary ? Colors.black : pageData.primaryColor,
                      size: 22,
                    ),
                  SizedBox(width: 3.w),
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: isPrimary ? 18.sp : 16.sp,
                      fontWeight: isPrimary ? FontWeight.w700 : FontWeight.w600,
                      color: isPrimary ? Colors.black : pageData.primaryColor,
                      letterSpacing: 0.5,
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

  Widget _buildConnectionStatusIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: _getConnectionStatusColor().withValues(alpha: 0.1),
        border: Border.all(
          color: _getConnectionStatusColor().withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _getConnectionStatusColor(),
              boxShadow: [
                BoxShadow(
                  color: _getConnectionStatusColor().withValues(alpha: 0.6),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          SizedBox(width: 2.w),
          Text(
            _getConnectionStatusText(),
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: _getConnectionStatusColor(),
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryIcon() {
    switch (pageData.category) {
      case 'network':
        return 'hub';
      case 'security':
        return 'security';
      case 'connectivity':
        return 'router';
      case 'privacy':
        return 'shield';
      case 'setup':
        return 'rocket_launch';
      default:
        return 'circle';
    }
  }

  String _getPrimaryButtonLabel() {
    if (isConnecting) return 'Connecting...';

    switch (connectionStatus) {
      case 'connected':
        return 'Launch Neural Network';
      case 'ready_to_connect':
        return 'Initialize Quantum Setup';
      case 'connection_failed':
        return 'Start Offline Mode';
      default:
        return 'Begin Experience';
    }
  }

  String _getPrimaryButtonIcon() {
    if (isConnecting) return 'sync';

    switch (connectionStatus) {
      case 'connected':
        return 'rocket_launch';
      case 'ready_to_connect':
        return 'auto_awesome';
      case 'connection_failed':
        return 'offline_bolt';
      default:
        return 'play_arrow';
    }
  }

  Color _getConnectionStatusColor() {
    switch (connectionStatus) {
      case 'connected':
        return const Color(0xFF00FF88); // Quantum green
      case 'ready_to_connect':
        return pageData.primaryColor;
      case 'connection_failed':
        return const Color(0xFFFFAA00); // Quantum amber
      default:
        return Colors.white.withValues(alpha: 0.6);
    }
  }

  String _getConnectionStatusText() {
    if (isConnecting) return 'Initializing quantum connection...';

    switch (connectionStatus) {
      case 'connected':
        return 'Neural network synchronized';
      case 'ready_to_connect':
        return 'Quantum bridge ready';
      case 'connection_failed':
        return 'Offline mesh available';
      default:
        return 'Checking quantum status...';
    }
  }
}
