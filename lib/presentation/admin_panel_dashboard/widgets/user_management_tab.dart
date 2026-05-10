import 'package:flutter/material.dart';
import '../../../core/color_polyfill.dart';
import 'package:sizer/sizer.dart';

import '../../../theme/app_theme.dart';

/// User Management Tab for admin dashboard
class UserManagementTab extends StatefulWidget {
  const UserManagementTab({super.key});

  @override
  State<UserManagementTab> createState() => _UserManagementTabState();
}

class _UserManagementTabState extends State<UserManagementTab> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'all';

  final List<Map<String, dynamic>> _mockUsers = [
    {
      'id': '1',
      'name': 'FER Demo User',
      'email': 'demo@fernetwork.nl',
      'role': 'user',
      'status': 'active',
      'walletAddress': '0x1234...5678',
      'lastSignIn': '2 hours ago',
      'provider': 'email',
    },
    {
      'id': '2',
      'name': 'FER Network Admin',
      'email': 'bouncingferretofficial@gmail.com',
      'role': 'admin',
      'status': 'active',
      'walletAddress': '0xABCD...EFGH',
      'lastSignIn': 'Now',
      'provider': 'google',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with search and filters
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search users...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppTheme.accentColor),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              DropdownButton<String>(
                value: _selectedFilter,
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('All Users')),
                  DropdownMenuItem(value: 'admin', child: Text('Admins')),
                  DropdownMenuItem(value: 'user', child: Text('Users')),
                  DropdownMenuItem(value: 'active', child: Text('Active')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value!;
                  });
                },
                borderRadius: BorderRadius.circular(12),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Users List
          Expanded(
            child: ListView.separated(
              itemCount: _mockUsers.length,
              separatorBuilder: (context, index) => SizedBox(height: 2.h),
              itemBuilder: (context, index) {
                final user = _mockUsers[index];
                return _buildUserCard(user, isDark);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user, bool isDark) {
    final isAdmin = user['role'] == 'admin';
    final isCurrentUser = user['email'] == 'bouncingferretofficial@gmail.com';

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.surfaceDark.withValues(alpha: 0.3)
            : AppTheme.surfaceLight.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAdmin
              ? AppTheme.accentColor.withValues(alpha: 0.3)
              : Colors.grey.withValues(alpha: 0.2),
          width: isAdmin ? 2 : 1,
        ),
        boxShadow: isAdmin
            ? [
                BoxShadow(
                  color: AppTheme.accentColor.withValues(alpha: 0.1),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Header
          Row(
            children: [
              CircleAvatar(
                radius: 6.w,
                backgroundColor:
                    isAdmin ? AppTheme.accentColor : Colors.grey.shade400,
                child: Text(
                  user['name'].toString().split(' ').map((n) => n[0]).join(''),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.sp,
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          user['name'],
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13.sp,
                            color: isDark
                                ? AppTheme.textPrimaryDark
                                : AppTheme.textPrimary,
                          ),
                        ),
                        if (isAdmin) ...[
                          SizedBox(width: 2.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 2.w,
                              vertical: 0.5.w,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  AppTheme.accentColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'ADMIN',
                              style: TextStyle(
                                color: AppTheme.accentColor,
                                fontSize: 8.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                        if (isCurrentUser) ...[
                          SizedBox(width: 2.w),
                          Icon(
                            Icons.person,
                            color: AppTheme.accentColor,
                            size: 4.w,
                          ),
                        ],
                      ],
                    ),
                    Text(
                      user['email'],
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: isDark
                            ? AppTheme.textSecondaryDark
                            : AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(user['status'], isDark),
            ],
          ),

          SizedBox(height: 2.h),

          // User Details
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  'Provider',
                  user['provider'],
                  Icons.login,
                  isDark,
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  'Last Sign In',
                  user['lastSignIn'],
                  Icons.access_time,
                  isDark,
                ),
              ),
            ],
          ),

          SizedBox(height: 1.h),

          _buildDetailItem(
            'Wallet Address',
            user['walletAddress'],
            Icons.account_balance_wallet,
            isDark,
            fullWidth: true,
          ),

          if (!isCurrentUser) ...[
            SizedBox(height: 2.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showUserDetails(user),
                    icon: Icon(Icons.visibility, size: 4.w),
                    label: Text('View Details'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.accentColor,
                      side: BorderSide(color: AppTheme.accentColor),
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showUserActions(user),
                    icon: Icon(Icons.more_horiz, size: 4.w),
                    label: Text('Actions'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange,
                      side: BorderSide(color: Colors.orange),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status, bool isDark) {
    final color = status == 'active' ? AppTheme.successColor : Colors.orange;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 2.w,
        vertical: 1.w,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.circle,
            color: color,
            size: 2.w,
          ),
          SizedBox(width: 1.w),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 8.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(
    String label,
    String value,
    IconData icon,
    bool isDark, {
    bool fullWidth = false,
  }) {
    return Container(
      padding: EdgeInsets.all(2.w),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppTheme.accentColor,
            size: 3.5.w,
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 8.sp,
                    color: isDark
                        ? AppTheme.textSecondaryDark
                        : AppTheme.textSecondary,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppTheme.textPrimaryDark
                        : AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showUserDetails(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('User Details: ${user['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${user['email']}'),
            Text('Role: ${user['role']}'),
            Text('Status: ${user['status']}'),
            Text('Provider: ${user['provider']}'),
            Text('Wallet: ${user['walletAddress']}'),
            Text('Last Sign In: ${user['lastSignIn']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showUserActions(Map<String, dynamic> user) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'User Actions: ${user['name']}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            SizedBox(height: 2.h),
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Edit User Role'),
              onTap: () {
                Navigator.pop(context);
                // Implement role editing
              },
            ),
            ListTile(
              leading: Icon(Icons.block, color: Colors.orange),
              title: Text('Suspend User'),
              onTap: () {
                Navigator.pop(context);
                // Implement user suspension
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: AppTheme.errorColor),
              title: Text('Delete User'),
              onTap: () {
                Navigator.pop(context);
                // Implement user deletion with confirmation
              },
            ),
          ],
        ),
      ),
    );
  }
}
