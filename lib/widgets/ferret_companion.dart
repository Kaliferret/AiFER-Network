import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

/// FERCompanion - The ferret mascot that assists users
/// This is a placeholder widget for future implementation
class FERCompanion extends StatefulWidget {
  final bool isVisible;
  final VoidCallback? onTap;

  const FERCompanion({
    Key? key,
    this.isVisible = false,
    this.onTap,
  }) : super(key: key);

  @override
  State<FERCompanion> createState() => _FERCompanionState();
}

class _FERCompanionState extends State<FERCompanion>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _idleController;
  late Animation<Offset> _bounceAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _eyeBlinkAnimation;

  Timer? _interactionTimer;
  bool _isSpeaking = false;

  final List<String> _greetings = [
    "Hi! I'm your ferret companion! 🦦",
    "Need help exploring AiFER OS?",
    "Let me guide you through!",
    "I'm here to assist you!",
  ];

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _idleController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _bounceAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -20),
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _idleController,
      curve: Curves.easeInOut,
    ));

    _eyeBlinkAnimation = Tween<double>(
      begin: 1.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _idleController,
      curve: Curves.easeInOut,
    ));

    if (widget.isVisible) {
      _startAnimations();
    }
  }

  @override
  void didUpdateWidget(FERCompanion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _startAnimations();
      } else {
        _stopAnimations();
      }
    }
  }

  void _startAnimations() {
    _bounceController.repeat(reverse: true);
    _idleController.repeat(reverse: true);
  }

  void _stopAnimations() {
    _bounceController.stop();
    _idleController.stop();
  }

  void _handleTap() {
    setState(() {
      _isSpeaking = true;
    });

    // Show greeting bubble
    final greeting = _greetings[(DateTime.now().millisecond) % _greetings.length];
    _showSpeechBubble(greeting);

    // Reset speaking state after animation
    Timer(const Duration(seconds: 2), () {
      setState(() {
        _isSpeaking = false;
      });
    });

    widget.onTap?.call();
  }

  void _showSpeechBubble(String message) {
    // In a full implementation, this would show a speech bubble
    // For now, we'll use a Snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Color(0xFF39FF14),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _idleController.dispose();
    _interactionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) return const SizedBox.shrink();

    return Positioned(
      bottom: 20.h,
      right: 5.w,
      child: GestureDetector(
        onTap: _handleTap,
        child: AnimatedBuilder(
          animation: Listenable.merge([_bounceController, _idleController]),
          builder: (context, child) {
            return Transform.translate(
              offset: _bounceAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Speech bubble (placeholder)
                    if (_isSpeaking)
                      Container(
                        margin: EdgeInsets.only(bottom: 2.h),
                        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(3.w),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Text(
                          "Hello! 🦦",
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    
                    // Ferret mascot (emoji placeholder)
                    Container(
                      width: 20.w,
                      height: 20.w,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF39FF14), // Neon green
                            Color(0xFF00E5FF), // Cyan
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF39FF14).withValues(alpha: 0.4),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Text(
                              '🦦',
                              style: TextStyle(fontSize: 10.w),
                            ),
                          ),
                          // Pulsing rings
                          ...List.generate(3, (index) {
                            return AnimatedContainer(
                              duration: Duration(milliseconds: 1500),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Color(0xFF39FF14).withValues(
                                      alpha: 0.3 - (index * 0.1)),
                                  width: 2,
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    
                    // Label
                    SizedBox(height: 1.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: Color(0xFF39FF14).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(3.w),
                      ),
                      child: Text(
                        'Tap for help',
                        style: GoogleFonts.inter(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF39FF14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// A screen that shows the FERCompanion (for testing)
class FERCompanionDemoScreen extends StatefulWidget {
  const FERCompanionDemoScreen({Key? key}) : super(key: key);

  @override
  State<FERCompanionDemoScreen> createState() => _FERCompanionDemoScreenState();
}

class _FERCompanionDemoScreenState extends State<FERCompanionDemoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FERCompanion Demo'),
      ),
      body: Stack(
        children: [
          // Background content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.touch_app,
                  size: 15.w,
                  color: Colors.grey,
                ),
                SizedBox(height: 2.h),
                Text(
                  'Tap the ferret to interact',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          
          // FERCompanion overlay
          FERCompanion(
            isVisible: true,
            onTap: () {
              print('Ferret tapped!');
            },
          ),
        ],
      ),
    );
  }
}