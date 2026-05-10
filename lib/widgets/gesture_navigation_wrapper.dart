import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../core/app_export.dart';
import '../routes/app_routes.dart';
import './navigation_service.dart';

class GestureNavigationWrapper extends StatefulWidget {
  final Widget child;
  final int currentIndex;
  final Function(int) onNavigate;

  const GestureNavigationWrapper({
    Key? key,
    required this.child,
    required this.currentIndex,
    required this.onNavigate,
  }) : super(key: key);

  @override
  State<GestureNavigationWrapper> createState() =>
      _GestureNavigationWrapperState();
}

class _GestureNavigationWrapperState extends State<GestureNavigationWrapper>
    with TickerProviderStateMixin {
  late AnimationController _swipeController;
  late AnimationController _edgeController;
  late Animation<double> _swipeAnimation;
  late Animation<double> _edgeAnimation;

  bool _isSwipeActive = false;
  bool _showEdgeIndicator = false;
  double _swipeDistance = 0.0;
  Offset _swipeStartPosition = Offset.zero;

  // Gesture thresholds
  final double _swipeThreshold = 30.w;
  final double _velocityThreshold = 1000.0;
  final double _edgeThreshold = 5.w;

  @override
  void initState() {
    super.initState();

    _swipeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _edgeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _swipeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _swipeController, curve: Curves.easeOut),
    );

    _edgeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _edgeController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _swipeController.dispose();
    _edgeController.dispose();
    super.dispose();
  }

  void _handleSwipeStart(DragStartDetails details) {
    _swipeStartPosition = details.globalPosition;

    // Check if starting from edge
    if (details.globalPosition.dx < _edgeThreshold ||
        details.globalPosition.dx >
            MediaQuery.of(context).size.width - _edgeThreshold) {
      setState(() {
        _showEdgeIndicator = true;
      });
      _edgeController.forward();
    }
  }

  void _handleSwipeUpdate(DragUpdateDetails details) {
    final currentPosition = details.globalPosition;
    final deltaX = currentPosition.dx - _swipeStartPosition.dx;
    final deltaY = currentPosition.dy - _swipeStartPosition.dy;

    // Only handle horizontal swipes
    if (deltaY.abs() > deltaX.abs() * 2) return;

    setState(() {
      _swipeDistance = deltaX;
      _isSwipeActive = deltaX.abs() > 10.w;
    });

    if (_isSwipeActive) {
      final progress = (deltaX.abs() / _swipeThreshold).clamp(0.0, 1.0);
      _swipeController.value = progress;

      // Haptic feedback at 50% progress
      if (progress > 0.5 && progress < 0.6) {
        HapticFeedback.selectionClick();
      }
    }
  }

  void _handleSwipeEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    final shouldTrigger = _swipeDistance.abs() > _swipeThreshold ||
        velocity.abs() > _velocityThreshold;

    if (_isSwipeActive && shouldTrigger) {
      _performNavigation(_swipeDistance > 0 ? 'right' : 'left');
      HapticFeedback.mediumImpact();
    }

    // Reset state
    setState(() {
      _isSwipeActive = false;
      _showEdgeIndicator = false;
      _swipeDistance = 0.0;
    });

    _swipeController.reset();
    _edgeController.reverse();
  }

  void _performNavigation(String direction) {
    final routes = [
      AppRoutes.networkDashboard,
      AppRoutes.messagingInterface,
      AppRoutes.blockchainWalletManager,
      AppRoutes.ferexplorer,
    ];

    int newIndex = widget.currentIndex;

    if (direction == 'right' && newIndex > 0) {
      newIndex--;
    } else if (direction == 'left' && newIndex < routes.length - 1) {
      newIndex++;
    } else {
      return; // No navigation needed
    }

    widget.onNavigate(newIndex);
    Navigator.pushReplacementNamed(context, routes[newIndex]);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main content
        GestureDetector(
          onPanStart: _handleSwipeStart,
          onPanUpdate: _handleSwipeUpdate,
          onPanEnd: _handleSwipeEnd,
          child: widget.child,
        ),

        // Edge indicators
        if (_showEdgeIndicator) ...[
          _buildEdgeIndicator(true), // Left edge
          _buildEdgeIndicator(false), // Right edge
        ],

        // Swipe progress indicator
        if (_isSwipeActive) _buildSwipeIndicator(),

        // Double tap gesture overlay
        _buildDoubleTapOverlay(),
      ],
    );
  }

  Widget _buildEdgeIndicator(bool isLeft) {
    return AnimatedBuilder(
      animation: _edgeAnimation,
      builder: (context, child) {
        return Positioned(
          left: isLeft ? 0 : null,
          right: isLeft ? null : 0,
          top: 0,
          bottom: 0,
          child: Transform.scale(
            scaleX: _edgeAnimation.value,
            alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
            child: Container(
              width: 1.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: isLeft ? Alignment.centerLeft : Alignment.centerRight,
                  end: isLeft ? Alignment.centerRight : Alignment.centerLeft,
                  colors: [
                    Color(0xFF6C63FF).withValues(alpha: 0.8),
                    Color(0xFF6C63FF).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSwipeIndicator() {
    return AnimatedBuilder(
      animation: _swipeAnimation,
      builder: (context, child) {
        final isRightSwipe = _swipeDistance > 0;

        return Positioned(
          top: 50.h - 5.h,
          left: isRightSwipe ? 5.w : null,
          right: isRightSwipe ? null : 5.w,
          child: Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: Color(0xFF6C63FF).withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(8.w),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF6C63FF).withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isRightSwipe ? Icons.arrow_back_ios : Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 5.w,
                ),
                SizedBox(width: 2.w),
                Text(
                  _getNavigationHint(isRightSwipe),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getNavigationHint(bool isRightSwipe) {
    final routes = ['Dashboard', 'Messages', 'Wallets', 'Explorer'];
    final currentIndex = widget.currentIndex;

    if (isRightSwipe && currentIndex > 0) {
      return routes[currentIndex - 1];
    } else if (!isRightSwipe && currentIndex < routes.length - 1) {
      return routes[currentIndex + 1];
    }

    return 'Navigate';
  }

  Widget _buildDoubleTapOverlay() {
    return GestureDetector(
      onDoubleTap: _handleDoubleTap,
      behavior: HitTestBehavior.translucent,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.transparent,
      ),
    );
  }

  void _handleDoubleTap() {
    // Double tap to toggle quick menu
    HapticFeedback.mediumImpact();
    NavigationService.instance.handleQuickAction('quick_menu_toggle');
  }
}

// Gesture tutorial overlay
class GestureTutorialOverlay extends StatefulWidget {
  final VoidCallback onClose;

  const GestureTutorialOverlay({
    Key? key,
    required this.onClose,
  }) : super(key: key);

  @override
  State<GestureTutorialOverlay> createState() => _GestureTutorialOverlayState();
}

class _GestureTutorialOverlayState extends State<GestureTutorialOverlay>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  int _currentStep = 0;
  final PageController _pageController = PageController();

  final List<Map<String, dynamic>> _tutorialSteps = [
    {
      'title': 'Swipe Navigation',
      'description':
          'Swipe left or right from any edge to navigate between screens',
      'icon': Icons.swipe,
      'gesture': 'swipe',
    },
    {
      'title': 'Double Tap',
      'description': 'Double tap anywhere to access quick actions menu',
      'icon': Icons.touch_app,
      'gesture': 'double_tap',
    },
    {
      'title': 'Long Press',
      'description': 'Long press on navigation items for context menus',
      'icon': Icons.touch_app,
      'gesture': 'long_press',
    },
    {
      'title': 'Keyboard Shortcuts',
      'description': 'Use Ctrl+S for scan, Ctrl+T for speed test, and more',
      'icon': Icons.keyboard,
      'gesture': 'keyboard',
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _tutorialSteps.length - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      widget.onClose();
    }
  }

  void _skipTutorial() {
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Container(
            color: Colors.black.withValues(alpha: 0.8),
            child: SafeArea(
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: EdgeInsets.all(4.w),
                    child: Row(
                      children: [
                        Icon(
                          Icons.touch_app,
                          color: Color(0xFF6C63FF),
                          size: 6.w,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Navigation Gestures',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Spacer(),
                        TextButton(
                          onPressed: _skipTutorial,
                          child: Text(
                            'Skip',
                            style: TextStyle(
                              color: Color(0xFF6C63FF),
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tutorial content
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _tutorialSteps.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentStep = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        final step = _tutorialSteps[index];
                        return Padding(
                          padding: EdgeInsets.all(6.w),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.all(8.w),
                                decoration: BoxDecoration(
                                  color:
                                      Color(0xFF6C63FF).withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  step['icon'],
                                  color: Color(0xFF6C63FF),
                                  size: 15.w,
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                step['title'],
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 3.h),
                              Text(
                                step['description'],
                                style: TextStyle(
                                  color: Colors.grey[300],
                                  fontSize: 12.sp,
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 6.h),
                              _buildGestureAnimation(step['gesture']),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // Bottom navigation
                  Padding(
                    padding: EdgeInsets.all(4.w),
                    child: Row(
                      children: [
                        // Page indicators
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              _tutorialSteps.length,
                              (index) => Container(
                                margin: EdgeInsets.symmetric(horizontal: 1.w),
                                width: index == _currentStep ? 6.w : 2.w,
                                height: 2.w,
                                decoration: BoxDecoration(
                                  color: index == _currentStep
                                      ? Color(0xFF6C63FF)
                                      : Colors.grey[600],
                                  borderRadius: BorderRadius.circular(1.w),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Next button
                        ElevatedButton(
                          onPressed: _nextStep,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF6C63FF),
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 1.5.h,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6.w),
                            ),
                          ),
                          child: Text(
                            _currentStep < _tutorialSteps.length - 1
                                ? 'Next'
                                : 'Got it!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGestureAnimation(String gesture) {
    switch (gesture) {
      case 'swipe':
        return _SwipeAnimation();
      case 'double_tap':
        return _DoubleTapAnimation();
      case 'long_press':
        return _LongPressAnimation();
      case 'keyboard':
        return _KeyboardAnimation();
      default:
        return Container();
    }
  }
}

// Individual gesture animations
class _SwipeAnimation extends StatefulWidget {
  @override
  State<_SwipeAnimation> createState() => _SwipeAnimationState();
}

class _SwipeAnimationState extends State<_SwipeAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(-1.0, 0.0),
      end: Offset(1.0, 0.0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 8.h,
      width: 50.w,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(2.w),
      ),
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          margin: EdgeInsets.all(1.w),
          decoration: BoxDecoration(
            color: Color(0xFF6C63FF),
            borderRadius: BorderRadius.circular(1.5.w),
          ),
          child: Icon(
            Icons.touch_app,
            color: Colors.white,
            size: 4.w,
          ),
        ),
      ),
    );
  }
}

class _DoubleTapAnimation extends StatefulWidget {
  @override
  State<_DoubleTapAnimation> createState() => _DoubleTapAnimationState();
}

class _DoubleTapAnimationState extends State<_DoubleTapAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: 15.w,
        height: 15.w,
        decoration: BoxDecoration(
          color: Color(0xFF6C63FF).withValues(alpha: 0.3),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.touch_app,
          color: Color(0xFF6C63FF),
          size: 8.w,
        ),
      ),
    );
  }
}

class _LongPressAnimation extends StatefulWidget {
  @override
  State<_LongPressAnimation> createState() => _LongPressAnimationState();
}

class _LongPressAnimationState extends State<_LongPressAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 15.w,
              height: 15.w,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(
              width: 15.w,
              height: 15.w,
              child: CircularProgressIndicator(
                value: _progressAnimation.value,
                strokeWidth: 1.w,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
              ),
            ),
            Icon(
              Icons.touch_app,
              color: Color(0xFF6C63FF),
              size: 6.w,
            ),
          ],
        );
      },
    );
  }
}

class _KeyboardAnimation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(2.w),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildKey('Ctrl'),
          SizedBox(width: 2.w),
          Text('+', style: TextStyle(color: Colors.white, fontSize: 12.sp)),
          SizedBox(width: 2.w),
          _buildKey('S'),
        ],
      ),
    );
  }

  Widget _buildKey(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: Color(0xFF6C63FF),
        borderRadius: BorderRadius.circular(1.w),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
