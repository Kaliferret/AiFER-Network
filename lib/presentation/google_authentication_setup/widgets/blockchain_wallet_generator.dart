import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';

class BlockchainWalletGenerator extends StatefulWidget {
  const BlockchainWalletGenerator({Key? key}) : super(key: key);

  @override
  State<BlockchainWalletGenerator> createState() =>
      _BlockchainWalletGeneratorState();
}

class _BlockchainWalletGeneratorState extends State<BlockchainWalletGenerator>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<Color?> _colorAnimation;

  int _currentStep = 0;
  final List<String> _steps = [
    'Generating Stellar wallet...',
    'Creating SUI blockchain wallet...',
    'Linking wallets to account...',
    'Encrypting wallet data...',
    'Finalizing setup...',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));

    _colorAnimation = ColorTween(
      begin: Color(0xFF6C63FF),
      end: Color(0xFF34A853),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.repeat();
    _startStepProgress();
  }

  void _startStepProgress() async {
    for (int i = 0; i < _steps.length; i++) {
      await Future.delayed(Duration(milliseconds: 800));
      if (mounted) {
        setState(() {
          _currentStep = i;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Blockchain generation animation
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotationAnimation.value * 3.14159,
              child: Container(
                width: 25.w,
                height: 25.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _colorAnimation.value ?? Color(0xFF6C63FF),
                      Color(0xFF9C27B0),
                      Color(0xFFE91E63),
                    ],
                    stops: [0.0, 0.5, 1.0],
                  ),
                  borderRadius: BorderRadius.circular(12.5.w),
                  boxShadow: [
                    BoxShadow(
                      color: (_colorAnimation.value ?? Color(0xFF6C63FF))
                          .withAlpha(102),
                      blurRadius: 20,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer ring
                    Container(
                      width: 20.w,
                      height: 20.w,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white.withAlpha(77),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(10.w),
                      ),
                    ),
                    // Inner blockchain icon
                    Icon(
                      Icons.link,
                      color: Colors.white,
                      size: 8.w,
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        SizedBox(height: 5.h),

        // Title
        Text(
          'Generating Blockchain Wallets',
          style: GoogleFonts.inter(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),

        SizedBox(height: 2.h),

        // Current step
        if (_currentStep < _steps.length)
          Text(
            _steps[_currentStep],
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color:
                  Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(204),
            ),
            textAlign: TextAlign.center,
          ),

        SizedBox(height: 4.h),

        // Progress steps
        Column(
          children: [
            ...List.generate(_steps.length, (index) {
              final isCompleted = index < _currentStep;
              final isCurrent = index == _currentStep;

              return Container(
                margin: EdgeInsets.only(bottom: 1.h),
                child: Row(
                  children: [
                    // Step indicator
                    Container(
                      width: 6.w,
                      height: 6.w,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? Color(0xFF34A853)
                            : isCurrent
                                ? Color(0xFF6C63FF)
                                : Theme.of(context).dividerColor.withAlpha(77),
                        borderRadius: BorderRadius.circular(3.w),
                      ),
                      child: Center(
                        child: isCompleted
                            ? Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 3.w,
                              )
                            : isCurrent
                                ? SizedBox(
                                    width: 3.w,
                                    height: 3.w,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                : null,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    // Step text
                    Expanded(
                      child: Text(
                        _steps[index],
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          color: isCompleted || isCurrent
                              ? Theme.of(context).textTheme.bodyMedium?.color
                              : Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.color
                                  ?.withAlpha(128),
                          fontWeight:
                              isCurrent ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),

            SizedBox(height: 3.h),

            // Security note
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(2.w),
                border: Border.all(
                  color: Color(0xFF34A853).withAlpha(77),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.security,
                    color: Color(0xFF34A853),
                    size: 4.w,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      'Wallets encrypted with your Google account ID',
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        color: Color(0xFF34A853),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
