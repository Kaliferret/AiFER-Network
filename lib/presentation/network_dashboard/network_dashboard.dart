import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_bottom_bar.dart';

/// FER Network — Dashboard
///
/// Base44-style mobile dashboard:
///  ┌────────────────────────────────────────────────┐
///  │ ☰    Dashboard              🔍   🔔            │
///  ├────────────────────────────────────────────────┤
///  │ ┌ WELCOME BACK ───────────────────────────────┐│
///  │ │ [avatar] Semi                  ⚙ Customize  ││
///  │ │ ● Online    Friday, May 8, 2026             ││
///  │ │                                              ││
///  │ │ Mood 👍🎨😊🎯 │ ★ Level 11 │ 🔥 Streak 7d  ││
///  │ │ 🎨 NFTs 0                                    ││
///  │ └──────────────────────────────────────────────┘│
///  │                                                 │
///  │ [💬 New Message] [🛒 Browse Market]             │
///  │ [🎮 Play Games ] [✨ AI Assistant]              │
///  │                                                 │
///  │ ┌ 🟧 FER Balance           1.104 FER ─────────┐│
///  │ ┌ 🟦 Unread Messages            3 ───────────┐│
///  └────────────────────────────────────────────────┘
class NetworkDashboard extends StatefulWidget {
  const NetworkDashboard({super.key});

  @override
  State<NetworkDashboard> createState() => _NetworkDashboardState();
}

class _NetworkDashboardState extends State<NetworkDashboard> {
  int _bottomIndex = 0;

  // Placeholder profile — will be wired to AiFERiDAuthService in Phase 5
  final String _displayName = 'Semi';
  final String _avatarEmoji = '🦊'; // red-avatar ferret placeholder
  final bool _isOnline = true;

  // Placeholder gamification stats — wired in Phase 6
  final int _level = 11;
  final int _streakDays = 7;
  final int _nftCount = 0;
  final int _selectedMoodIndex = 0;

  // Placeholder wallet / messaging stats — wired in Phase 4/6
  final double _ferBalance = 1.104;
  final int _unreadMessages = 3;

