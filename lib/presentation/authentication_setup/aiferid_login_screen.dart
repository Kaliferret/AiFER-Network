import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/aiferid_auth_service.dart';
import '../../services/blockchain_wallet_service.dart';
import '../../theme/app_theme.dart';

/// AiFERiD Login Screen — Phase 5
///
/// Targets the real Claude `AiFERiDAuthService` API (no legacy shims):
///   • `authenticateWithWallet(address, signature, metadata)` for existing IDs
///   • `createAnonymousSession(ferretName: ...)` for one-tap guest ferrets
///   • `BlockchainWalletService.generateWallet()` to mint a fresh FER wallet
///
/// Offline-first: all persistence goes through `OfflineFirstDatabase` via
/// the auth service; a sign-in completes without any network call.
class AiFERiDLoginScreen extends StatefulWidget {
  const AiFERiDLoginScreen({Key? key}) : super(key: key);

  @override
  State<AiFERiDLoginScreen> createState() => _AiFERiDLoginScreenState();
}

class _AiFERiDLoginScreenState extends State<AiFERiDLoginScreen>
    with TickerProviderStateMixin {
  // ── animation ──────────────────────────────────────────────────────
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulse;

  // ── state ──────────────────────────────────────────────────────────
  bool _isSigningIn = false;
  bool _isCreating = false;
  bool _isGuestLoading = false;
  String? _errorMessage;
  String? _successMessage;
  int _selectedDemoIndex = -1;

  // ── services (real API) ────────────────────────────────────────────
  final AiFERiDAuthService _auth = AiFERiDAuthService.instance;
  final BlockchainWalletService _wallet = BlockchainWalletService.instance;

  // ── form controllers ───────────────────────────────────────────────
  final TextEditingController _aiferidController = TextEditingController();
  final TextEditingController _ferretNameController = TextEditingController();

  // Demo AiFERiDs — quick-fill only, authenticated through the real API.
  static const List<_DemoAccount> _demos = [
    _DemoAccount(
      id: 'FER0xDemo987654321FeDcBa9876543210FeDcBa',
      name: 'Demo User',
      description: 'General user for testing FERChat & FERVoice',
      color: AppTheme.tileBlue,
    ),
    _DemoAccount(
      id: 'FER0xAdmin123456789AbCdEf0123456789AbCdEf',
      name: 'Admin User',
      description: 'Administrator access with full controls',
      color: AppTheme.balanceOrange,
    ),
    _DemoAccount(
      id: 'FER0xBeta555888999AbCdEf0123456789AbCdEf',
      name: 'Beta Tester',
      description: 'Access to advanced beta features',
      color: AppTheme.primary,
    ),
  ];

  // ── lifecycle ──────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      duration: const Duration(milliseconds: 1600),
      vsync: this,
    );
    _pulse = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    _pulseCtrl.repeat(reverse: true);

    _bootServices();
  }

  Future<void> _bootServices() async {
    try {
      await _auth.initialize();
      await _wallet.initialize();
      debugPrint('✅ Phase-5 login screen: auth + wallet services ready');
    } catch (e) {
      debugPrint('⚠️  Service init on login screen failed: $e');
    }

    // If already signed in, jump straight to dashboard.
    if (_auth.getCurrentUser() != null && mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.networkDashboard);
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _aiferidController.dispose();
    _ferretNameController.dispose();
    super.dispose();
  }

  // ── auth handlers ──────────────────────────────────────────────────

  /// Sign in with an existing AiFERiD wallet address.
  /// We sign a deterministic challenge locally (SHA-256 over address) because
  /// the sandbox has no real wallet provider; the real mobile build will
  /// swap this for a hardware-key signature.
  Future<void> _handleSignIn() async {
    if (!mounted) return;

    final addr = _aiferidController.text.trim();
    if (addr.isEmpty) {
      _showError('Enter your AiFERiD or tap a demo account.');
      return;
    }
    if (!_isValidFerAddress(addr)) {
      _showError('Invalid AiFERiD format — expected FER… address.');
      return;
    }

    setState(() {
      _isSigningIn = true;
      _errorMessage = null;
    });

    try {
      final signature = _localChallengeSignature(addr);
      final result = await _auth.authenticateWithWallet(
        addr,
        signature,
        <String, dynamic>{
          'source': 'aiferid_login_screen',
          'method': 'local-challenge',
          'ts': DateTime.now().toIso8601String(),
        },
      );

      if (result.success && mounted) {
        HapticFeedback.lightImpact();
        _showSuccess('Welcome back 🎉');
        await Future.delayed(const Duration(milliseconds: 900));
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.networkDashboard);
        }
      } else {
        _showError(result.error ?? 'Authentication failed');
      }
    } catch (e) {
      _showError('Authentication failed: $e');
    } finally {
      if (mounted) setState(() => _isSigningIn = false);
    }
  }

  /// Mint a fresh FER wallet and sign in with it.
  Future<void> _handleCreateWallet() async {
    if (!mounted) return;

    final ferretName = _ferretNameController.text.trim();
    if (ferretName.isEmpty) {
      _showError('Give your ferret a name first.');
      return;
    }

    setState(() {
      _isCreating = true;
      _errorMessage = null;
    });

    try {
      // 1. Mint wallet via BlockchainWalletService.
      final tempUserId = 'pending-${DateTime.now().millisecondsSinceEpoch}';
      final wallet = await _wallet.generateWallet(
        userId: tempUserId,
        accountName: ferretName,
      );

      final address = wallet['address'] as String?;
      if (address == null || address.isEmpty) {
        _showError('Wallet creation returned no address.');
        return;
      }

      // 2. Authenticate through the real wallet path.
      final signature = _localChallengeSignature(address);
      final result = await _auth.authenticateWithWallet(
        address,
        signature,
        <String, dynamic>{
          'source': 'aiferid_login_screen',
          'method': 'wallet-creation',
          'ferret_name': ferretName,
          'wallet_type': wallet['type']?.toString() ?? 'fer',
        },
      );

      if (result.success && mounted) {
        _aiferidController.text = address;
        HapticFeedback.mediumImpact();
        _showSuccess('AiFERiD created 🎯\n$address');
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.networkDashboard);
        }
      } else {
        _showError(result.error ?? 'Account creation failed');
      }
    } catch (e) {
      _showError('Account creation failed: $e');
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  /// One-tap guest ferret — no wallet needed, session kept in memory.
  Future<void> _handleGuest() async {
    if (!mounted) return;
    setState(() {
      _isGuestLoading = true;
      _errorMessage = null;
    });
    try {
      final result = await _auth.createAnonymousSession(
        ferretName: _ferretNameController.text.trim().isEmpty
            ? 'Guest Ferret'
            : _ferretNameController.text.trim(),
      );
      if (result.success && mounted) {
        HapticFeedback.selectionClick();
        _showSuccess('Guest ferret ready 🦦');
        await Future.delayed(const Duration(milliseconds: 700));
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.networkDashboard);
        }
      } else {
        _showError(result.error ?? 'Guest session failed');
      }
    } catch (e) {
      _showError('Guest session failed: $e');
    } finally {
      if (mounted) setState(() => _isGuestLoading = false);
    }
  }

  void _selectDemo(int index) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedDemoIndex = index;
      _aiferidController.text = _demos[index].id;
      _errorMessage = null;
    });
  }

  // ── helpers ────────────────────────────────────────────────────────
  bool _isValidFerAddress(String v) =>
      RegExp(r'^FER[A-Za-z0-9]{8,}$').hasMatch(v);

  String _localChallengeSignature(String address) {
    final challenge = 'FER-AUTH|$address|${DateTime.now().toUtc().day}';
    return sha256.convert(utf8.encode(challenge)).toString();
  }

  void _showError(String msg) {
    if (!mounted) return;
    setState(() {
      _errorMessage = msg;
      _successMessage = null;
    });
  }

  void _showSuccess(String msg) {
    if (!mounted) return;
    setState(() {
      _successMessage = msg;
      _errorMessage = null;
    });
  }

  // ── UI ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              SizedBox(height: 3.h),
              _buildSignInCard(),
              SizedBox(height: 2.5.h),
              _buildDemoAccounts(),
              SizedBox(height: 2.5.h),
              _buildCreateCard(),
              SizedBox(height: 2.h),
              _buildGuestButton(),
              if (_errorMessage != null) ...[
                SizedBox(height: 2.h),
                _buildBanner(_errorMessage!, AppTheme.accent),
              ],
              if (_successMessage != null) ...[
                SizedBox(height: 2.h),
                _buildBanner(_successMessage!, AppTheme.primary),
              ],
              SizedBox(height: 3.h),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        ScaleTransition(
          scale: _pulse,
          child: Container(
            width: 22.w,
            height: 22.w,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primary, AppTheme.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(6.w),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x5500FF88),
                  blurRadius: 28,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              Icons.bolt_rounded,
              color: AppTheme.background,
              size: 11.w,
            ),
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          'AiFER Network',
          style: GoogleFonts.inter(
            fontSize: 22.sp,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          'Quantum-safe · Offline-first · Yours',
          style: GoogleFonts.inter(
            fontSize: 11.sp,
            fontWeight: FontWeight.w500,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSignInCard() {
    return _card(
      accent: AppTheme.primary,
      title: 'Sign in',
      subtitle: 'Use an existing AiFERiD',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _inputField(
            controller: _aiferidController,
            hint: 'FER…',
            icon: Icons.fingerprint_rounded,
            keyboardType: TextInputType.text,
          ),
          SizedBox(height: 1.8.h),
          _primaryButton(
            label: 'Sign In',
            loading: _isSigningIn,
            color: AppTheme.primary,
            onTap: _isSigningIn ? null : _handleSignIn,
          ),
        ],
      ),
    );
  }

  Widget _buildDemoAccounts() {
    return _card(
      accent: AppTheme.tileBlue,
      title: 'Quick demo',
      subtitle: 'Tap to pre-fill then sign in',
      child: Column(
        children: List.generate(_demos.length, (i) {
          final d = _demos[i];
          final selected = _selectedDemoIndex == i;
          return Padding(
            padding: EdgeInsets.only(bottom: i == _demos.length - 1 ? 0 : 1.h),
            child: InkWell(
              borderRadius: BorderRadius.circular(3.w),
              onTap: () => _selectDemo(i),
              child: Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: selected
                      ? d.color.withOpacity(0.18)
                      : AppTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(3.w),
                  border: Border.all(
                    color: selected ? d.color : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 10.w,
                      height: 10.w,
                      decoration: BoxDecoration(
                        color: d.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(2.5.w),
                      ),
                      child: Icon(Icons.person_rounded,
                          color: d.color, size: 5.w),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            d.name,
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          SizedBox(height: 0.3.h),
                          Text(
                            d.description,
                            style: GoogleFonts.inter(
                              fontSize: 9.5.sp,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (selected)
                      Icon(Icons.check_circle_rounded,
                          color: d.color, size: 5.w),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCreateCard() {
    return _card(
      accent: AppTheme.tilePink,
      title: 'New here?',
      subtitle: 'Mint a fresh FER wallet',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _inputField(
            controller: _ferretNameController,
            hint: 'Ferret name',
            icon: Icons.pets_rounded,
          ),
          SizedBox(height: 1.8.h),
          _primaryButton(
            label: 'Create Wallet',
            loading: _isCreating,
            color: AppTheme.tilePink,
            onTap: _isCreating ? null : _handleCreateWallet,
          ),
        ],
      ),
    );
  }

  Widget _buildGuestButton() {
    return TextButton(
      onPressed: _isGuestLoading ? null : _handleGuest,
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 1.6.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3.w),
        ),
        side: const BorderSide(color: AppTheme.surfaceElevated),
      ),
      child: _isGuestLoading
          ? SizedBox(
              width: 4.w,
              height: 4.w,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppTheme.textSecondary),
              ),
            )
          : Text(
              'Continue as Guest Ferret',
              style: GoogleFonts.inter(
                fontSize: 11.5.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Text(
        'Offline-first · No server required\nLattice-crypto · Frequency-hopping transport',
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(
          fontSize: 9.sp,
          color: AppTheme.textTertiary,
          height: 1.6,
        ),
      ),
    );
  }

  // ── UI primitives ──────────────────────────────────────────────────
  Widget _card({
    required Color accent,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(4.w),
        border: Border.all(color: AppTheme.surfaceElevated, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 1.w,
                height: 3.h,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(1.w),
                ),
              ),
              SizedBox(width: 2.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 2.h),
          child,
        ],
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.inter(
        fontSize: 12.sp,
        color: AppTheme.textPrimary,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(
          fontSize: 12.sp,
          color: AppTheme.textTertiary,
        ),
        prefixIcon: Icon(icon, color: AppTheme.textSecondary, size: 5.w),
        filled: true,
        fillColor: AppTheme.surfaceElevated,
        contentPadding:
            EdgeInsets.symmetric(vertical: 1.6.h, horizontal: 3.w),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(3.w),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(3.w),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(3.w),
          borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
        ),
      ),
    );
  }

  Widget _primaryButton({
    required String label,
    required bool loading,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: AppTheme.background,
        padding: EdgeInsets.symmetric(vertical: 1.8.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3.w),
        ),
        elevation: 0,
      ),
      child: loading
          ? SizedBox(
              width: 4.w,
              height: 4.w,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
    );
  }

  Widget _buildBanner(String msg, Color color) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(
            color == AppTheme.accent
                ? Icons.error_outline_rounded
                : Icons.check_circle_outline_rounded,
            color: color,
            size: 5.w,
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              msg,
              style: GoogleFonts.inter(
                fontSize: 11.sp,
                color: color,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DemoAccount {
  final String id;
  final String name;
  final String description;
  final Color color;

  const _DemoAccount({
    required this.id,
    required this.name,
    required this.description,
    required this.color,
  });
}
