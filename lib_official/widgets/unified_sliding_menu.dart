<![CDATA[import 'dart:async';
import 'package:flutter/material.dart';
import '../services/aiferid_auth_service.dart';
import '../core/frequency_hopping.dart';

/// Unified Sliding Menu for FER Ecosystem
/// Consistent navigation across all platforms and applications
class UnifiedSlidingMenu extends StatefulWidget {
  final FERAppType currentApp;
  final Function(FERAppType) onAppSelected;
  final AiFERiDUserProfile? userProfile;
  final bool isMenuOpen;
  final VoidCallback? onMenuToggle;
  
  const UnifiedSlidingMenu({
    Key? key,
    required this.currentApp,
    required this.onAppSelected,
    this.userProfile,
    this.isMenuOpen = false,
    this.onMenuToggle,
  }) : super(key: key);
  
  @override
  _UnifiedSlidingMenuState createState() => _UnifiedSlidingMenuState();
}

class _UnifiedSlidingMenuState extends State<UnifiedSlidingMenu> 
    with SingleTickerProviderStateMixin {
  
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  bool _isMenuOpen = false;
  
  // Badge counts
  int _unreadMessageCount = 0;
  int _pendingTransferCount = 0;
  int _activeGameCount = 0;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadBadgeCounts();
    _setupRealtimeUpdates();
  }
  
  @override
  void didUpdateWidget(UnifiedSlidingMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isMenuOpen != _isMenuOpen) {
      _toggleMenu(widget.isMenuOpen);
    }
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main content area
        widget.child ?? Container(),
        
        // Semi-transparent overlay when menu is open
        if (_isMenuOpen)
          GestureDetector(
            onTap: () => _closeMenu(),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 250),
              color: Colors.black.withOpacity(_isMenuOpen ? 0.5 : 0.0),
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        
        // Sliding menu panel
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          child: SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: _buildMenuPanel(),
            ),
          ),
        ),
      ],
    );
  }
  
  /// Initialize menu animations
  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: Offset(-1.0, 0.0),
      end: Offset(0.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }
  
  /// Build the main menu panel
  Widget _buildMenuPanel() {
    return Container(
      width: 320.0,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: Offset(4, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Menu header with user profile
          _buildMenuHeader(),
          
          // Menu items
          Expanded(
            child: _buildMenuItems(),
          ),
          
          // Menu footer with system info
          _buildMenuFooter(),
        ],
      ),
    );
  }
  
  /// Build menu header with FER branding and user info
  Widget _buildMenuHeader() {
    return Container(
      padding: EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            FERColors.primary,
            FERColors.primaryDark,
          ],
        ),
      ),
      child: Column(
        children: [
          // FER Logo
          Container(
            width: 70.0,
            height: 70.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 15,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.network_check,
                  size: 35.0,
                  color: FERColors.primary,
                ),
                
                // Status indicator
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    width: 16.0,
                    height: 16.0,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 16.0),
          
          // User profile or anonymous ferret
          if (widget.userProfile != null)
            _buildUserProfileHeader()
          else
            _buildAnonymousFerretHeader(),
          
          SizedBox(height: 12.0),
          
          // Network status
          _buildNetworkStatus(),
        ],
      ),
    );
  }
  
  /// Build authenticated user profile header
  Widget _buildUserProfileHeader() {
    final user = widget.userProfile!;
    final displayName = user.ferretId.isNotEmpty 
        ? user.ferretId 
        : user.walletAddress.substring(0, 6) + '...';
    
    return Column(
      children: [
        // User avatar
        CircleAvatar(
          radius: 28.0,
          backgroundColor: Colors.white.withOpacity(0.2),
          child: user.ferretId.isNotEmpty
            ? Icon(Icons.pets, size: 30.0, color: Colors.white)
            : Icon(Icons.account_circle, size: 30.0, color: Colors.white),
        ),
        
        SizedBox(height: 8.0),
        
        // User name
        Text(
          displayName,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        
        SizedBox(height: 4.0),
        
        // Auth type badge
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Text(
            _getAuthTypeDisplayName(user.authType),
            style: TextStyle(
              color: Colors.white,
              fontSize: 11.0,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
  
  /// Build anonymous ferret header
  Widget _buildAnonymousFerretHeader() {
    return Column(
      children: [
        // Ferret avatar
        CircleAvatar(
          radius: 28.0,
          backgroundColor: Colors.white.withOpacity(0.2),
          child: Icon(Icons.pets, size: 30.0, color: Colors.white),
        ),
        
        SizedBox(height: 8.0),
        
        // Ferret name
        Text(
          'Anonymous Ferret',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        
        SizedBox(height: 4.0),
        
        // Anonymous badge
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Text(
            'Private Mode',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11.0,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
  
  /// Build network status indicator
  Widget _buildNetworkStatus() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8.0,
            height: 8.0,
            decoration: BoxDecoration(
              color: Colors.greenAccent,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 6.0),
          Text(
            'FER Network Connected',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10.0,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  /// Build menu items list
  Widget _buildMenuItems() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Core applications section
          _buildMenuSectionHeader('Applications'),
          
          _buildMenuItem(
            icon: Icons.chat,
            title: 'FERChat',
            subtitle: 'Messages & Calls',
            appType: FERAppType.chat,
            isActive: widget.currentApp == FERAppType.chat,
            badgeCount: _unreadMessageCount,
            badgeColor: FERColors.accent,
          ),
          
          _buildMenuItem(
            icon: Icons.folder_shared,
            title: 'FERExplorer',
            subtitle: 'File Management',
            appType: FERAppType.explorer,
            isActive: widget.currentApp == FERAppType.explorer,
            badgeCount: _pendingTransferCount,
            badgeColor: Colors.orange,
          ),
          
          _buildMenuItem(
            icon: Icons.sports_esports,
            title: 'FERGame',
            subtitle: 'Gaming Platform',
            appType: FERAppType.game,
            isActive: widget.currentApp == FERAppType.game,
            badgeCount: _activeGameCount,
            badgeColor: Colors.purple,
          ),
          
          SizedBox(height: 16.0),
          
          // System section
          _buildMenuSectionHeader('System'),
          
          _buildMenuItem(
            icon: Icons.settings,
            title: 'Settings',
            subtitle: 'Preferences & Configuration',
            appType: FERAppType.settings,
            isActive: widget.currentApp == FERAppType.settings,
          ),
          
          _buildMenuItem(
            icon: Icons.security,
            title: 'Security',
            subtitle: 'Privacy & Authentication',
            appType: FERAppType.security,
            isActive: widget.currentApp == FERAppType.security,
          ),
          
          _buildMenuItem(
            icon: Icons.info,
            title: 'About',
            subtitle: 'FER Network Information',
            appType: FERAppType.about,
            isActive: widget.currentApp == FERAppType.about,
          ),
          
          SizedBox(height: 16.0),
          
          // Account section
          _buildMenuSectionHeader('Account'),
          
          if (widget.userProfile == null)
            _buildMenuItem(
              icon: Icons.login,
              title: 'Connect Wallet',
              subtitle: 'Sign in with blockchain wallet',
              appType: FERAppType.walletAuth,
              isActive: false,
              isHighlight: true,
            )
          else
            _buildMenuItem(
              icon: Icons.logout,
              title: 'Sign Out',
              subtitle: 'Disconnect from FER Network',
              appType: FERAppType.signout,
              isActive: false,
              isDestructive: true,
            ),
        ],
      ),
    );
  }
  
  /// Build menu section header
  Widget _buildMenuSectionHeader(String title) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Theme.of(context).textTheme.caption?.color,
          fontSize: 11.0,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
  
  /// Build individual menu item
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required FERAppType appType,
    required bool isActive,
    int badgeCount = 0,
    Color badgeColor = FERColors.accent,
    bool isHighlight = false,
    bool isDestructive = false,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleMenuItemTap(appType),
          borderRadius: BorderRadius.circular(12.0),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: isActive 
                ? FERColors.primary.withOpacity(0.1)
                : isHighlight
                  ? FERColors.primary.withOpacity(0.05)
                  : isDestructive
                    ? Colors.red.withOpacity(0.05)
                    : Colors.transparent,
              borderRadius: BorderRadius.circular(12.0),
              border: isActive 
                ? Border.all(color: FERColors.primary, width: 1.5)
                : isHighlight
                  ? Border.all(color: FERColors.primary.withOpacity(0.3), width: 1)
                  : null,
            ),
            child: Row(
              children: [
                // Icon container
                Container(
                  width: 44.0,
                  height: 44.0,
                  decoration: BoxDecoration(
                    color: isActive 
                      ? FERColors.primary
                      : isDestructive
                        ? Colors.red.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Icon(
                    icon,
                    size: 22.0,
                    color: isActive 
                      ? Colors.white
                      : isDestructive
                        ? Colors.red
                        : Theme.of(context).iconTheme.color,
                  ),
                ),
                
                SizedBox(width: 16.0),
                
                // Title and subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w600,
                          color: isActive 
                            ? FERColors.primary
                            : isDestructive
                              ? Colors.red
                              : Theme.of(context).textTheme.titleLarge?.color,
                        ),
                      ),
                      SizedBox(height: 2.0),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Badge
                if (badgeCount > 0) ...[
                  SizedBox(width: 8.0),
                  Container(
                    constraints: BoxConstraints(
                      minWidth: 20.0,
                      minHeight: 20.0,
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Text(
                      badgeCount > 99 ? '99+' : badgeCount.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.0,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
                
                // Arrow indicator
                if (!isDestructive)
                  Icon(
                    Icons.chevron_right,
                    size: 20.0,
                    color: Theme.of(context).iconTheme.color?.withOpacity(0.4),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  /// Build menu footer with system info
  Widget _buildMenuFooter() {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        children: [
          // Network frequency indicator
          _buildFrequencyIndicator(),
          
          SizedBox(height: 8.0),
          
          // Version info
          Text(
            'FER Network v1.0.0',
            style: TextStyle(
              color: Theme.of(context).textTheme.caption?.color,
              fontSize: 10.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          
          SizedBox(height: 4.0),
          
          Text(
            'Quantum-Secured • Decentralized',
            style: TextStyle(
              color: Theme.of(context).textTheme.caption?.color?.withOpacity(0.7),
              fontSize: 9.0,
            ),
          ),
        ],
      ),
    );
  }
  
  /// Build frequency hopping indicator
  Widget _buildFrequencyIndicator() {
    return FutureBuilder<double>(
      future: _getCurrentFrequency(),
      builder: (context, snapshot) {
        final frequency = snapshot.data ?? 2.4;
        
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
          decoration: BoxDecoration(
            color: FERColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.wifi,
                size: 14.0,
                color: FERColors.primary,
              ),
              SizedBox(width: 6.0),
              Text(
                '${frequency.toStringAsFixed(1)} GHz',
                style: TextStyle(
                  color: FERColors.primary,
                  fontSize: 10.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  /// Handle menu item tap
  void _handleMenuItemTap(FERAppType appType) {
    switch (appType) {
      case FERAppType.signout:
        _showSignOutConfirmation();
        break;
      case FERAppType.walletAuth:
        // Trigger wallet authentication
        break;
      default:
        widget.onAppSelected(appType);
        _closeMenu();
    }
  }
  
  /// Show sign out confirmation dialog
  void _showSignOutConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sign Out'),
          content: Text('Are you sure you want to sign out from FER Network?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onAppSelected(FERAppType.signout);
                _closeMenu();
              },
              child: Text('Sign Out', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
  
  /// Toggle menu open/close
  void _toggleMenu(bool open) {
    if (open && !_isMenuOpen) {
      _openMenu();
    } else if (!open && _isMenuOpen) {
      _closeMenu();
    }
  }
  
  /// Open menu
  void _openMenu() {
    setState(() {
      _isMenuOpen = true;
    });
    _animationController.forward();
    widget.onMenuToggle?.call();
  }
  
  /// Close menu
  void _closeMenu() {
    setState(() {
      _isMenuOpen = false;
    });
    _animationController.reverse();
    widget.onMenuToggle?.call();
  }
  
  /// Get current frequency from frequency hopping service
  Future<double> _getCurrentFrequency() async {
    try {
      final freqService = FERFrequencyHopping.instance;
      return freqService.getCurrentFrequency();
    } catch (e) {
      return 2.4; // Default frequency
    }
  }
  
  /// Get display name for auth type
  String _getAuthTypeDisplayName(AiFERiDAuthType authType) {
    switch (authType) {
      case AiFERiDAuthType.wallet:
        return 'Wallet Authenticated';
      case AiFERiDAuthType.anonymousFerret:
        return 'Anonymous Access';
      case AiFERiDAuthType.multiFactor:
        return 'Multi-Factor Auth';
      case AiFERiDAuthType.biometric:
        return 'Biometric Auth';
    }
  }
  
  /// Load badge counts
  void _loadBadgeCounts() {
    // Simulate loading badge counts
    _unreadMessageCount = 3;
    _pendingTransferCount = 1;
    _activeGameCount = 2;
  }
  
  /// Setup real-time updates for badges
  void _setupRealtimeUpdates() {
    // In real implementation, listen to database changes or network updates
    Timer.periodic(Duration(seconds: 30), (timer) {
      _loadBadgeCounts();
      if (mounted) setState(() {});
    });
  }
}

/// FER application types
enum FERAppType {
  chat,
  explorer,
  game,
  settings,
  security,
  about,
  walletAuth,
  signout,
}

/// FER color scheme
class FERColors {
  static const Color primary = Color(0xFF00FF88);
  static const Color primaryDark = Color(0xFF00CC66);
  static const Color accent = Color(0xFFFF006E);
  static const Color secondary = Color(0xFF00CCFF);
  static const Color background = Color(0xFF1A1A1A);
  static const Color surface = Color(0xFF2A2A2A);
}
]]>