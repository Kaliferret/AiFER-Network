import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../core/app_export.dart';
import '../services/google_auth_service.dart';

class EnhancedBottomBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final Function(String) onQuickAction;

  const EnhancedBottomBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.onQuickAction,
  }) : super(key: key);

  @override
  State<EnhancedBottomBar> createState() => _EnhancedBottomBarState();
}

class _EnhancedBottomBarState extends State<EnhancedBottomBar>
    with TickerProviderStateMixin {
  late AnimationController _fabAnimationController;
  late AnimationController _selectionAnimationController;
  late Animation<double> _fabAnimation;
  late Animation<double> _selectionAnimation;

  bool _showQuickMenu = false;
  int _previousIndex = 0;

  final List<Map<String, dynamic>> _quickActions = [
    {
      'icon': Icons.qr_code_scanner,
      'label': 'Scan',
      'action': 'scan_network',
      'color': Color(0xFF6C63FF),
    },
    {
      'icon': Icons.emergency,
      'label': 'Emergency',
      'action': 'emergency_mode',
      'color': Color(0xFFFF6B6B),
    },
    {
      'icon': Icons.speed,
      'label': 'Network Test',
      'action': 'speed_test',
      'color': Color(0xFF4ECDC4),
    },
    {
      'icon': Icons.security,
      'label': 'Security Check',
      'action': 'security_scan',
      'color': Color(0xFFFFD93D),
    },
  ];

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _selectionAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _fabAnimationController, curve: Curves.elasticOut),
    );
    _selectionAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _selectionAnimationController, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(EnhancedBottomBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _previousIndex = oldWidget.currentIndex;
      _selectionAnimationController.forward().then((_) {
        _selectionAnimationController.reset();
      });
      // Haptic feedback for navigation
      HapticFeedback.selectionClick();
    }
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _selectionAnimationController.dispose();
    super.dispose();
  }

  void _toggleQuickMenu() {
    setState(() {
      _showQuickMenu = !_showQuickMenu;
    });

    if (_showQuickMenu) {
      _fabAnimationController.forward();
      HapticFeedback.mediumImpact();
    } else {
      _fabAnimationController.reverse();
    }
  }

  void _handleQuickAction(String action) {
    _toggleQuickMenu();
    widget.onQuickAction(action);
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isAdmin = GoogleAuthService.instance.isAdmin();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Quick Actions Overlay
        if (_showQuickMenu) _buildQuickActionsOverlay(isDark, theme),

        // Main Bottom Bar
        Container(
          height: 14.h,
          decoration: BoxDecoration(
            color: isDark ? Color(0xFF1A1A1A) : Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(8.w)),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withAlpha(80)
                    : Colors.grey.withAlpha(40),
                blurRadius: 20,
                offset: Offset(0, -5),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            children: [
              // Connection Status Indicator
              _buildConnectionIndicator(isDark),

              // Navigation Items
              Expanded(
                child: Row(
                  children: [
                    _buildNavItem(
                      context,
                      icon: Icons.dashboard_outlined,
                      activeIcon: Icons.dashboard,
                      label: 'Dashboard',
                      index: 0,
                      route: AppRoutes.networkDashboard,
                      isDark: isDark,
                    ),
                    _buildNavItem(
                      context,
                      icon: Icons.chat_bubble_outline,
                      activeIcon: Icons.chat_bubble,
                      label: 'Messages',
                      index: 1,
                      route: AppRoutes.messagingInterface,
                      isDark: isDark,
                    ),
                    // FAB Space
                    Expanded(child: Container()),
                    _buildNavItem(
                      context,
                      icon: Icons.account_balance_wallet_outlined,
                      activeIcon: Icons.account_balance_wallet,
                      label: 'Wallets',
                      index: 2,
                      route: AppRoutes.blockchainWalletManager,
                      isDark: isDark,
                    ),
                    _buildNavItem(
                      context,
                      icon: Icons.explore_outlined,
                      activeIcon: Icons.explore,
                      label: 'Explorer',
                      index: 3,
                      route: AppRoutes.ferexplorer,
                      isDark: isDark,
                    ),
                    if (isAdmin)
                      _buildNavItem(
                        context,
                        icon: Icons.admin_panel_settings_outlined,
                        activeIcon: Icons.admin_panel_settings,
                        label: 'Admin',
                        index: 4,
                        route: AppRoutes.adminPanelDashboard,
                        isDark: isDark,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Floating Action Button
        _buildFloatingActionButton(isDark),
      ],
    );
  }

  Widget _buildConnectionIndicator(bool isDark) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 0.8.h, horizontal: 4.w),
      decoration: BoxDecoration(
        color: Color(0xFF6C63FF).withValues(alpha: 0.1),
        borderRadius: BorderRadius.vertical(top: Radius.circular(8.w)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 1.5.w,
            height: 1.5.w,
            decoration: BoxDecoration(
              color: Color(0xFF6C63FF),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF6C63FF).withValues(alpha: 0.5),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          SizedBox(width: 2.w),
          Text(
            'FER Network • Quantum Secure',
            style: GoogleFonts.inter(
              fontSize: 9.sp,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6C63FF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    required String route,
    required bool isDark,
  }) {
    final isActive = widget.currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (widget.currentIndex != index) {
            Navigator.pushReplacementNamed(context, route);
          }
          widget.onTap(index);
        },
        onLongPress: () {
          // Long press for context actions
          HapticFeedback.mediumImpact();
          _showContextMenu(context, label, route);
        },
        child: AnimatedBuilder(
          animation: _selectionAnimation,
          builder: (context, child) {
            return Container(
              padding: EdgeInsets.symmetric(vertical: 1.2.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Selection indicator
                      AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.elasticOut,
                        width: isActive ? 12.w : 0,
                        height: isActive ? 12.w : 0,
                        decoration: BoxDecoration(
                          color: Color(0xFF6C63FF).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6.w),
                        ),
                      ),
                      // Icon container
                      Container(
                        padding: EdgeInsets.all(2.5.w),
                        child: AnimatedSwitcher(
                          duration: Duration(milliseconds: 200),
                          child: Icon(
                            isActive ? activeIcon : icon,
                            key: ValueKey(isActive),
                            color: isActive
                                ? Color(0xFF6C63FF)
                                : isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                            size: 5.5.w,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 0.3.h),
                  AnimatedDefaultTextStyle(
                    duration: Duration(milliseconds: 200),
                    style: GoogleFonts.inter(
                      fontSize: isActive ? 9.sp : 8.5.sp,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                      color: isActive
                          ? Color(0xFF6C63FF)
                          : isDark
                              ? Colors.grey[400]
                              : Colors.grey[600],
                    ),
                    child: Text(label),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton(bool isDark) {
    return Positioned(
      top: -6.w,
      left: 0,
      right: 0,
      child: Center(
        child: AnimatedBuilder(
          animation: _fabAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _showQuickMenu ? 1.1 : 1.0,
              child: GestureDetector(
                onTap: _toggleQuickMenu,
                child: Container(
                  width: 14.w,
                  height: 14.w,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF6C63FF),
                        Color(0xFF4F46E5),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF6C63FF).withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: AnimatedRotation(
                    turns: _showQuickMenu ? 0.125 : 0.0,
                    duration: Duration(milliseconds: 300),
                    child: Icon(
                      _showQuickMenu ? Icons.close : Icons.add,
                      color: Colors.white,
                      size: 6.w,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildQuickActionsOverlay(bool isDark, ThemeData theme) {
    return Positioned.fill(
      child: GestureDetector(
        onTap: _toggleQuickMenu,
        child: Container(
          color: Colors.black.withValues(alpha: 0.3),
          child: AnimatedBuilder(
            animation: _fabAnimation,
            builder: (context, child) {
              return Stack(
                children: _quickActions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final action = entry.value;
                  final angle = (index * 60 - 30) * 3.14159 / 180;
                  final radius = 15.w * _fabAnimation.value;

                  return Positioned(
                    bottom: 14.h + 2.w + (radius * 0.8),
                    left:
                        50.w + (radius * 0.6 * (index % 2 == 0 ? -1 : 1)) - 6.w,
                    child: Transform.scale(
                      scale: _fabAnimation.value,
                      child: Opacity(
                        opacity: _fabAnimation.value,
                        child: GestureDetector(
                          onTap: () => _handleQuickAction(action['action']),
                          child: Column(
                            children: [
                              Container(
                                width: 12.w,
                                height: 12.w,
                                decoration: BoxDecoration(
                                  color: action['color'],
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: (action['color'] as Color)
                                          .withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  action['icon'],
                                  color: Colors.white,
                                  size: 5.w,
                                ),
                              ),
                              SizedBox(height: 1.h),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 2.w, vertical: 0.5.h),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.black87 : Colors.white,
                                  borderRadius: BorderRadius.circular(4.w),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  action['label'],
                                  style: GoogleFonts.inter(
                                    fontSize: 8.sp,
                                    fontWeight: FontWeight.w500,
                                    color:
                                        isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context, String label, String route) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: EdgeInsets.all(4.w),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(4.w),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$label Options',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            ListTile(
              leading: Icon(Icons.open_in_new),
              title: Text('Open in New Tab'),
              onTap: () {
                Navigator.pop(context);
                // Handle new tab logic
              },
            ),
            ListTile(
              leading: Icon(Icons.bookmark_border),
              title: Text('Add to Favorites'),
              onTap: () {
                Navigator.pop(context);
                // Handle bookmark logic
              },
            ),
            ListTile(
              leading: Icon(Icons.share),
              title: Text('Share Screen'),
              onTap: () {
                Navigator.pop(context);
                // Handle share logic
              },
            ),
          ],
        ),
      ),
    );
  }
}
