import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'dart:async'; // Add this import

import '../../core/app_export.dart';
// AiFER auth/data services are sourced via Phase-6 wiring; no import needed here yet.
import '../../services/google_auth_service.dart';
import '../../services/network_data_service.dart';
import '../../widgets/custom_app_bar.dart';
import './widgets/analytics_dashboard_widget.dart';
import './widgets/network_monitoring_widget.dart';
import './widgets/system_controls_widget.dart';
import './widgets/user_management_widget.dart';

class AdminPanelDashboard extends StatefulWidget {
  const AdminPanelDashboard({Key? key}) : super(key: key);

  @override
  State<AdminPanelDashboard> createState() => _AdminPanelDashboardState();
}

class _AdminPanelDashboardState extends State<AdminPanelDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  Map<String, dynamic> _adminStats = {};
  Map<String, dynamic> _networkStats = {};

  // Real-time data refresh
  bool _autoRefresh = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _initializeAdminPanel();

    // Auto-refresh every 30 seconds
    if (_autoRefresh) {
      _startAutoRefresh();
    }
  }

  void _startAutoRefresh() {
    Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted && _autoRefresh) {
        _refreshAdminData();
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _initializeAdminPanel() async {
    try {
      // Verify admin access
      final isAdmin = GoogleAuthService.instance.isAdmin();
      if (!isAdmin) {
        _redirectToAuth();
        return;
      }

      await _loadAdminData();
    } catch (e) {
      debugPrint('Admin panel initialization failed: $e');
      _showErrorDialog('Failed to initialize admin panel: $e');
    }
  }

  Future<void> _loadAdminData() async {
    setState(() => _isLoading = true);

    try {
      // Load comprehensive admin statistics
      final networkStats = await NetworkDataService.instance.getNetworkStats();
      // Conversation stats — will be sourced from OfflineFirstDatabase in Phase 6.
      final Map<String, dynamic> conversationStats = {
        'total_conversations': 0,
        'active_users': 0,
        'source': 'placeholder-phase6',
      };

      // Generate admin-specific metrics
      final adminMetrics = await _generateAdminMetrics();

      setState(() {
        _networkStats = networkStats;
        _adminStats = {
          ...conversationStats,
          ...adminMetrics,
          'last_updated': DateTime.now().toIso8601String(),
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Failed to load admin data: $e');
    }
  }

  Future<void> _refreshAdminData() async {
    await _loadAdminData();
  }

  Future<Map<String, dynamic>> _generateAdminMetrics() async {
    try {
      final user = GoogleAuthService.instance.getCurrentUser();
      return {
        'admin_user_email': user?.email ?? 'Unknown',
        'admin_login_time':
            user?.lastSignInAt ?? DateTime.now().toIso8601String(),
        'system_uptime': '99.8%',
        'security_level': 'Quantum Enhanced',
        'mesh_nodes_managed': _networkStats['active_nodes'] ?? 0,
        'total_package_throughput': '5.2TB',
        'fer_tokens_staked': '2,000,000 FER',
        'validator_efficiency': '97.5%',
      };
    } catch (e) {
      debugPrint('Failed to generate admin metrics: $e');
      return {};
    }
  }

  void _redirectToAuth() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacementNamed(
          context, AppRoutes.googleAuthenticationSetup);
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Admin Panel Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacementNamed(
                  context, AppRoutes.networkDashboard);
            },
            child: const Text('Back to Dashboard'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _autoRefresh = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundLight,
        appBar: _buildAppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppTheme.primaryLight),
              ),
              SizedBox(height: 16),
              Text(
                'Loading Admin Panel...',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Verifying administrator privileges',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildAdminHeader(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                NetworkMonitoringWidget(
                  networkStats: _networkStats,
                  onRefresh: _refreshAdminData,
                ),
                UserManagementWidget(
                  userStats: _adminStats,
                  recentActivity: [],
                  onRefresh: _refreshAdminData,
                ),
                AnalyticsDashboardWidget(
                  networkStats: _networkStats,
                  userStats: _adminStats,
                  onExportData: _refreshAdminData,
                ),
                SystemControlsWidget(
                  onEmergencyBroadcast: _refreshAdminData,
                  onNetworkConfiguration: _refreshAdminData,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return CustomAppBar(
      title: "AiFER Admin Panel",
      actions: [
        IconButton(
          icon: Icon(
            _autoRefresh ? Icons.sync_rounded : Icons.sync_disabled_rounded,
            color: _autoRefresh ? AppTheme.primaryLight : Colors.grey,
            size: 22,
          ),
          onPressed: () {
            setState(() => _autoRefresh = !_autoRefresh);
            if (_autoRefresh) _startAutoRefresh();
          },
        ),
        IconButton(
          icon: Icon(
            Icons.refresh_rounded,
            color: AppTheme.primaryLight,
            size: 22,
          ),
          onPressed: _refreshAdminData,
        ),
        SizedBox(width: 8),
      ],
    );
  }

  Widget _buildAdminHeader() {
    final user = GoogleAuthService.instance.getCurrentUser();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.red.withAlpha(13),
            Colors.orange.withAlpha(13),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.red.withAlpha(51),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.red.withAlpha(26),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.security_rounded,
              color: Colors.red,
              size: 28,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Administrator Access',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.red,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  user?.email ?? 'admin@aifer.network',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Last login: ${_formatDateTime(user?.lastSignInAt)}',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withAlpha(26),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green.withAlpha(77)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 6),
                Text(
                  'ACTIVE',
                  style: TextStyle(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        tabs: [
          Tab(
            icon: Icon(Icons.analytics_rounded, size: 20),
            text: 'Stats',
          ),
          Tab(
            icon: Icon(Icons.network_check_rounded, size: 20),
            text: 'Network',
          ),
          Tab(
            icon: Icon(Icons.people_rounded, size: 20),
            text: 'Users',
          ),
          Tab(
            icon: Icon(Icons.dashboard_rounded, size: 20),
            text: 'Analytics',
          ),
          Tab(
            icon: Icon(Icons.settings_rounded, size: 20),
            text: 'System',
          ),
        ],
        indicator: BoxDecoration(
          color: AppTheme.primaryLight,
          borderRadius: BorderRadius.circular(10),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[600],
        labelStyle: TextStyle(
          fontSize: 9.sp,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 9.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null) return 'Just now';
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else {
        return '${difference.inDays}d ago';
      }
    } catch (e) {
      return 'Recently';
    }
  }
}