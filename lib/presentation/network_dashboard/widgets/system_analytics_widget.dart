import 'package:flutter/material.dart';
import '../../../core/color_polyfill.dart';
import 'package:sizer/sizer.dart';

import '../../../services/unified_supabase_service.dart';
import '../../../theme/app_theme.dart';

class SystemAnalyticsWidget extends StatefulWidget {
  const SystemAnalyticsWidget({super.key});

  @override
  State<SystemAnalyticsWidget> createState() => _SystemAnalyticsWidgetState();
}

class _SystemAnalyticsWidgetState extends State<SystemAnalyticsWidget> {
  final UnifiedSupabaseService _supabaseService =
      UnifiedSupabaseService.instance;
  Map<String, dynamic>? _analyticsData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    try {
      if (!_supabaseService.isAuthenticated) {
        setState(() {
          _analyticsData = {
            'message': 'Sign in to view detailed analytics',
            'authenticated': false,
          };
          _isLoading = false;
        });
        return;
      }

      final currentUser = _supabaseService.getCurrentUser();
      if (currentUser == null) {
        throw Exception('User not found');
      }

      // Fetch analytics data using existing methods
      final totalTodos = await _supabaseService.getCount('todos', filters: {'user_id': currentUser.id});
      final completedTodos = await _supabaseService.getCount('todos', filters: {'user_id': currentUser.id, 'completed': true});
      final conversations = await _supabaseService.getCount('ferchat_conversations', filters: {'user_id': currentUser.id});
      final wallets = await _supabaseService.getCount('fer_wallets', filters: {'user_id': currentUser.id});
      
      final completionRate = totalTodos > 0 ? ((completedTodos / totalTodos) * 100).round() : 0;

      if (mounted) {
        setState(() {
          _analyticsData = {
            'total_todos': totalTodos,
            'completed_todos': completedTodos,
            'conversations': conversations,
            'wallets': wallets,
            'completion_rate': completionRate,
            'last_updated': DateTime.now().toIso8601String(),
            'authenticated': true,
            'user_id': currentUser.id,
            'user_email': currentUser.email,
          };
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _analyticsData = {
            'error': e.toString(),
            'authenticated': false,
          };
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.surfaceDark.withValues(alpha: 0.8)
            : AppTheme.surfaceLight.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.accentColor.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentColor.withValues(alpha: 0.1),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.analytics_outlined,
                  color: AppTheme.accentColor,
                  size: 5.w,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'System Analytics',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppTheme.textPrimaryDark
                            : AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      'Real-time database insights',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppTheme.textSecondaryDark
                            : AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (_isLoading)
                SizedBox(
                  width: 5.w,
                  height: 5.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.accentColor,
                  ),
                ),
            ],
          ),
          SizedBox(height: 3.h),
          if (_isLoading)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 4.h),
                child: Column(
                  children: [
                    CircularProgressIndicator(
                      color: AppTheme.accentColor,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Loading analytics...',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? AppTheme.textSecondaryDark
                            : AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (_analyticsData == null)
            _buildErrorState(theme, isDark, 'Failed to load analytics data')
          else if (_analyticsData!['authenticated'] == false)
            _buildUnauthenticatedState(theme, isDark)
          else
            _buildAnalyticsGrid(theme, isDark),
        ],
      ),
    );
  }

  Widget _buildAnalyticsGrid(ThemeData theme, bool isDark) {
    final stats = [
      {
        'title': 'Total Tasks',
        'value': _analyticsData!['total_todos']?.toString() ?? '0',
        'icon': Icons.task_alt,
        'color': AppTheme.accentColor,
      },
      {
        'title': 'Completed',
        'value': _analyticsData!['completed_todos']?.toString() ?? '0',
        'icon': Icons.check_circle,
        'color': AppTheme.successColor,
      },
      {
        'title': 'Conversations',
        'value': _analyticsData!['conversations']?.toString() ?? '0',
        'icon': Icons.chat_bubble_outline,
        'color': AppTheme.accentColor,
      },
      {
        'title': 'Wallets',
        'value': _analyticsData!['wallets']?.toString() ?? '0',
        'icon': Icons.account_balance_wallet,
        'color': AppTheme.warningColor,
      },
    ];

    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 3.w,
            mainAxisSpacing: 2.h,
            childAspectRatio: 1.2,
          ),
          itemCount: stats.length,
          itemBuilder: (context, index) {
            final stat = stats[index];
            return _buildAnalyticsCard(
              stat['title'] as String,
              stat['value'] as String,
              stat['icon'] as IconData,
              stat['color'] as Color,
              theme,
              isDark,
            );
          },
        ),

        SizedBox(height: 3.h),

        // Completion rate
        if (_analyticsData!['completion_rate'] != null)
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: isDark
                  ? AppTheme.backgroundDark.withValues(alpha: 0.3)
                  : AppTheme.backgroundLight.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Completion Rate',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppTheme.textPrimaryDark
                            : AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      '${_analyticsData!['completion_rate']}%',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.successColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                LinearProgressIndicator(
                  value: (_analyticsData!['completion_rate'] ?? 0) / 100.0,
                  backgroundColor: isDark
                      ? AppTheme.textSecondaryDark.withValues(alpha: 0.2)
                      : AppTheme.textSecondary.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation(AppTheme.successColor),
                  minHeight: 0.8.h,
                ),
              ],
            ),
          ),

        SizedBox(height: 2.h),

        // Last updated
        Text(
          'Last updated: ${_formatTimestamp(_analyticsData!['last_updated'])}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: isDark
                ? AppTheme.textSecondaryDark.withValues(alpha: 0.7)
                : AppTheme.textSecondary.withValues(alpha: 0.7),
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsCard(
    String title,
    String value,
    IconData icon,
    Color color,
    ThemeData theme,
    bool isDark,
  ) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 6.w,
            color: color,
          ),
          SizedBox(height: 1.h),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
              color:
                  isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnauthenticatedState(ThemeData theme, bool isDark) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.accentColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.accentColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.login,
            size: 12.w,
            color: AppTheme.accentColor,
          ),
          SizedBox(height: 2.h),
          Text(
            'Sign In Required',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.accentColor,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Please sign in to view detailed system analytics and user statistics.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color:
                  isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: 3.h),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/google-authentication-setup');
            },
            icon: Icon(Icons.login, size: 4.w),
            label: Text('Sign In'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: 6.w,
                vertical: 1.5.h,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, bool isDark, String message) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.errorColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 12.w,
            color: AppTheme.errorColor,
          ),
          SizedBox(height: 2.h),
          Text(
            'Analytics Unavailable',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.errorColor,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color:
                  isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: 3.h),
          ElevatedButton.icon(
            onPressed: _loadAnalytics,
            icon: Icon(Icons.refresh, size: 4.w),
            label: Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: 6.w,
                vertical: 1.5.h,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(String? timestamp) {
    if (timestamp == null) return 'Unknown';

    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else {
        return '${difference.inDays}d ago';
      }
    } catch (e) {
      return 'Unknown';
    }
  }
}
