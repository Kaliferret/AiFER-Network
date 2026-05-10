import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/aiferid_auth_service.dart';
import '../../services/theme_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';

class DeviceSettingsScreen extends StatefulWidget {
  const DeviceSettingsScreen({super.key});

  @override
  State<DeviceSettingsScreen> createState() => _DeviceSettingsScreenState();
}

class _DeviceSettingsScreenState extends State<DeviceSettingsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final AiFERiDAuthService _authService = AiFERiDAuthService.instance;

  // Add ThemeService getter
  ThemeService get _themeService => ThemeService.instance;

  // Device settings state
  bool _meshNetworkEnabled = true;
  bool _blockchainSyncEnabled = true;
  bool _emergencyModeEnabled = false;
  bool _autoDiscoveryEnabled = true;
  bool _batterySaverMode = false;
  bool _quantumEncryption = true;
  bool _voiceCommands = false;
  bool _biometricAuth = true;

  // Network settings
  String _selectedFrequency = '2.4GHz';
  double _transmissionPower = 75.0;
  int _maxConnections = 10;
  String _nodeRole = 'mesh_node';

  // Gaming settings
  bool _gamingModeEnabled = false;
  bool _lowLatencyMode = false;
  double _gamingPriority = 50.0;

  // Security settings
  bool _autoLockEnabled = true;
  int _lockTimeoutMinutes = 5;
  bool _remoteWipeEnabled = false;
  bool _isDeveloperMode = false;

  final List<String> _availableFrequencies = [
    '2.4GHz',
    '5GHz',
    '6GHz',
    'Multi-band'
  ];
  final List<String> _nodeRoles = [
    'mesh_node',
    'gateway',
    'relay',
    'edge_node'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadDeviceSettings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadDeviceSettings() {
    // Simulate loading device settings
    // In real app, this would load from Supabase
    setState(() {
      // Settings already initialized above
    });
  }

  Future<void> _saveSettings() async {
    try {
      // In real app, save to Supabase device_settings table
      Fluttertoast.showToast(
        msg: "Settings saved to AiFER Network",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to save settings: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  Future<void> _askChad(String query) async {
    try {
      final deviceInfo = {
        'mesh_enabled': _meshNetworkEnabled,
        'frequency': _selectedFrequency,
        'power': _transmissionPower,
        'role': _nodeRole,
      };

      // Device-settings AI assistant — wired in Phase 6.
      debugPrint('device-settings query="$query" info=$deviceInfo');
      _showChadDialog(
        'The device-settings assistant will be wired up in Phase 6 '
        '(backed by FER Network\'s own inference stack, no OpenAI).',
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Assistant unavailable: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  void _showChadDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIconWidget(
                iconName: 'smart_toy', color: AppTheme.accentColor, size: 24),
            SizedBox(width: 2.w),
            Text('Chad Assistant',
                style: TextStyle(color: AppTheme.accentColor)),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: AppTheme.accentColor)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Device Settings',
        showBackButton: true,
        actions: [
          IconButton(
            onPressed: _exportSettings,
            icon: CustomIconWidget(
              iconName: 'download',
              color: AppTheme.accentColor,
              size: 6.w,
            ),
            tooltip: 'Export Settings',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshSettings,
        color: AppTheme.accentColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Device info card
              _buildDeviceInfoCard(theme, isDark),

              SizedBox(height: 3.h),

              // Theme settings section
              _buildThemeSettingsSection(theme, isDark),

              SizedBox(height: 3.h),

              // Network settings
              _buildNetworkSettingsSection(theme, isDark),

              SizedBox(height: 3.h),

              // Privacy & Security
              _buildPrivacySecuritySection(theme, isDark),

              SizedBox(height: 3.h),

              // Performance settings
              _buildPerformanceSection(theme, isDark),

              SizedBox(height: 3.h),

              // Developer options
              if (_isDeveloperMode) _buildDeveloperSection(theme, isDark),

              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: 3, // Settings is index 3
        onTap: (index) {
          // Handle navigation tap
          setState(() {});
        },
      ),
    );
  }

  Widget _buildDeviceInfoCard(ThemeData theme, bool isDark) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.accentColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'device_info',
                color: AppTheme.accentColor,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'Device Information',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.accentColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoTile(
                  'Device ID',
                  'FER-${DateTime.now().millisecondsSinceEpoch.toRadixString(16).toUpperCase()}',
                  isDark,
                  theme),
              _buildInfoTile('AiFER Network Version', '2.1.0', isDark, theme),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoTile('FERMesh Protocol', 'v3.2.1', isDark, theme),
              _buildInfoTile('Last Sync',
                  '${DateTime.now().toString().split('.')[0]}', isDark, theme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSettingsSection(ThemeData theme, bool isDark) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.accentColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'palette',
                color: AppTheme.accentColor,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'Appearance Settings',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.accentColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          AnimatedBuilder(
            animation: _themeService,
            builder: (context, child) {
              return Column(
                children: [
                  _buildSettingTile(
                    'Dark Mode',
                    _themeService.themeMode == ThemeMode.system
                        ? 'Following system preference'
                        : 'Manual theme selection',
                    Switch.adaptive(
                      value: _themeService.themeMode == ThemeMode.dark,
                      onChanged: _themeService.themeMode == ThemeMode.system
                          ? null
                          : (value) => _themeService.setThemeMode(
                              value ? ThemeMode.dark : ThemeMode.light),
                      activeColor: AppTheme.accentColor,
                    ),
                    isDark,
                    theme,
                  ),
                  _buildSettingTile(
                    'Follow System Theme',
                    'Automatically match system appearance',
                    Switch.adaptive(
                      value: _themeService.themeMode == ThemeMode.system,
                      onChanged: (value) => _themeService.setThemeMode(
                          value ? ThemeMode.system : ThemeMode.light),
                      activeColor: AppTheme.accentColor,
                    ),
                    isDark,
                    theme,
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 2.h),
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.accentColor.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _themeService.themeMode == ThemeMode.system
                              ? Icons.brightness_auto
                              : (_themeService.themeMode == ThemeMode.dark
                                  ? Icons.dark_mode
                                  : Icons.light_mode),
                          color: AppTheme.accentColor,
                          size: 5.w,
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Current Theme',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppTheme.accentColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                _themeService.themeMode == ThemeMode.system
                                    ? 'System Default'
                                    : (_themeService.themeMode == ThemeMode.dark
                                        ? 'Dark Mode'
                                        : 'Light Mode'),
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: AppTheme.accentColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => _showThemeSelectionDialog(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentColor,
                            foregroundColor: AppTheme.primaryLight,
                            padding: EdgeInsets.symmetric(
                                horizontal: 4.w, vertical: 1.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child:
                              Text('Change', style: TextStyle(fontSize: 12.sp)),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  void _showThemeSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.palette, color: AppTheme.accentColor),
            SizedBox(width: 2.w),
            Text('Select Theme', style: TextStyle(color: AppTheme.accentColor)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeOption(
              'System Default',
              'Follow device settings',
              Icons.brightness_auto,
              ThemeMode.system,
              _themeService.themeMode == ThemeMode.system,
            ),
            SizedBox(height: 1.h),
            _buildThemeOption(
              'Light Mode',
              'Always use light theme',
              Icons.light_mode,
              ThemeMode.light,
              _themeService.themeMode == ThemeMode.light,
            ),
            SizedBox(height: 1.h),
            _buildThemeOption(
              'Dark Mode',
              'Always use dark theme',
              Icons.dark_mode,
              ThemeMode.dark,
              _themeService.themeMode == ThemeMode.dark,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                Text('Cancel', style: TextStyle(color: AppTheme.accentColor)),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    String title,
    String subtitle,
    IconData icon,
    ThemeMode mode,
    bool isSelected,
  ) {
    return InkWell(
      onTap: () {
        _themeService.setThemeMode(mode);
        Navigator.pop(context);
        Fluttertoast.showToast(
          msg: "Theme changed to $title",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.accentColor.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppTheme.accentColor
                : AppTheme.accentColor.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.accentColor : AppTheme.textSecondary,
              size: 6.w,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isSelected
                          ? AppTheme.accentColor
                          : AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: isSelected
                          ? AppTheme.accentColor
                          : AppTheme.textSecondary,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppTheme.accentColor,
                size: 5.w,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkSettingsSection(ThemeData theme, bool isDark) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.accentColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'network',
                color: AppTheme.accentColor,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'Network Settings',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.accentColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          _buildSettingTile(
            'Mesh Network',
            'Enable decentralized mesh networking',
            Switch.adaptive(
              value: _meshNetworkEnabled,
              onChanged: (value) => setState(() => _meshNetworkEnabled = value),
              activeColor: AppTheme.accentColor,
            ),
            isDark,
            theme,
          ),
          _buildSettingTile(
            'Blockchain Sync',
            'Synchronize with FERChain network',
            Switch.adaptive(
              value: _blockchainSyncEnabled,
              onChanged: (value) =>
                  setState(() => _blockchainSyncEnabled = value),
              activeColor: AppTheme.accentColor,
            ),
            isDark,
            theme,
          ),
          _buildSettingTile(
            'Auto Discovery',
            'Automatically discover nearby nodes',
            Switch.adaptive(
              value: _autoDiscoveryEnabled,
              onChanged: (value) =>
                  setState(() => _autoDiscoveryEnabled = value),
              activeColor: AppTheme.accentColor,
            ),
            isDark,
            theme,
          ),
          SizedBox(height: 3.h),
          _buildSectionHeader('Network Configuration', isDark, theme),
          _buildDropdownTile(
            'Frequency Band',
            'Select operating frequency',
            _selectedFrequency,
            _availableFrequencies,
            (value) => setState(() => _selectedFrequency = value!),
            isDark,
            theme,
          ),
          _buildDropdownTile(
            'Node Role',
            'Define network role',
            _nodeRole,
            _nodeRoles,
            (value) => setState(() => _nodeRole = value!),
            isDark,
            theme,
          ),
          _buildSliderTile(
            'Transmission Power',
            'Adjust signal strength (${_transmissionPower.toInt()}%)',
            _transmissionPower,
            0.0,
            100.0,
            (value) => setState(() => _transmissionPower = value),
            isDark,
            theme,
          ),
          _buildSliderTile(
            'Max Connections',
            'Maximum peer connections ($_maxConnections)',
            _maxConnections.toDouble(),
            5.0,
            50.0,
            (value) => setState(() => _maxConnections = value.toInt()),
            isDark,
            theme,
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacySecuritySection(ThemeData theme, bool isDark) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.accentColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'security',
                color: AppTheme.accentColor,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'Privacy & Security',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.accentColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          _buildSettingTile(
            'Biometric Auth',
            'Use fingerprint/face unlock',
            Switch.adaptive(
              value: _biometricAuth,
              onChanged: (value) => setState(() => _biometricAuth = value),
              activeColor: AppTheme.accentColor,
            ),
            isDark,
            theme,
          ),
          _buildSettingTile(
            'Auto Lock',
            'Automatically lock device',
            Switch.adaptive(
              value: _autoLockEnabled,
              onChanged: (value) => setState(() => _autoLockEnabled = value),
              activeColor: AppTheme.accentColor,
            ),
            isDark,
            theme,
          ),
          _buildSliderTile(
            'Lock Timeout',
            'Auto-lock after $_lockTimeoutMinutes minutes',
            _lockTimeoutMinutes.toDouble(),
            1.0,
            30.0,
            (value) => setState(() => _lockTimeoutMinutes = value.toInt()),
            isDark,
            theme,
          ),
          SizedBox(height: 3.h),
          _buildSectionHeader('Encryption', isDark, theme),
          _buildSettingTile(
            'Quantum Encryption',
            'Enhanced quantum-resistant encryption',
            Switch.adaptive(
              value: _quantumEncryption,
              onChanged: (value) => setState(() => _quantumEncryption = value),
              activeColor: AppTheme.accentColor,
            ),
            isDark,
            theme,
          ),
          SizedBox(height: 3.h),
          _buildSectionHeader('Emergency', isDark, theme),
          _buildSettingTile(
            'Emergency Mode',
            'Enable emergency mesh protocols',
            Switch.adaptive(
              value: _emergencyModeEnabled,
              onChanged: (value) =>
                  setState(() => _emergencyModeEnabled = value),
              activeColor: AppTheme.errorColor,
            ),
            isDark,
            theme,
          ),
          _buildSettingTile(
            'Remote Wipe',
            'Allow remote device wipe',
            Switch.adaptive(
              value: _remoteWipeEnabled,
              onChanged: (value) => setState(() => _remoteWipeEnabled = value),
              activeColor: AppTheme.errorColor,
            ),
            isDark,
            theme,
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceSection(ThemeData theme, bool isDark) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.accentColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'performance',
                color: AppTheme.accentColor,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'Performance Settings',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.accentColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          _buildSettingTile(
            'Gaming Mode',
            'Optimize for FERGame sessions',
            Switch.adaptive(
              value: _gamingModeEnabled,
              onChanged: (value) => setState(() => _gamingModeEnabled = value),
              activeColor: AppTheme.accentColor,
            ),
            isDark,
            theme,
          ),
          _buildSettingTile(
            'Low Latency Mode',
            'Prioritize gaming traffic',
            Switch.adaptive(
              value: _lowLatencyMode,
              onChanged: (value) => setState(() => _lowLatencyMode = value),
              activeColor: AppTheme.accentColor,
            ),
            isDark,
            theme,
          ),
          _buildSliderTile(
            'Gaming Priority',
            'Network priority for games (${_gamingPriority.toInt()}%)',
            _gamingPriority,
            0.0,
            100.0,
            (value) => setState(() => _gamingPriority = value),
            isDark,
            theme,
          ),
          SizedBox(height: 3.h),
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.accentColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'videogame_asset',
                      color: AppTheme.accentColor,
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'FERGame Performance',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.accentColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildPerformanceMetric('Latency', '12ms', isDark, theme),
                    _buildPerformanceMetric('FPS', '60', isDark, theme),
                    _buildPerformanceMetric('Nodes', '47', isDark, theme),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeveloperSection(ThemeData theme, bool isDark) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.accentColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'developer',
                color: AppTheme.accentColor,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'Developer Options',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.accentColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          _buildSettingTile(
            'Battery Saver',
            'Reduce power consumption',
            Switch.adaptive(
              value: _batterySaverMode,
              onChanged: (value) => setState(() => _batterySaverMode = value),
              activeColor: AppTheme.accentColor,
            ),
            isDark,
            theme,
          ),
          _buildSettingTile(
            'Voice Commands',
            'Enable Chad voice assistant',
            Switch.adaptive(
              value: _voiceCommands,
              onChanged: (value) => setState(() => _voiceCommands = value),
              activeColor: AppTheme.accentColor,
            ),
            isDark,
            theme,
          ),
          SizedBox(height: 3.h),
          _buildSectionHeader('Device Information', isDark, theme),
          _buildInfoTile(
              'Device ID',
              'FER-${DateTime.now().millisecondsSinceEpoch.toRadixString(16).toUpperCase()}',
              isDark,
              theme),
          _buildInfoTile('AiFER Network Version', '2.1.0', isDark, theme),
          _buildInfoTile('FERMesh Protocol', 'v3.2.1', isDark, theme),
          _buildInfoTile('Last Sync',
              '${DateTime.now().toString().split('.')[0]}', isDark, theme),
          SizedBox(height: 3.h),
          _buildActionButton('Reset to Defaults', Icons.restore,
              () => _resetToDefaults(), isDark, theme),
          SizedBox(height: 2.h),
          _buildActionButton('Export Configuration', Icons.download,
              () => _exportConfig(), isDark, theme),
          SizedBox(height: 2.h),
          _buildActionButton('Run Network Diagnostics', Icons.network_check,
              () => _runDiagnostics(), isDark, theme),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppTheme.accentColor,
        ),
      ),
    );
  }

  Widget _buildSettingTile(String title, String subtitle, Widget trailing,
      bool isDark, ThemeData theme) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(
          title,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
          ),
        ),
        trailing: trailing,
      ),
    );
  }

  Widget _buildDropdownTile(
      String title,
      String subtitle,
      String value,
      List<String> items,
      ValueChanged<String?> onChanged,
      bool isDark,
      ThemeData theme) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(
          title,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
          ),
        ),
        trailing: DropdownButton<String>(
          value: value,
          onChanged: onChanged,
          items: items
              .map((item) => DropdownMenuItem(
                    value: item,
                    child: Text(item,
                        style: TextStyle(color: AppTheme.accentColor)),
                  ))
              .toList(),
          underline: Container(),
          dropdownColor: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        ),
      ),
    );
  }

  Widget _buildSliderTile(
      String title,
      String subtitle,
      double value,
      double min,
      double max,
      ValueChanged<double> onChanged,
      bool isDark,
      ThemeData theme) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
              color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color:
                  isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: 1.h),
          Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
            activeColor: AppTheme.accentColor,
            inactiveColor: AppTheme.accentColor.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(
      String title, String value, bool isDark, ThemeData theme) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(
          title,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
          ),
        ),
        trailing: Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.accentColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(String title, IconData icon, VoidCallback onPressed,
      bool isDark, ThemeData theme) {
    return Container(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: AppTheme.primaryLight),
        label: Text(title,
            style: TextStyle(
                color: AppTheme.primaryLight, fontWeight: FontWeight.w600)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.accentColor,
          padding: EdgeInsets.symmetric(vertical: 2.h),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildPerformanceMetric(
      String label, String value, bool isDark, ThemeData theme) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppTheme.accentColor,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  void _resetToDefaults() {
    setState(() {
      _meshNetworkEnabled = true;
      _blockchainSyncEnabled = true;
      _emergencyModeEnabled = false;
      _autoDiscoveryEnabled = true;
      _batterySaverMode = false;
      _quantumEncryption = true;
      _voiceCommands = false;
      _biometricAuth = true;
      _selectedFrequency = '2.4GHz';
      _transmissionPower = 75.0;
      _maxConnections = 10;
      _nodeRole = 'mesh_node';
      _gamingModeEnabled = false;
      _lowLatencyMode = false;
      _gamingPriority = 50.0;
      _autoLockEnabled = true;
      _lockTimeoutMinutes = 5;
      _remoteWipeEnabled = false;
    });

    Fluttertoast.showToast(
      msg: "Settings reset to defaults",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _exportConfig() async {
    final config = {
      'mesh_network': _meshNetworkEnabled,
      'blockchain_sync': _blockchainSyncEnabled,
      'emergency_mode': _emergencyModeEnabled,
      'frequency': _selectedFrequency,
      'transmission_power': _transmissionPower,
      'node_role': _nodeRole,
      'gaming_mode': _gamingModeEnabled,
      'quantum_encryption': _quantumEncryption,
      'exported_at': DateTime.now().toIso8601String(),
    };

    Clipboard.setData(ClipboardData(text: config.toString()));
    Fluttertoast.showToast(
      msg: "Configuration copied to clipboard",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _runDiagnostics() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Network Diagnostics',
            style: TextStyle(color: AppTheme.accentColor)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                '• FERMesh Network: ${_meshNetworkEnabled ? "✓ Active" : "✗ Inactive"}'),
            Text(
                '• Blockchain Sync: ${_blockchainSyncEnabled ? "✓ Synced" : "✗ Offline"}'),
            Text('• Signal Strength: 85%'),
            Text('• Peer Connections: 12/50'),
            Text('• AiFER Network: ✓ Connected'),
            Text('• Chad Service: ✓ Available'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: AppTheme.accentColor)),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshSettings() async {
    // Simulate refreshing settings
    await Future.delayed(Duration(seconds: 1));
    _loadDeviceSettings();
  }

  Future<void> _exportSettings() async {
    final config = {
      'mesh_network': _meshNetworkEnabled,
      'blockchain_sync': _blockchainSyncEnabled,
      'emergency_mode': _emergencyModeEnabled,
      'frequency': _selectedFrequency,
      'transmission_power': _transmissionPower,
      'node_role': _nodeRole,
      'gaming_mode': _gamingModeEnabled,
      'quantum_encryption': _quantumEncryption,
      'exported_at': DateTime.now().toIso8601String(),
    };

    Clipboard.setData(ClipboardData(text: config.toString()));
    Fluttertoast.showToast(
      msg: "Settings exported to clipboard",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }
}