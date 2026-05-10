import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../services/blockchain_wallet_service.dart';
import '../../../services/supabase_auth_service.dart';

class WalletCreationCard extends StatefulWidget {
  final VoidCallback onCreateWallet;
  final VoidCallback onImportWallet;

  const WalletCreationCard({
    super.key,
    required this.onCreateWallet,
    required this.onImportWallet,
  });

  @override
  State<WalletCreationCard> createState() => _WalletCreationCardState();
}

class _WalletCreationCardState extends State<WalletCreationCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  final BlockchainWalletService _walletService =
      BlockchainWalletService.instance;
  final SupabaseAuthService _authService = SupabaseAuthService();

  bool _isCreating = false;
  bool _isImporting = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateWallet() async {
    if (_isCreating) return;

    setState(() {
      _isCreating = true;
    });

    try {
      final user = _authService.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Generate new blockchain wallet with updated method call
      final result = await _walletService.generateWallet(
        userId: user.id,
        accountName: 'AiFER FERMesh Wallet',
        // type parameter is now optional and defaults to WalletType.fer
      );

      if (result['success'] == true) {
        // Show success and recovery phrase
        await _showRecoveryPhraseDialog(result['recovery_phrase']);

        _showSuccessMessage('Blockchain wallet created successfully!');
        widget.onCreateWallet();
      } else {
        _showErrorMessage(
            'Failed to create wallet: ${result['error'] ?? 'Unknown error'}');
      }
    } catch (e) {
      _showErrorMessage('Failed to create wallet: ${e.toString()}');
    } finally {
      setState(() {
        _isCreating = false;
      });
    }
  }

  Future<void> _handleImportWallet() async {
    if (_isImporting) return;

    final recoveryPhrase = await _showImportWalletDialog();
    if (recoveryPhrase == null || recoveryPhrase.isEmpty) return;

    setState(() {
      _isImporting = true;
    });

    try {
      final user = _authService.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Import existing wallet
      final wallets = await _walletService.getUserWallets(user.id);

      if (wallets.isNotEmpty) {
        _showSuccessMessage('Blockchain wallet imported successfully!');
        widget.onImportWallet();
      }
    } catch (e) {
      _showErrorMessage('Failed to import wallet: ${e.toString()}');
    } finally {
      setState(() {
        _isImporting = false;
      });
    }
  }

  Future<void> _showRecoveryPhraseDialog(List<String> recoveryPhrase) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.security, color: AppTheme.accentColor),
            SizedBox(width: 2.w),
            Text('Backup Your Recovery Phrase'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'IMPORTANT: Save these 12 words in a secure location. You\'ll need them to recover your wallet.',
              style: TextStyle(
                color: AppTheme.errorColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 3.h),
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withAlpha(26),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.accentColor.withAlpha(77)),
              ),
              child: Column(
                children: [
                  for (int i = 0; i < recoveryPhrase.length; i += 3)
                    Padding(
                      padding: EdgeInsets.only(bottom: 1.h),
                      child: Row(
                        children: [
                          for (int j = i;
                              j < i + 3 && j < recoveryPhrase.length;
                              j++)
                            Expanded(
                              child: Text(
                                '${j + 1}. ${recoveryPhrase[j]}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 2.h),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Clipboard.setData(
                          ClipboardData(text: recoveryPhrase.join(' ')));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text('Recovery phrase copied to clipboard')),
                      );
                    },
                    icon: Icon(Icons.copy, size: 4.w),
                    label: Text('Copy'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentColor.withAlpha(51),
                      foregroundColor: AppTheme.accentColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('I\'ve Saved It Securely'),
          ),
        ],
      ),
    );
  }

  Future<List<String>?> _showImportWalletDialog() async {
    final controller = TextEditingController();

    return showDialog<List<String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.download, color: AppTheme.successColor),
            SizedBox(width: 2.w),
            Text('Import Wallet'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Enter your 12-word recovery phrase:'),
            SizedBox(height: 2.h),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: InputDecoration(
                hintText:
                    'word1 word2 word3 word4 word5 word6 word7 word8 word9 word10 word11 word12',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final phrase = controller.text.trim().split(' ');
              if (phrase.length == 12) {
                Navigator.of(context).pop(phrase);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please enter exactly 12 words')),
                );
              }
            },
            child: Text('Import'),
          ),
        ],
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

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // FERMesh Security Icon
                Container(
                  width: 20.w,
                  height: 20.w,
                  margin: EdgeInsets.only(bottom: 4.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.accentColor,
                        AppTheme.accentColor.withAlpha(179),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accentColor.withAlpha(77),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.account_balance_wallet,
                      color: isDark
                          ? AppTheme.primaryLight
                          : AppTheme.surfaceLight,
                      size: 8.w,
                    ),
                  ),
                ),

                // Title
                Text(
                  'FERMesh Blockchain Wallet',
                  style: GoogleFonts.inter(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppTheme.textPrimaryDark
                        : AppTheme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 1.h),

                // Subtitle
                Text(
                  'Secure your mesh network access with blockchain wallet authentication for online and offline use',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: isDark
                        ? AppTheme.textSecondaryDark
                        : AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 4.h),

                // Create New Wallet Card
                _buildWalletOptionCard(
                  context: context,
                  isDark: isDark,
                  title: 'Create New Wallet',
                  subtitle:
                      'Generate a new blockchain wallet for FERMesh access with recovery phrase',
                  icon: Icons.add_circle_outline,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.accentColor.withAlpha(26),
                      AppTheme.accentColor.withAlpha(13),
                    ],
                  ),
                  borderColor: AppTheme.accentColor,
                  isLoading: _isCreating,
                  onTap: _handleCreateWallet,
                ),

                SizedBox(height: 2.h),

                // Import Existing Wallet Card
                _buildWalletOptionCard(
                  context: context,
                  isDark: isDark,
                  title: 'Import Existing Wallet',
                  subtitle:
                      'Restore access with your 12-word recovery phrase for offline authentication',
                  icon: Icons.download,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.successColor.withAlpha(26),
                      AppTheme.successColor.withAlpha(13),
                    ],
                  ),
                  borderColor: AppTheme.successColor,
                  isLoading: _isImporting,
                  onTap: _handleImportWallet,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWalletOptionCard({
    required BuildContext context,
    required bool isDark,
    required String title,
    required String subtitle,
    required IconData icon,
    required Gradient gradient,
    required Color borderColor,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          minHeight: 12.h,
        ),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor.withAlpha(77),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: borderColor.withAlpha(26),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon Container
            Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: borderColor.withAlpha(38),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: isLoading
                    ? SizedBox(
                        width: 6.w,
                        height: 6.w,
                        child: CircularProgressIndicator(
                          color: borderColor,
                          strokeWidth: 2,
                        ),
                      )
                    : Icon(
                        icon,
                        color: borderColor,
                        size: 6.w,
                      ),
              ),
            ),

            SizedBox(width: 4.w),

            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppTheme.textPrimaryDark
                          : AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w400,
                      color: isDark
                          ? AppTheme.textSecondaryDark
                          : AppTheme.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Arrow Icon
            if (!isLoading)
              Icon(
                Icons.arrow_forward_ios,
                color: borderColor,
                size: 4.w,
              ),
          ],
        ),
      ),
    );
  }
}
