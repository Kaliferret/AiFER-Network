import 'package:flutter/material.dart';
import '../core/color_polyfill.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// Custom AppBar widget implementing Neural Network Palette design
/// with Quantum Minimalism approach for decentralized communication apps
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final bool centerTitle;
  final double elevation;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final VoidCallback? onBackPressed;
  final PreferredSizeWidget? bottom;
  final bool showNetworkStatus;
  final String networkStatus;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showBackButton = true,
    this.centerTitle = true,
    this.elevation = 0,
    this.backgroundColor,
    this.foregroundColor,
    this.onBackPressed,
    this.bottom,
    this.showNetworkStatus = false,
    this.networkStatus = 'connected',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: foregroundColor ??
                  (isDark ? AppTheme.textPrimaryDark : AppTheme.primaryLight),
            ),
          ),
          if (showNetworkStatus) ...[
            const SizedBox(width: 12),
            _NetworkStatusIndicator(status: networkStatus),
          ],
        ],
      ),
      leading: leading ??
          (showBackButton && Navigator.canPop(context)
              ? IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    color: foregroundColor ??
                        (isDark ? AppTheme.accentColor : AppTheme.primaryLight),
                  ),
                  onPressed: onBackPressed ?? () => Navigator.pop(context),
                )
              : null),
      actions: actions ?? _buildDefaultActions(context),
      centerTitle: centerTitle,
      elevation: elevation,
      backgroundColor: backgroundColor ??
          (isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight),
      foregroundColor: foregroundColor ??
          (isDark ? AppTheme.textPrimaryDark : AppTheme.primaryLight),
      surfaceTintColor: Colors.transparent,
      bottom: bottom,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.surfaceDark,
                    AppTheme.surfaceDark.withValues(alpha: 0.95),
                  ],
                )
              : null,
        ),
      ),
    );
  }

  List<Widget> _buildDefaultActions(BuildContext context) {
    return [
      // Network settings action
      IconButton(
        icon: const Icon(Icons.settings_ethernet),
        tooltip: 'Network Settings',
        onPressed: () => Navigator.pushNamed(context, '/network-dashboard'),
      ),
      // Profile/Settings action
      IconButton(
        icon: const Icon(Icons.account_circle_outlined),
        tooltip: 'Profile',
        onPressed: () => Navigator.pushNamed(context, '/authentication-setup'),
      ),
    ];
  }

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0),
      );
}

/// Network status indicator widget with animated connection states
class _NetworkStatusIndicator extends StatefulWidget {
  final String status;

  const _NetworkStatusIndicator({required this.status});

  @override
  State<_NetworkStatusIndicator> createState() =>
      _NetworkStatusIndicatorState();
}

class _NetworkStatusIndicatorState extends State<_NetworkStatusIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.status.toLowerCase() == 'connecting') {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(_NetworkStatusIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.status.toLowerCase() == 'connecting') {
      _animationController.repeat(reverse: true);
    } else {
      _animationController.stop();
      _animationController.reset();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = AppTheme.getNetworkStatusColor(widget.status);

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.status.toLowerCase() == 'connecting'
              ? _pulseAnimation.value
              : 1.0,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: statusColor.withValues(alpha: 0.4),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
