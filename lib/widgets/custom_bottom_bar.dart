import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../core/app_export.dart';
import '../services/google_auth_service.dart';

class CustomBottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isAdmin = GoogleAuthService.instance.isAdmin();

    return Container(
      height: 12.h,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(6.w)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildNavItem(
            context,
            icon: Icons.dashboard_outlined,
            activeIcon: Icons.dashboard,
            label: 'Dashboard',
            index: 0,
            route: AppRoutes.networkDashboard,
          ),
          _buildNavItem(
            context,
            icon: Icons.chat_outlined,
            activeIcon: Icons.chat,
            label: 'Chat',
            index: 1,
            route: AppRoutes.messagingInterface,
          ),
          _buildNavItem(
            context,
            icon: Icons.account_balance_wallet_outlined,
            activeIcon: Icons.account_balance_wallet,
            label: 'Wallets',
            index: 2,
            route: AppRoutes.blockchainWalletManager,
          ),
          _buildNavItem(
            context,
            icon: Icons.explore_outlined,
            activeIcon: Icons.explore,
            label: 'Explore',
            index: 3,
            route: AppRoutes.ferexplorer,
          ),
          if (isAdmin)
            _buildNavItem(
              context,
              icon: Icons.admin_panel_settings_outlined,
              activeIcon: Icons.admin_panel_settings,
              label: 'Admin',
              index: 4,
              route: AppRoutes.adminPanelDashboard,
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
  }) {
    final isActive = currentIndex == index;
    final isAdmin = GoogleAuthService.instance.isAdmin();
    final itemCount = isAdmin ? 5 : 4;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (currentIndex != index) {
            Navigator.pushReplacementNamed(context, route);
          }
          onTap(index);
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 1.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: isActive
                      ? Color(0xFF6C63FF).withAlpha(26)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(2.w),
                ),
                child: Icon(
                  isActive ? activeIcon : icon,
                  color: isActive
                      ? Color(0xFF6C63FF)
                      : Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color
                          ?.withAlpha(153),
                  size: 6.w,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 10.sp,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive
                      ? Color(0xFF6C63FF)
                      : Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color
                          ?.withAlpha(153),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
