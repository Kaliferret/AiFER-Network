import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../core/app_export.dart';
import '../services/google_auth_service.dart';

class QuickAccessAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final VoidCallback? onBackPressed;
  final PreferredSizeWidget? bottom;
  final bool showNetworkStatus;
  final String networkStatus;
  final Function(String)? onQuickAction;

  const QuickAccessAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showBackButton = true,
    this.centerTitle = true,
    this.backgroundColor,
    this.foregroundColor,
    this.onBackPressed,
    this.bottom,
    this.showNetworkStatus = false,
    this.networkStatus = 'connected',
    this.onQuickAction,
  });

  @override
  State<QuickAccessAppBar> createState() => _QuickAccessAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0) + 8.h,
      );
}

class _QuickAccessAppBarState extends State<QuickAccessAppBar>
    with TickerProviderStateMixin {
  late AnimationController _searchController;
  late AnimationController _menuController;
  late Animation<double> _searchAnimation;
  late Animation<double> _menuAnimation;

  bool _showSearch = false;
  bool _showQuickMenu = false;
  final TextEditingController _searchTextController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  final List<Map<String, dynamic>> _quickMenuItems = [
    {
      'icon': Icons.qr_code_scanner,
      'label': 'Scan Network',
      'action': 'scan_network',
      'shortcut': 'Ctrl+S',
    },
    {
      'icon': Icons.speed,
      'label': 'Speed Test',
      'action': 'speed_test',
      'shortcut': 'Ctrl+T',
    },
    {
      'icon': Icons.settings_ethernet,
      'label': 'Network Settings',
      'action': 'network_settings',
      'shortcut': 'Ctrl+N',
    },
    {
      'icon': Icons.emergency,
      'label': 'Emergency Mode',
      'action': 'emergency_mode',
      'shortcut': 'Ctrl+E',
    },
    {
      'icon': Icons.security,
      'label': 'Security Scan',
      'action': 'security_scan',
      'shortcut': 'Ctrl+R',
    },
    {
      'icon': Icons.backup,
      'label': 'Backup Data',
      'action': 'backup_data',
      'shortcut': 'Ctrl+B',
    },
  ];

  @override
  void initState() {
    super.initState();
    _searchController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _menuController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _searchAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _searchController, curve: Curves.easeOut),
    );
    _menuAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _menuController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _menuController.dispose();
    _searchTextController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _showSearch = !_showSearch;
    });

    if (_showSearch) {
      _searchController.forward();
      _searchFocusNode.requestFocus();
    } else {
      _searchController.reverse();
      _searchFocusNode.unfocus();
      _searchTextController.clear();
    }
    HapticFeedback.selectionClick();
  }

  void _toggleQuickMenu() {
    setState(() {
      _showQuickMenu = !_showQuickMenu;
    });

    if (_showQuickMenu) {
      _menuController.forward();
    } else {
      _menuController.reverse();
    }
    HapticFeedback.mediumImpact();
  }

  void _handleQuickAction(String action) {
    _toggleQuickMenu();
    if (widget.onQuickAction != null) {
      widget.onQuickAction!(action);
    }
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isAdmin = GoogleAuthService.instance.isAdmin();

    return Stack(
      children: [
        AppBar(
          title: _buildTitle(isDark, theme),
          leading: widget.leading ??
              (widget.showBackButton && Navigator.canPop(context)
                  ? IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_new,
                        color: widget.foregroundColor ??
                            (isDark
                                ? Color(0xFF6C63FF)
                                : AppTheme.primaryLight),
                      ),
                      onPressed:
                          widget.onBackPressed ?? () => Navigator.pop(context),
                    )
                  : null),
          actions: _buildActions(isDark, isAdmin),
          centerTitle: widget.centerTitle,
          elevation: 0,
          backgroundColor: widget.backgroundColor ??
              (isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight),
          foregroundColor: widget.foregroundColor ??
              (isDark ? AppTheme.textPrimaryDark : AppTheme.primaryLight),
          surfaceTintColor: Colors.transparent,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(8.h),
            child: Column(
              children: [
                if (widget.showNetworkStatus) _buildNetworkStatus(isDark),
                _buildQuickAccessBar(isDark, theme),
                if (widget.bottom != null) widget.bottom!,
              ],
            ),
          ),
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
        ),

        // Quick Menu Overlay
        if (_showQuickMenu) _buildQuickMenuOverlay(isDark, theme),
      ],
    );
  }

  Widget _buildTitle(bool isDark, ThemeData theme) {
    return AnimatedBuilder(
      animation: _searchAnimation,
      builder: (context, child) {
        return Row(
          children: [
            if (!_showSearch) ...[
              Icon(
                Icons.hub,
                color: Color(0xFF6C63FF),
                size: 6.w,
              ),
              SizedBox(width: 2.w),
            ],
            Expanded(
              child: _showSearch
                  ? Container(
                      height: 5.h,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[800] : Colors.grey[100],
                        borderRadius: BorderRadius.circular(6.w),
                        border: Border.all(
                          color: Color(0xFF6C63FF).withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: _searchTextController,
                        focusNode: _searchFocusNode,
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search network, wallets, or commands...',
                          hintStyle: GoogleFonts.inter(
                            fontSize: 11.sp,
                            color: Colors.grey[500],
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Color(0xFF6C63FF),
                            size: 5.w,
                          ),
                          suffixIcon: _searchTextController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    color: Colors.grey[500],
                                    size: 4.w,
                                  ),
                                  onPressed: () {
                                    _searchTextController.clear();
                                    setState(() {});
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 3.w,
                            vertical: 1.h,
                          ),
                        ),
                        onChanged: (value) => setState(() {}),
                      ),
                    )
                  : Text(
                      widget.title,
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppTheme.textPrimaryDark
                            : AppTheme.primaryLight,
                      ),
                    ),
            ),
            if (widget.showNetworkStatus && !_showSearch) ...[
              SizedBox(width: 3.w),
              _NetworkStatusIndicator(status: widget.networkStatus),
            ],
          ],
        );
      },
    );
  }

  List<Widget> _buildActions(bool isDark, bool isAdmin) {
    return [
      // Search toggle
      IconButton(
        onPressed: _toggleSearch,
        icon: AnimatedSwitcher(
          duration: Duration(milliseconds: 200),
          child: Icon(
            _showSearch ? Icons.close : Icons.search,
            key: ValueKey(_showSearch),
            color: Color(0xFF6C63FF),
          ),
        ),
        tooltip: _showSearch ? 'Close Search' : 'Search',
      ),

      // Quick menu toggle
      IconButton(
        onPressed: _toggleQuickMenu,
        icon: AnimatedRotation(
          turns: _showQuickMenu ? 0.5 : 0.0,
          duration: Duration(milliseconds: 200),
          child: Icon(
            Icons.apps,
            color: Color(0xFF6C63FF),
          ),
        ),
        tooltip: 'Quick Actions',
      ),

      // Profile/User menu
      PopupMenuButton<String>(
        icon: CircleAvatar(
          radius: 4.w,
          backgroundColor: Color(0xFF6C63FF).withValues(alpha: 0.2),
          child: Icon(
            Icons.person,
            color: Color(0xFF6C63FF),
            size: 4.w,
          ),
        ),
        onSelected: (value) {
          switch (value) {
            case 'profile':
              Navigator.pushNamed(context, AppRoutes.authenticationSetup);
              break;
            case 'settings':
              Navigator.pushNamed(context, AppRoutes.deviceSettings);
              break;
            case 'admin':
              if (isAdmin) {
                Navigator.pushNamed(context, AppRoutes.adminPanelDashboard);
              }
              break;
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'profile',
            child: Row(
              children: [
                Icon(Icons.person_outline, size: 4.w),
                SizedBox(width: 2.w),
                Text('Profile'),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'settings',
            child: Row(
              children: [
                Icon(Icons.settings_outlined, size: 4.w),
                SizedBox(width: 2.w),
                Text('Settings'),
              ],
            ),
          ),
          if (isAdmin)
            PopupMenuItem(
              value: 'admin',
              child: Row(
                children: [
                  Icon(Icons.admin_panel_settings_outlined, size: 4.w),
                  SizedBox(width: 2.w),
                  Text('Admin Panel'),
                ],
              ),
            ),
        ],
      ),
    ];
  }

  Widget _buildNetworkStatus(bool isDark) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 4.w),
      color: widget.networkStatus == 'connected'
          ? Color(0xFF6C63FF).withValues(alpha: 0.1)
          : AppTheme.warningColor.withValues(alpha: 0.1),
      child: Row(
        children: [
          _NetworkStatusIndicator(status: widget.networkStatus),
          SizedBox(width: 2.w),
          Text(
            widget.networkStatus == 'connected'
                ? 'FER Network • Quantum Secure Connection'
                : 'Network ${widget.networkStatus.toUpperCase()}',
            style: GoogleFonts.inter(
              fontSize: 9.sp,
              fontWeight: FontWeight.w500,
              color: widget.networkStatus == 'connected'
                  ? Color(0xFF6C63FF)
                  : AppTheme.warningColor,
            ),
          ),
          Spacer(),
          if (widget.networkStatus == 'connected')
            Icon(
              Icons.security,
              color: Color(0xFF6C63FF),
              size: 3.w,
            ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessBar(bool isDark, ThemeData theme) {
    return Container(
      height: 6.h,
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.surfaceDark.withValues(alpha: 0.8)
            : AppTheme.surfaceLight.withValues(alpha: 0.8),
        border: Border(
          top: BorderSide(
            color: isDark
                ? AppTheme.dividerDark.withValues(alpha: 0.3)
                : AppTheme.dividerLight.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildQuickAccessButton(
            icon: Icons.qr_code_scanner,
            label: 'Scan',
            onTap: () => _handleQuickAction('scan_network'),
            isDark: isDark,
          ),
          _buildQuickAccessButton(
            icon: Icons.speed,
            label: 'Test',
            onTap: () => _handleQuickAction('speed_test'),
            isDark: isDark,
          ),
          _buildQuickAccessButton(
            icon: Icons.emergency,
            label: 'Emergency',
            onTap: () => _handleQuickAction('emergency_mode'),
            isDark: isDark,
            isEmergency: true,
          ),
          _buildQuickAccessButton(
            icon: Icons.more_horiz,
            label: 'More',
            onTap: _toggleQuickMenu,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
    bool isEmergency = false,
  }) {
    final color = isEmergency ? AppTheme.errorColor : Color(0xFF6C63FF);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(2.w),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 4.w,
            ),
            SizedBox(height: 0.2.h),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 8.sp,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickMenuOverlay(bool isDark, ThemeData theme) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      bottom: 0,
      child: GestureDetector(
        onTap: _toggleQuickMenu,
        child: Container(
          color: Colors.black.withValues(alpha: 0.3),
          child: Align(
            alignment: Alignment.topRight,
            child: AnimatedBuilder(
              animation: _menuAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _menuAnimation.value,
                  alignment: Alignment.topRight,
                  child: Container(
                    margin: EdgeInsets.only(
                      top: kToolbarHeight + 2.h,
                      right: 4.w,
                    ),
                    width: 70.w,
                    decoration: BoxDecoration(
                      color: isDark ? Color(0xFF2A2A2A) : Colors.white,
                      borderRadius: BorderRadius.circular(3.w),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            color: Color(0xFF6C63FF).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(3.w),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.flash_on,
                                color: Color(0xFF6C63FF),
                                size: 5.w,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                'Quick Actions',
                                style: GoogleFonts.inter(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF6C63FF),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ...(_quickMenuItems.map((item) => _buildQuickMenuItem(
                              item: item,
                              isDark: isDark,
                            ))),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickMenuItem({
    required Map<String, dynamic> item,
    required bool isDark,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: Color(0xFF6C63FF).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(2.w),
        ),
        child: Icon(
          item['icon'],
          color: Color(0xFF6C63FF),
          size: 4.w,
        ),
      ),
      title: Text(
        item['label'],
        style: GoogleFonts.inter(
          fontSize: 11.sp,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      subtitle: Text(
        item['shortcut'],
        style: GoogleFonts.inter(
          fontSize: 9.sp,
          color: Colors.grey[500],
        ),
      ),
      onTap: () => _handleQuickAction(item['action']),
      dense: true,
    );
  }
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
            width: 2.w,
            height: 2.w,
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
