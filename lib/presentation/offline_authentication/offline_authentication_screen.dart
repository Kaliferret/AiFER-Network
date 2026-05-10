import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/supabase_auth_service.dart';
import '../../widgets/custom_app_bar.dart';

class OfflineAuthenticationScreen extends StatefulWidget {
  const OfflineAuthenticationScreen({super.key});

  @override
  State<OfflineAuthenticationScreen> createState() =>
      _OfflineAuthenticationScreenState();
}

class _OfflineAuthenticationScreenState
    extends State<OfflineAuthenticationScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final SupabaseAuthService _authService = SupabaseAuthService();
  
  bool _isLoading = false;
  String _walletAddress = '';
  String _sessionToken = '';
  String _message = '';
  String _signature = '';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _generateAuthenticationChallenge();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _fadeController.forward();
  }

  void _generateAuthenticationChallenge() {
    _message =
        'AiFER Network Offline Authentication ${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<void> _authenticateWithWallet() async {
    if (_walletAddress.isEmpty || _signature.isEmpty) {
      _showErrorMessage('Please enter wallet address and signature');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Attempt wallet authentication
      final result = await _authService.signInWithWallet(
        walletAddress: _walletAddress,
        message: _message,
        signature: _signature,
      );

      if (result['success'] == true) {
        _showSuccessMessage('Wallet authentication successful!');

        // Navigate to dashboard
        Navigator.pushReplacementNamed(context, AppRoutes.networkDashboard);
      }
    } catch (e) {
      _showErrorMessage('Wallet authentication failed: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _authenticateOffline() async {
    if (_sessionToken.isEmpty || _walletAddress.isEmpty) {
      _showErrorMessage('Please enter session token and wallet address');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final isValid = await _authService.authenticateOffline(
        sessionToken: _sessionToken,
        walletAddress: _walletAddress,
      );

      if (isValid) {
        _showSuccessMessage('Offline authentication successful!');
        Navigator.pushReplacementNamed(context, AppRoutes.networkDashboard);
      } else {
        _showErrorMessage('Invalid offline session or wallet address');
      }
    } catch (e) {
      _showErrorMessage('Offline authentication failed: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildAuthenticationCard({
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 3.h),
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: iconColor.withAlpha(51),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: iconColor.withAlpha(26),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: iconColor.withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 6.w,
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppTheme.textPrimaryDark
                            : AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppTheme.textSecondaryDark
                            : AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Form fields
          ...children,
        ],
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'AiFER Offline Access',
        showBackButton: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(6.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Blockchain Wallet Authentication',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color:
                      isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
                ),
              ),

              SizedBox(height: 1.h),

              Text(
                'Authenticate using your blockchain wallet for secure offline access to the FERMesh network',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? AppTheme.textSecondaryDark
                      : AppTheme.textSecondary,
                ),
              ),

              SizedBox(height: 4.h),

              // Wallet Authentication Section
              _buildAuthenticationCard(
                title: 'Wallet Authentication',
                description:
                    'Sign message with your blockchain wallet for network access',
                icon: Icons.account_balance_wallet,
                iconColor: AppTheme.accentColor,
                children: [
                  // Wallet Address Field
                  TextFormField(
                    onChanged: (value) => _walletAddress = value,
                    decoration: InputDecoration(
                      labelText: 'Wallet Address',
                      hintText: 'Enter your FER wallet address',
                      prefixIcon: Icon(Icons.fingerprint),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppTheme.accentColor),
                      ),
                    ),
                  ),

                  SizedBox(height: 2.h),

                  // Challenge Message Display
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor.withAlpha(26),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.accentColor.withAlpha(77),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sign this message:',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.accentColor,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          _message,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontFamily: 'monospace',
                            color: isDark
                                ? AppTheme.textSecondaryDark
                                : AppTheme.textSecondary,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                Clipboard.setData(
                                    ClipboardData(text: _message));
                                _showSuccessMessage(
                                    'Message copied to clipboard');
                              },
                              icon: Icon(Icons.copy, size: 4.w),
                              label: Text('Copy'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 2.h),

                  // Signature Field
                  TextFormField(
                    onChanged: (value) => _signature = value,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Signature',
                      hintText: 'Paste signature from your wallet',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppTheme.accentColor),
                      ),
                    ),
                  ),

                  SizedBox(height: 3.h),

                  // Authentication Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _authenticateWithWallet,
                      icon: _isLoading
                          ? SizedBox(
                              width: 4.w,
                              height: 4.w,
                              child: CircularProgressIndicator(
                                color: AppTheme.surfaceLight,
                                strokeWidth: 2,
                              ),
                            )
                          : Icon(Icons.security),
                      label: Text(_isLoading
                          ? 'Authenticating...'
                          : 'Authenticate Wallet'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentColor,
                        foregroundColor: AppTheme.surfaceLight,
                        padding: EdgeInsets.symmetric(vertical: 2.5.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Offline Session Section
              _buildAuthenticationCard(
                title: 'Offline Session',
                description: 'Use stored session for offline network access',
                icon: Icons.offline_bolt,
                iconColor: AppTheme.successColor,
                children: [
                  // Session Token Field
                  TextFormField(
                    onChanged: (value) => _sessionToken = value,
                    decoration: InputDecoration(
                      labelText: 'Session Token',
                      hintText: 'Enter your offline session token',
                      prefixIcon: Icon(Icons.vpn_key),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppTheme.successColor),
                      ),
                    ),
                  ),

                  SizedBox(height: 3.h),

                  // Offline Authentication Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _authenticateOffline,
                      icon: _isLoading
                          ? SizedBox(
                              width: 4.w,
                              height: 4.w,
                              child: CircularProgressIndicator(
                                color: AppTheme.surfaceLight,
                                strokeWidth: 2,
                              ),
                            )
                          : Icon(Icons.offline_bolt),
                      label: Text(
                          _isLoading ? 'Authenticating...' : 'Access Offline'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.successColor,
                        foregroundColor: AppTheme.surfaceLight,
                        padding: EdgeInsets.symmetric(vertical: 2.5.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Information Section
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: AppTheme.warningColor.withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.warningColor.withAlpha(77),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppTheme.warningColor,
                          size: 5.w,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Offline Access Information',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.warningColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '• Wallet authentication creates a secure offline session\n'
                      '• Session tokens are valid for 7 days\n'
                      '• Offline access allows FERMesh network functionality without internet\n'
                      '• Your wallet must be verified before creating offline sessions',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppTheme.textSecondaryDark
                            : AppTheme.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 6.h),
            ],
          ),
        ),
      ),
    );
  }
}