  static const _moods = ['👍', '🎨', '😊', '🎯'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 4.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildWelcomeCard(),
              SizedBox(height: 3.h),
              _buildActionTilesGrid(),
              SizedBox(height: 3.h),
              _buildBalanceCard(),
              SizedBox(height: 2.h),
              _buildUnreadCard(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _bottomIndex,
        onTap: (i) => setState(() => _bottomIndex = i),
      ),
    );
  }

  // ── App bar ────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.background,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.menu_rounded),
        onPressed: () => Scaffold.of(context).openDrawer(),
      ),
      title: const Text('Dashboard'),
      centerTitle: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.search_rounded),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.notifications_none_rounded),
          onPressed: () {},
        ),
        SizedBox(width: 1.w),
      ],
    );
  }

  // ── Welcome card ───────────────────────────────────────────
  Widget _buildWelcomeCard() {
    return Container(
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.surfaceElevated, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar + name + customize
          Row(
            children: [
              _buildAvatar(),
              SizedBox(width: 4.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WELCOME BACK',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      _displayName,
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              _buildCustomizeButton(),
            ],
          ),
          SizedBox(height: 2.h),
          // Online + date
          Row(
            children: [
              _buildOnlinePill(),
              SizedBox(width: 3.w),
              Text(
                _formattedDate(),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.5.h),
          // Stats grid
          _buildStatsRow(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 16.w,
      height: 16.w,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.accent.withValues(alpha: 0.9), AppTheme.tilePink],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accent.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(_avatarEmoji, style: TextStyle(fontSize: 28.sp)),
    );
  }

  Widget _buildCustomizeButton() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.divider, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.settings_rounded,
              size: 14.sp, color: AppTheme.textSecondary),
          SizedBox(width: 1.5.w),
          Text('Customize',
              style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildOnlinePill() {
    final isOn = _isOnline;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
      decoration: BoxDecoration(
        color: isOn
            ? AppTheme.successColor.withValues(alpha: 0.15)
            : AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 2.w,
            height: 2.w,
            decoration: BoxDecoration(
              color: isOn ? AppTheme.successColor : AppTheme.textTertiary,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 1.5.w),
          Text(
            isOn ? 'Online' : 'Offline',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: isOn ? AppTheme.successColor : AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _formattedDate() {
    final d = DateTime.now();
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${days[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  // ── Stats row ───────────────────────────────────────────────
  Widget _buildStatsRow() {
    return Wrap(
      spacing: 2.w,
      runSpacing: 1.5.h,
      children: [
        _buildMoodChip(),
        _buildStatChip(
          icon: Icons.star_rounded,
          iconColor: const Color(0xFFFBBF24),
          label: 'Level',
          value: '$_level',
        ),
        _buildStatChip(
          icon: Icons.local_fire_department_rounded,
          iconColor: const Color(0xFFF97316),
          label: 'Streak',
          value: '$_streakDays days',
        ),
        _buildStatChip(
          icon: Icons.palette_rounded,
          iconColor: AppTheme.tilePurple,
          label: 'NFTs',
          value: '$_nftCount',
        ),
      ],
    );
  }

  Widget _buildMoodChip() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.2.h),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Mood:',
              style: TextStyle(
                  fontSize: 11.sp,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500)),
          SizedBox(width: 2.w),
          ...List.generate(_moods.length, (i) {
            final selected = i == _selectedMoodIndex;
            return Padding(
              padding: EdgeInsets.only(right: 1.w),
              child: Container(
                width: 7.w,
                height: 7.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected
                      ? AppTheme.background
                      : AppTheme.surface.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: selected
                      ? Border.all(color: AppTheme.primary, width: 1)
                      : null,
                ),
                child: Text(_moods[i], style: TextStyle(fontSize: 14.sp)),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatChip(
      {required IconData icon,
      required Color iconColor,
      required String label,
      required String value}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.2.h),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18.sp, color: iconColor),
          SizedBox(width: 2.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 10.sp,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500)),
              Text(value,
                  style: TextStyle(
                      fontSize: 13.sp,
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                      height: 1.1)),
            ],
          ),
        ],
      ),
    );
  }

  // ── Four action tiles ──────────────────────────────────────
  Widget _buildActionTilesGrid() {
    final tiles = <_ActionTile>[
      _ActionTile(
        label: 'New\nMessage',
        icon: Icons.chat_bubble_rounded,
        color: AppTheme.tileBlue,
        onTap: () =>
            Navigator.pushNamed(context, AppRoutes.messagingInterface),
      ),
      _ActionTile(
        label: 'Browse\nMarket',
        icon: Icons.shopping_bag_rounded,
        color: AppTheme.tilePink,
        onTap: () {
          // Phase 6 — market screen
        },
      ),
      _ActionTile(
        label: 'Play\nGames',
        icon: Icons.sports_esports_rounded,
        color: AppTheme.tileGreen,
        onTap: () => Navigator.pushNamed(context, AppRoutes.gamingHub),
      ),
      _ActionTile(
        label: 'AI\nAssistant',
        icon: Icons.auto_awesome_rounded,
        color: AppTheme.tilePurple,
        onTap: () {
          // Phase 6 — AI assistant screen
        },
      ),
    ];
    return Row(
      children: tiles
          .map((t) => Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 1.w),
                  child: _buildActionTile(t),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildActionTile(_ActionTile t) {
    return TapScale(
      onTap: t.onTap,
      semanticsLabel: t.label,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 2.w),
        decoration: BoxDecoration(
          color: t.color,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: t.color.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(t.icon, color: Colors.white, size: 22.sp),
            SizedBox(height: 1.h),
            Text(
              t.label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Balance card ────────────────────────────────────────────
  Widget _buildBalanceCard() {
    return TapScale(
      onTap: () =>
          Navigator.pushNamed(context, AppRoutes.blockchainWalletManager),
      semanticsLabel: 'Open wallet',
      child: Container(
        padding: EdgeInsets.all(5.w),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.surfaceElevated, width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(2.5.w),
              decoration: BoxDecoration(
                color: AppTheme.balanceOrange,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.account_balance_wallet_rounded,
                  color: Colors.white, size: 22.sp),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _ferBalance.toStringAsFixed(3),
                    style: TextStyle(
                      fontSize: 30.sp,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                      height: 1.0,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    'FER Balance',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: AppTheme.textTertiary, size: 22.sp),
          ],
        ),
      ),
    );
  }

  // ── Unread messages card ───────────────────────────────────
  Widget _buildUnreadCard() {
    return TapScale(
      onTap: () =>
          Navigator.pushNamed(context, AppRoutes.messagingInterface),
      semanticsLabel: 'Open messages',
      child: Container(
        padding: EdgeInsets.all(5.w),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.surfaceElevated, width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.5.w),
              decoration: BoxDecoration(
                color: AppTheme.tileBlue,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.chat_bubble_rounded,
                  color: Colors.white, size: 22.sp),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$_unreadMessages',
                    style: TextStyle(
                      fontSize: 30.sp,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                      height: 1.0,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    'Unread Messages',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: AppTheme.textTertiary, size: 22.sp),
          ],
        ),
      ),
    );
  }
}

class _ActionTile {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  _ActionTile(
      {required this.label,
      required this.icon,
      required this.color,
      required this.onTap});
}
