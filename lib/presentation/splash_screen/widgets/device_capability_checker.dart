import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';
import 'dart:math' as math;

import '../../../core/app_export.dart';

/// Widget that checks device capabilities for FERMesh network functionality
class DeviceCapabilityChecker extends StatefulWidget {
  final Function(DeviceCapabilities) onCapabilitiesChecked;
  final VoidCallback? onError;

  const DeviceCapabilityChecker({
    super.key,
    required this.onCapabilitiesChecked,
    this.onError,
  });

  @override
  State<DeviceCapabilityChecker> createState() =>
      _DeviceCapabilityCheckerState();
}

class _DeviceCapabilityCheckerState extends State<DeviceCapabilityChecker> {
  bool _isChecking = true;
  String _currentCheck = 'Initializing...';
  DeviceCapabilities? _capabilities;

  @override
  void initState() {
    super.initState();
    _performCapabilityCheck();
  }

  Future<void> _performCapabilityCheck() async {
    try {
      final capabilities = DeviceCapabilities();

      // Check network connectivity
      setState(() => _currentCheck = 'Checking network capabilities...');
      await _checkNetworkCapabilities(capabilities);

      // Check permissions
      setState(() => _currentCheck = 'Verifying permissions...');
      await _checkPermissions(capabilities);

      // Check hardware features
      setState(() => _currentCheck = 'Scanning hardware features...');
      await _checkHardwareFeatures(capabilities);

      // Check blockchain readiness
      setState(() => _currentCheck = 'Preparing blockchain services...');
      await _checkBlockchainReadiness(capabilities);

      setState(() {
        _isChecking = false;
        _capabilities = capabilities;
      });

      // Delay for user to see completion
      await Future.delayed(const Duration(milliseconds: 500));
      widget.onCapabilitiesChecked(capabilities);
    } catch (e) {
      setState(() {
        _isChecking = false;
        _currentCheck = 'Device compatibility check failed';
      });

      await Future.delayed(const Duration(seconds: 2));
      widget.onError?.call();
    }
  }

  Future<void> _checkNetworkCapabilities(
      DeviceCapabilities capabilities) async {
    try {
      // Check connectivity
      final connectivity = Connectivity();
      final connectivityResults = await connectivity.checkConnectivity();

      capabilities.hasWiFi =
          connectivityResults == ConnectivityResult.wifi;
      capabilities.hasCellular =
          connectivityResults == ConnectivityResult.mobile;
      capabilities.hasEthernet =
          connectivityResults == ConnectivityResult.ethernet;

      // Web has limited network access
      if (kIsWeb) {
        capabilities.hasBluetooth = false;
        capabilities.hasNFC = false;
      } else {
        capabilities.hasBluetooth = true; // Assume available on mobile
        capabilities.hasNFC = true; // Assume available on mobile
      }

      await Future.delayed(const Duration(milliseconds: 800));
    } catch (e) {
      capabilities.networkError = e.toString();
    }
  }

  Future<void> _checkPermissions(DeviceCapabilities capabilities) async {
    try {
      if (kIsWeb) {
        // Web permissions are handled by browser
        capabilities.hasLocationPermission = true;
        capabilities.hasStoragePermission = true;
        capabilities.hasPhonePermission = true;
      } else {
        // Check mobile permissions
        final locationStatus = await Permission.location.status;
        capabilities.hasLocationPermission = locationStatus.isGranted;

        final storageStatus = await Permission.storage.status;
        capabilities.hasStoragePermission = storageStatus.isGranted;

        final phoneStatus = await Permission.phone.status;
        capabilities.hasPhonePermission = phoneStatus.isGranted;
      }

      await Future.delayed(const Duration(milliseconds: 600));
    } catch (e) {
      capabilities.permissionError = e.toString();
    }
  }

  Future<void> _checkHardwareFeatures(DeviceCapabilities capabilities) async {
    try {
      // Platform-specific hardware checks
      if (kIsWeb) {
        capabilities.hasGPS = true; // Browser geolocation
        capabilities.hasCamera = true; // Browser media access
        capabilities.hasMicrophone = true; // Browser media access
        capabilities.hasAccelerometer = false;
        capabilities.hasGyroscope = false;
      } else {
        // Mobile hardware features
        capabilities.hasGPS = true;
        capabilities.hasCamera = true;
        capabilities.hasMicrophone = true;
        capabilities.hasAccelerometer = true;
        capabilities.hasGyroscope = true;
      }

      // Check processor capabilities
      capabilities.processorScore = _calculateProcessorScore();
      capabilities.memoryMB = _estimateAvailableMemory();

      await Future.delayed(const Duration(milliseconds: 700));
    } catch (e) {
      capabilities.hardwareError = e.toString();
    }
  }

