import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/aiferid_auth_service.dart';
import '../../services/blockchain_wallet_service.dart';
import '../../services/offline_first_database.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/account_verification_widget.dart';
import './widgets/wallet_card_widget.dart';
import './widgets/wallet_creation_form.dart';

/// Phase 6 · step 2 — Blockchain Wallet Manager wired to the real stack.
///
/// Identity: `AiFERiDAuthService.getCurrentUser()`  (Google path removed)
/// Wallets:  `BlockchainWalletService` (already Claude-compatible)
/// History:  `OfflineFirstDatabase` (offline-first, no Supabase)
///
/// The screen surfaces three tabs:
///   1. Overview — aggregate FER balance + wallet cards
///   2. New wallet — `WalletCreationForm` (uses the existing widget)
///   3. Verify account — `AccountVerificationWidget` (unchanged)
class BlockchainWalletManagerScreen extends StatefulWidget {
  const BlockchainWalletManagerScreen({Key? key}) : super(key: key);

  @override
  State<BlockchainWalletManagerScreen> createState() =>
      _BlockchainWalletManagerScreenState();
}

class _BlockchainWalletManagerScreenState
    extends State<BlockchainWalletManagerScreen>
    with TickerProviderStateMixin {
  // ── services (real stack) ──────────────────────────────────────────
  final BlockchainWalletService _wallets = BlockchainWalletService.instance;
  final AiFERiDAuthService _auth = AiFERiDAuthService.instance;
  final OfflineFirstDatabase _db = OfflineFirstDatabase.instance;

  // ── tabs ───────────────────────────────────────────────────────────
  late final TabController _tabs;

  // ── state ──────────────────────────────────────────────────────────
  bool _isLoading = true;
  bool _isCreating = false;
  String? _userId;
  String _userLabel = 'Guest';
  List<BlockchainWallet> _myWallets = [];
  double _aggregateFer = 0.0;
  int _pendingCount = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _bootstrap();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    try {
      await _wallets.initialize();
      await _auth.initialize();
      await _db.initialize();
    } catch (_) {}

    final user = _auth.getCurrentUser();
    _userId = user?.walletAddress ?? user?.ferretId;
    _userLabel = user?.ferretId ?? user?.walletAddress ?? 'Guest';

    await _reloadWallets();
    if (mounted) setState(() => _isLoading = false);
  }

  // ── data ───────────────────────────────────────────────────────────
  Future<void> _reloadWallets() async {
    if (_userId == null) {
      setState(() {
        _myWallets = [];
        _aggregateFer = 0;
        _pendingCount = 0;
      });
      return;
    }
    try {
      final raw = await _wallets.getUserWallets(_userId!);
      final parsed =
          raw.map((m) => BlockchainWallet.fromMap(m)).toList();

      // Aggregate balance = sum of FER-type wallets' metadata['balance'] (a
      // user-visible number the wallet service writes on mint; the real on-
      // chain balance lookup is a Phase-7 polish item).
      double total = 0;
      int pending = 0;
      for (final w in parsed) {
        final bal = (w.metadata['balance'] as num?)?.toDouble();
        if (bal != null) total += bal;
        if (!w.isVerified) pending += 1;
      }

      if (!mounted) return;
      setState(() {
        _myWallets = parsed;
        _aggregateFer = total;
        _pendingCount = pending;
        _error = null;
      });
    } catch (e) {
      debugPrint('❌ reloadWallets: $e');
      if (mounted) setState(() => _error = 'Failed to load wallets: $e');
    }
  }

  Future<void> _createWallet(String accountName, WalletType type) async {
    if (_userId == null) {
      _toast('Sign in first', ok: false);
      return;
    }
    setState(() => _isCreating = true);
    try {
      final data = await _wallets.generateWallet(
        userId: _userId!,
        accountName: accountName,
        type: type,
      );
      HapticFeedback.mediumImpact();
      _toast('Wallet minted: ${_shortAddr(data['address'] as String? ?? '')}');
      await _reloadWallets();
      _tabs.animateTo(0);
    } catch (e) {
      _toast('Mint failed: $e', ok: false);
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  Future<void> _verifyWallet(BlockchainWallet w) async {
    try {
      final ok = await _wallets.verifyAccountName(w.accountName, w.address);
      _toast(
        ok ? 'Ownership verified ✓' : 'Verification failed',
        ok: ok,
      );
      await _reloadWallets();
    } catch (e) {
      _toast('Verify failed: $e', ok: false);
    }
  }

  // ── helpers ────────────────────────────────────────────────────────
  String _shortAddr(String a) =>
      a.length <= 10 ? a : '${a.substring(0, 6)}…${a.substring(a.length - 4)}';

  void _toast(String msg, {bool ok = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              color: AppTheme.background,
            )),
        backgroundColor: ok ? AppTheme.primary : AppTheme.accent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── UI ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildHeader(),
          _buildTabs(),
          Expanded(
            child: _isLoading
                ? _buildLoading()
                : TabBarView(
                    controller: _tabs,
                    children: [
                      _buildOverview(),
                      _buildCreate(),
                      const AccountVerificationWidget(),
                    ],
                  ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: 3,
        onTap: _handleBottomNav,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.background,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Wallet',
        style: GoogleFonts.inter(
          color: AppTheme.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 14.sp,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: AppTheme.textPrimary),
          onPressed: _reloadWallets,
        ),
      ],
    );
  }

  /// Orange balance card — same visual language as the dashboard's
  /// FER Balance card, but here it shows the live aggregate from
  /// `BlockchainWalletService.getUserWallets`.
  Widget _buildHeader() {
    return Container(
      margin: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.balanceOrange,
            AppTheme.balanceOrange.withOpacity(0.65),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(4.w),
        boxShadow: [
          BoxShadow(
            color: AppTheme.balanceOrange.withOpacity(0.3),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 13.w,
            height: 13.w,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(3.w),
            ),
            child: Icon(
              Icons.account_balance_wallet_rounded,
              color: Colors.white,
              size: 7.w,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total FER Balance',
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 0.4.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _aggregateFer.toStringAsFixed(3),
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                    SizedBox(width: 1.5.w),
                    Padding(
                      padding: EdgeInsets.only(bottom: 0.5.h),
                      child: Text(
                        'FER',
                        style: GoogleFonts.inter(
                          color: Colors.white70,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 0.4.h),
                Text(
                  '${_myWallets.length} wallet${_myWallets.length == 1 ? '' : 's'} · $_pendingCount pending · $_userLabel',
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 9.5.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(color: AppTheme.surfaceElevated),
      ),
      child: TabBar(
        controller: _tabs,
        labelColor: AppTheme.background,
        unselectedLabelColor: AppTheme.textSecondary,
        labelStyle:
            GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 10.5.sp),
        unselectedLabelStyle:
            GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 10.5.sp),
        indicator: BoxDecoration(
          color: AppTheme.primary,
          borderRadius: BorderRadius.circular(3.w),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'New'),
          Tab(text: 'Verify'),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return ListView.builder(
      itemCount: 3,
      itemBuilder: (_, __) => const ShimmerListItem(),
    );
  }

  Widget _buildOverview() {
    if (_error != null) {
      return ErrorStateView(
        title: 'Could not load wallets',
        message:
            'The local wallet cache failed to open. Retry to re-read your offline keystore.',
        icon: Icons.account_balance_wallet_outlined,
        onRetry: _reloadWallets,
      );
    }
    if (_myWallets.isEmpty) {
      return _buildEmptyState(
        icon: Icons.account_balance_wallet_outlined,
        title: 'No wallets yet',
        subtitle:
            'Mint a FER wallet to start holding balance and sending on-chain transfers.',
        cta: 'Create wallet',
        onTap: () => _tabs.animateTo(1),
      );
    }
    return RefreshIndicator(
      color: AppTheme.primary,
      backgroundColor: AppTheme.surface,
      onRefresh: _reloadWallets,
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(4.w, 1.h, 4.w, 4.h),
        itemCount: _myWallets.length,
        itemBuilder: (_, i) {
          final w = _myWallets[i];
          return Padding(
            padding: EdgeInsets.only(bottom: 1.5.h),
            child: WalletCardWidget(
              wallet: w,
              onVerify: w.isVerified ? null : () => _verifyWallet(w),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCreate() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: WalletCreationForm(
        onWalletCreated: _createWallet,
        isLoading: _isCreating,
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    String? cta,
    VoidCallback? onTap,
  }) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 22.w,
              height: 22.w,
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(6.w),
                border: Border.all(color: AppTheme.surfaceElevated),
              ),
              child: Icon(icon, color: AppTheme.balanceOrange, size: 11.w),
            ),
            SizedBox(height: 3.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 14.sp,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: AppTheme.textSecondary,
                fontSize: 11.sp,
                height: 1.5,
              ),
            ),
            if (cta != null && onTap != null) ...[
              SizedBox(height: 2.5.h),
              ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.balanceOrange,
                  foregroundColor: Colors.white,
                  padding:
                      EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3.w),
                  ),
                ),
                child: Text(
                  cta,
                  style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _handleBottomNav(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, AppRoutes.networkDashboard);
        break;
      case 1:
        Navigator.pushReplacementNamed(context, AppRoutes.messagingInterface);
        break;
      case 2:
        Navigator.pushReplacementNamed(context, AppRoutes.gamingHub);
        break;
      case 3:
        break; // already here
      case 4:
        Navigator.pushReplacementNamed(context, AppRoutes.deviceSettings);
        break;
    }
  }
}
