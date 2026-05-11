import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_export.dart';

class SlideOutMenu extends StatefulWidget {
  final VoidCallback? onClose;

  const SlideOutMenu({
    Key? key,
    this.onClose,
  }) : super(key: key);

  @override
  State<SlideOutMenu> createState() => _SlideOutMenuState();
}

class _SlideOutMenuState extends State<SlideOutMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    ));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _close() {
    _controller.reverse().then((_) {
      widget.onClose?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 80.w,
            height: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? Color(0xFF1A1A1A) : Colors.white,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(4.w),
                bottomRight: Radius.circular(4.w),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: Offset(2, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header
                _buildHeader(isDark),
                
                // Scrollable Navigation Items
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    itemCount: _menuItems.length,
                    itemBuilder: (context, index) {
                      return _buildMenuItem(
                        context,
                        _menuItems[index],
                        isDark,
                        index,
                      );
                    },
                  ),
                ),
                
                // Footer
                _buildFooter(isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF39FF14), // Neon green
            Color(0xFF00E5FF), // Cyan
          ],
        ),
      ),
      child: Row(
        children: [
          // Ferret avatar
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '🦦',
                style: TextStyle(fontSize: 6.w),
              ),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AiFER OS',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'v11 • Neon Ferret',
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: Colors.white),
            onPressed: _close,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    MenuItem item,
    bool isDark,
    int index,
  ) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.5.h),
        leading: Container(
          width: 10.w,
          height: 10.w,
          decoration: BoxDecoration(
            color: item.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(2.w),
          ),
          child: Icon(
            item.icon,
            color: item.color,
            size: 5.w,
          ),
        ),
        title: Text(
          item.title,
          style: GoogleFonts.inter(
            fontSize: 11.sp,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        trailing: item.badge != null
            ? Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.3.h),
                decoration: BoxDecoration(
                  color: item.color,
                  borderRadius: BorderRadius.circular(3.w),
                ),
                child: Text(
                  item.badge!,
                  style: GoogleFonts.inter(
                    fontSize: 8.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              )
            : null,
        onTap: () {
          HapticFeedback.lightImpact();
          _handleNavigation(item);
        },
      ),
    );
  }

  void _handleNavigation(MenuItem item) {
    _close();
    
    // Navigate to the appropriate route
    if (item.route != null) {
      Navigator.pushReplacementNamed(context, item.route!);
    } else {
      // Show placeholder message for not-yet-implemented features
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${item.title} coming soon!'),
          backgroundColor: Color(0xFF39FF14),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildFooter(bool isDark) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white12 : Colors.black12,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildFooterButton(
            Icons.settings,
            'Settings',
            isDark,
            AppRoutes.settings,
          ),
          _buildFooterButton(
            Icons.info_outline,
            'About',
            isDark,
            null,
          ),
          _buildFooterButton(
            Icons.logout,
            'Logout',
            isDark,
            null,
          ),
        ],
      ),
    );
  }

  Widget _buildFooterButton(
    IconData icon,
    String label,
    bool isDark,
    String? route,
  ) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        if (route != null) {
          _close();
          Navigator.pushReplacementNamed(context, route);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$label coming soon!')),
          );
        }
      },
      child: Column(
        children: [
          Icon(
            icon,
            color: isDark ? Colors.white54 : Colors.black54,
            size: 5.w,
          ),
          SizedBox(height: 0.5.h),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 9.sp,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  // 17 menu items from AIFER v11
  static final List<MenuItem> _menuItems = [
    MenuItem(
      title: 'Dashboard',
      icon: Icons.dashboard,
      route: AppRoutes.networkDashboard,
      color: Color(0xFF39FF14), // Neon green
    ),
    MenuItem(
      title: 'Feed',
      icon: Icons.rss_feed,
      route: null, // Not yet implemented
      color: Color(0xFF00E5FF), // Cyan
    ),
    MenuItem(
      title: 'Chat',
      icon: Icons.chat,
      route: AppRoutes.messagingInterface,
      color: Color(0xFFB388FF), // Violet
    ),
    MenuItem(
      title: 'Wallet',
      icon: Icons.account_balance_wallet,
      route: AppRoutes.blockchainWalletManager,
      color: Color(0xFFFF0080), // Magenta
    ),
    MenuItem(
      title: 'Games',
      icon: Icons.sports_esports,
      route: AppRoutes.gamingHub,
      color: Color(0xFFFFD740), // Gold
    ),
    MenuItem(
      title: 'Files',
      icon: Icons.folder,
      route: AppRoutes.ferretFiles,
      color: Color(0xFF40C4FF), // Sky blue
    ),
    MenuItem(
      title: 'Notes',
      icon: Icons.note,
      route: AppRoutes.ferretNotes,
      color: Color(0xFFFF6E40), // Deep orange
    ),
    MenuItem(
      title: 'Terminal',
      icon: Icons.terminal,
      route: AppRoutes.ferretTerminal,
      color: Color(0xFFFFEB3B), // Yellow
    ),
    MenuItem(
      title: 'Mail',
      icon: Icons.mail,
      route: AppRoutes.ferretMail,
      color: Color(0xFF69F0AE), // Light green
    ),
    MenuItem(
      title: 'Gallery',
      icon: Icons.photo_library,
      route: AppRoutes.ferretGallery,
      color: Color(0xFFE040FB), // Purple
    ),
    MenuItem(
      title: 'Calendar',
      icon: Icons.calendar_today,
      route: AppRoutes.ferretCalendar,
      color: Color(0xFF536DFE), // Indigo
    ),
    MenuItem(
      title: 'Media',
      icon: Icons.play_circle,
      route: AppRoutes.ferretMedia,
      color: Color(0xFFFF5252), // Red
    ),
    MenuItem(
      title: 'Tasks',
      icon: Icons.check_circle,
      route: AppRoutes.todoList,
      color: Color(0xFF64FFDA), // Teal
    ),
    MenuItem(
      title: 'FERCode',
      icon: Icons.code,
      route: null, // Not yet implemented
      color: Color(0xFF607D8B), // Blue grey
    ),
    MenuItem(
      title: 'FERTrade',
      icon: Icons.show_chart,
      route: null, // Not yet implemented
      color: Color(0xFF7C4DFF), // Deep purple
      badge: 'PRO',
    ),
    MenuItem(
      title: 'FERChain',
      icon: Icons.link,
      route: AppRoutes.ferexplorer,
      color: Color(0xFF00B0FF), // Light blue
    ),
    MenuItem(
      title: 'Marketplace',
      icon: Icons.store,
      route: null, // Not yet implemented
      color: Color(0xFFFFAB40), // Amber
    ),
  ];
}

class MenuItem {
  final String title;
  final IconData icon;
  final String? route;
  final Color color;
  final String? badge;

  MenuItem({
    required this.title,
    required this.icon,
    this.route,
    required this.color,
    this.badge,
  });
}