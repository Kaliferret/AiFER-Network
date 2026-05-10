import 'package:flutter/material.dart';
import '../core/color_polyfill.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// Custom TabBar widget implementing Neural Network Palette design
/// with quantum teal indicators and clean hierarchy for technical interfaces
class CustomTabBar extends StatefulWidget implements PreferredSizeWidget {
  final List<CustomTab> tabs;
  final int initialIndex;
  final ValueChanged<int>? onTap;
  final bool isScrollable;
  final TabAlignment? tabAlignment;
  final EdgeInsetsGeometry? labelPadding;
  final Color? indicatorColor;
  final double indicatorWeight;
  final TabBarIndicatorSize indicatorSize;

  const CustomTabBar({
    super.key,
    required this.tabs,
    this.initialIndex = 0,
    this.onTap,
    this.isScrollable = false,
    this.tabAlignment,
    this.labelPadding,
    this.indicatorColor,
    this.indicatorWeight = 3.0,
    this.indicatorSize = TabBarIndicatorSize.label,
  });

  @override
  State<CustomTabBar> createState() => _CustomTabBarState();

  @override
  Size get preferredSize => const Size.fromHeight(48);
}

class _CustomTabBarState extends State<CustomTabBar>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _scaleAnimations;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.tabs.length,
      initialIndex: widget.initialIndex,
      vsync: this,
    );

    _initializeAnimations();
    _tabController.addListener(_handleTabChange);
  }

  void _initializeAnimations() {
    _animationControllers = List.generate(
      widget.tabs.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 150),
        vsync: this,
      ),
    );

    _scaleAnimations = _animationControllers
        .map((controller) => Tween<double>(
              begin: 1.0,
              end: 1.05,
            ).animate(CurvedAnimation(
              parent: controller,
              curve: Curves.easeInOut,
            )))
        .toList();

    // Animate the initially selected tab
    if (widget.initialIndex < _animationControllers.length) {
      _animationControllers[widget.initialIndex].forward();
    }
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) return;

    final previousIndex = _tabController.previousIndex;
    final currentIndex = _tabController.index;

    // Reset previous animation
    if (previousIndex < _animationControllers.length) {
      _animationControllers[previousIndex].reverse();
    }

    // Start new animation
    if (currentIndex < _animationControllers.length) {
      _animationControllers[currentIndex].forward();
    }

    // Handle navigation if route is provided
    final currentTab = widget.tabs[currentIndex];
    if (currentTab.route != null) {
      Navigator.pushNamed(context, currentTab.route!);
    }

    // Call the provided onTap callback
    widget.onTap?.call(currentIndex);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    for (final controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? AppTheme.dividerDark.withValues(alpha: 0.3)
                : AppTheme.dividerLight.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        tabs: List.generate(widget.tabs.length, (index) {
          return _buildTab(context, index, isDark);
        }),
        isScrollable: widget.isScrollable,
        tabAlignment: widget.tabAlignment,
        labelPadding: widget.labelPadding ??
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        labelColor: AppTheme.accentColor,
        unselectedLabelColor:
            isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
        labelStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.1,
        ),
        indicator: _CustomTabIndicator(
          color: widget.indicatorColor ?? AppTheme.accentColor,
          weight: widget.indicatorWeight,
        ),
        indicatorSize: widget.indicatorSize,
        splashFactory: NoSplash.splashFactory,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
      ),
    );
  }

  Widget _buildTab(BuildContext context, int index, bool isDark) {
    final tab = widget.tabs[index];
    final isSelected = index == _tabController.index;

    return AnimatedBuilder(
      animation: _scaleAnimations[index],
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimations[index].value,
          child: Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon with quantum teal accent
                if (tab.icon != null) ...[
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.accentColor.withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      tab.icon,
                      size: 20,
                      color: isSelected
                          ? AppTheme.accentColor
                          : (isDark
                              ? AppTheme.textSecondaryDark
                              : AppTheme.textSecondary),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],

                // Tab text with network status indicator
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          tab.text,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),

                      // Network status or badge indicator
                      if (tab.showBadge) ...[
                        const SizedBox(width: 6),
                        _TabBadge(
                          count: tab.badgeCount,
                          showDot: tab.badgeCount == 0,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Custom tab indicator with quantum teal accent
class _CustomTabIndicator extends Decoration {
  final Color color;
  final double weight;

  const _CustomTabIndicator({
    required this.color,
    required this.weight,
  });

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _CustomTabIndicatorPainter(
      color: color,
      weight: weight,
      onChanged: onChanged,
    );
  }
}

class _CustomTabIndicatorPainter extends BoxPainter {
  final Color color;
  final double weight;

  _CustomTabIndicatorPainter({
    required this.color,
    required this.weight,
    VoidCallback? onChanged,
  }) : super(onChanged);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final rect = Rect.fromLTWH(
      offset.dx,
      configuration.size!.height - weight,
      configuration.size!.width,
      weight,
    );

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw rounded indicator
    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(weight / 2),
    );

    canvas.drawRRect(rrect, paint);
  }
}

/// Badge widget for tab notifications
class _TabBadge extends StatelessWidget {
  final int count;
  final bool showDot;

  const _TabBadge({
    required this.count,
    this.showDot = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (showDot && count == 0) {
      return Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          color: AppTheme.accentColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.accentColor.withValues(alpha: 0.4),
              blurRadius: 2,
              spreadRadius: 0.5,
            ),
          ],
        ),
      );
    }

    if (count > 0) {
      return Container(
        constraints: const BoxConstraints(
          minWidth: 16,
          minHeight: 16,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          color: AppTheme.errorColor,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: AppTheme.errorColor.withValues(alpha: 0.3),
              blurRadius: 2,
              spreadRadius: 0.5,
            ),
          ],
        ),
        child: Text(
          count > 99 ? '99+' : count.toString(),
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppTheme.surfaceLight,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

/// Data class for custom tab configuration
class CustomTab {
  final String text;
  final IconData? icon;
  final String? route;
  final bool showBadge;
  final int badgeCount;

  const CustomTab({
    required this.text,
    this.icon,
    this.route,
    this.showBadge = false,
    this.badgeCount = 0,
  });
}