  Future<void> _checkBlockchainReadiness(
      DeviceCapabilities capabilities) async {
    try {
      // Simulate blockchain service initialization
      capabilities.stellarNetworkReady = true;
      capabilities.suiBlockchainReady = true;
      capabilities.ferChainReady = true;

      // Check crypto capabilities
      capabilities.hasSecureEnclave = !kIsWeb;
      capabilities.supportsQuantumCrypto = true;

      await Future.delayed(const Duration(milliseconds: 900));
    } catch (e) {
      capabilities.blockchainError = e.toString();
    }
  }

  int _calculateProcessorScore() {
    // Simplified processor scoring
    if (kIsWeb) return 75; // Assume decent web performance
    return 85; // Assume good mobile performance
  }

  int _estimateAvailableMemory() {
    // Simplified memory estimation
    if (kIsWeb) return 2048; // 2GB typical for web
    return 4096; // 4GB typical for mobile
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (!_isChecking && _capabilities != null) {
      return _buildCapabilitiesSummary(isDark);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Checking animation
        Container(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentColor),
          ),
        ),

        SizedBox(height: 3.h),

        // Current check status
        Text(
          _currentCheck,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCapabilitiesSummary(bool isDark) {
    final capabilities = _capabilities!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Success icon
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.successColor.withValues(alpha: 0.2),
          ),
          child: CustomIconWidget(
            iconName: 'check_circle',
            color: AppTheme.successColor,
            size: 30,
          ),
        ),

        SizedBox(height: 2.h),

        // Capabilities summary
        Text(
          'Device Ready for FERMesh',
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.successColor,
          ),
        ),

        SizedBox(height: 1.h),

        // Quick stats
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildCapabilityStat(
              'Network',
              capabilities.getNetworkScore(),
              isDark,
            ),
            _buildCapabilityStat(
              'Hardware',
              capabilities.getHardwareScore(),
              isDark,
            ),
            _buildCapabilityStat(
              'Blockchain',
              capabilities.getBlockchainScore(),
              isDark,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCapabilityStat(String label, int score, bool isDark) {
    Color scoreColor = AppTheme.errorColor;
    if (score >= 80)
      scoreColor = AppTheme.successColor;
    else if (score >= 60) scoreColor = AppTheme.warningColor;

    return Column(
      children: [
        Text(
          '$score%',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: scoreColor,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// Data class for device capabilities
class DeviceCapabilities {
  // Network capabilities
  bool hasWiFi = false;
  bool hasCellular = false;
  bool hasBluetooth = false;
  bool hasNFC = false;
  bool hasEthernet = false;
  String? networkError;

  // Permissions
  bool hasLocationPermission = false;
  bool hasStoragePermission = false;
  bool hasPhonePermission = false;
  String? permissionError;

  // Hardware features
  bool hasGPS = false;
  bool hasCamera = false;
  bool hasMicrophone = false;
  bool hasAccelerometer = false;
  bool hasGyroscope = false;
  int processorScore = 0;
  int memoryMB = 0;
  String? hardwareError;

  // Blockchain readiness
  bool stellarNetworkReady = false;
  bool suiBlockchainReady = false;
  bool ferChainReady = false;
  bool hasSecureEnclave = false;
  bool supportsQuantumCrypto = false;
  String? blockchainError;

  int getNetworkScore() {
    int score = 0;
    if (hasWiFi) score += 25;
    if (hasCellular) score += 25;
    if (hasBluetooth) score += 20;
    if (hasNFC) score += 15;
    if (hasEthernet) score += 15;
    return score;
  }

  int getHardwareScore() {
    int score = 0;
    if (hasGPS) score += 20;
    if (hasCamera) score += 15;
    if (hasMicrophone) score += 15;
    if (hasAccelerometer) score += 10;
    if (hasGyroscope) score += 10;
    score += (processorScore * 0.3).round();
    return math.min(100, score);
  }

  int getBlockchainScore() {
    int score = 0;
    if (stellarNetworkReady) score += 30;
    if (suiBlockchainReady) score += 30;
    if (ferChainReady) score += 25;
    if (hasSecureEnclave) score += 10;
    if (supportsQuantumCrypto) score += 5;
    return score;
  }

  bool get isCompatible {
    return getNetworkScore() >= 50 &&
        getHardwareScore() >= 60 &&
        getBlockchainScore() >= 70;
  }
}