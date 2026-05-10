import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

/// Authentication Loading Widget with secure token exchange visualization
class AuthLoadingWidget extends StatefulWidget {
  final String message;

  const AuthLoadingWidget({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  State<AuthLoadingWidget> createState() => _AuthLoadingWidgetState();
}

class _AuthLoadingWidgetState extends State<AuthLoadingWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _rotateAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.linear),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(8.w),
      child: Column(
        children: [
          // Animated loading indicator
          AnimatedBuilder(
            animation: Listenable.merge([_pulseAnimation, _rotateAnimation]),
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Transform.rotate(
                  angle: _rotateAnimation.value * 2 * 3.14159,
                  child: Container(
                    width: 20.w,
                    height: 20.w,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).primaryColor,
                          Theme.of(context).primaryColor.withAlpha(77),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).primaryColor.withAlpha(102),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.security,
                      color: Colors.white,
                      size: 10.w,
                    ),
                  ),
                ),
              );
            },
          ),

          SizedBox(height: 6.w),

          // Loading message
          Text(
            widget.message,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.titleMedium?.color,
            ),
          ),

          SizedBox(height: 2.w),

          Text(
            'Securing your connection with OAuth 2.0',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),

          SizedBox(height: 6.w),

          // Progress steps
          _buildProgressSteps(),
        ],
      ),
    );
  }

  Widget _buildProgressSteps() {
    return Column(
      children: [
        _buildProgressStep(
          'Validating Google account',
          true,
          Icons.verified_user,
        ),
        _buildProgressStep(
          'Exchanging secure tokens',
          true,
          Icons.swap_horiz,
        ),
        _buildProgressStep(
          'Generating blockchain wallets',
          false,
          Icons.account_balance_wallet,
        ),
      ],
    );
  }

  Widget _buildProgressStep(String title, bool isCompleted, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.w),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(
              color: isCompleted
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).dividerColor.withAlpha(77),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCompleted ? Icons.check : icon,
              color: Colors.white,
              size: 4.w,
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                fontWeight: isCompleted ? FontWeight.w600 : FontWeight.w400,
                color: isCompleted
                    ? Theme.of(context).textTheme.titleMedium?.color
                    : Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ),
          if (!isCompleted) ...[
            SizedBox(
              width: 4.w,
              height: 4.w,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }
}
