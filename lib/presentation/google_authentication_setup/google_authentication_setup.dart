import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/aiferid_auth_service.dart';
import '../../services/blockchain_wallet_service.dart';
import './widgets/aiferid_auth_loading_widget.dart';
import './widgets/aiferid_sign_in_widget.dart';
import './widgets/aiferid_wallet_generator_widget.dart';

/// AiFERiD Authentication Setup - Replaces Google Authentication
/// Users authenticate using their blockchain wallet addresses (AiFERiD)
class AiFERiDAuthenticationSetup extends StatefulWidget {
  const AiFERiDAuthenticationSetup({Key? key}) : super(key: key);

  @override
  State<AiFERiDAuthenticationSetup> createState() =>
      _AiFERiDAuthenticationSetupState();
}

class _AiFERiDAuthenticationSetupState
    extends State<AiFERiDAuthenticationSetup> {
  bool _isLoading = false;
  bool _isCreatingWallet = false;
  bool _isAuthenticating = false;
  String? _errorMessage;
  String? _successMessage;

  final AiFERiDAuthService _authService = AiFERiDAuthService.instance;
  final BlockchainWalletService _walletService =
      BlockchainWalletService.instance;

  final TextEditingController _aiferidController = TextEditingController();
  final TextEditingController _accountNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeAiFERiDAuth();
    _checkExistingAuth();
  }

  void _initializeAiFERiDAuth() {
    _authService.initialize();
    _walletService.initialize();
    debugPrint('✅ AiFERiD Authentication Setup initialized');
  }

  Future<void> _checkExistingAuth() async {
    final isAuthenticated = await _authService.isAuthenticated();
    if (isAuthenticated && mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.networkDashboard);
    }
  }

  Future<void> _handleAiFERiDSignIn() async {
    if (!mounted) return;

    final aiFERiD = _aiferidController.text.trim();
    if (aiFERiD.isEmpty) {
      _showError('Please enter your AiFERiD');
      return;
    }

    if (!_authService.isValidAiFERiDFormat(aiFERiD)) {
      _showError('Invalid AiFERiD format. Please check your wallet address.');
      return;
    }

    setState(() {
      _isAuthenticating = true;
      _errorMessage = null;
    });

    try {
      final result =
          await _authService.authenticateWithAiFERiD(aiFERiD: aiFERiD);

      if (result['success'] == true && mounted) {
        _showSuccess('Authentication successful! Welcome back.');
        await Future.delayed(Duration(seconds: 2));

        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.networkDashboard);
        }
      } else {
        _showError(result['error'] ?? 'Authentication failed');
      }
    } catch (e) {
      _showError('Authentication failed: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isAuthenticating = false;
        });
      }
    }
  }

  Future<void> _handleCreateAiFERiDAccount() async {
    if (!mounted) return;

    final accountName = _accountNameController.text.trim();
    final email = _emailController.text.trim();

    if (accountName.isEmpty) {
      _showError('Please enter an account name');
      return;
    }

    if (email.isEmpty || !email.contains('@')) {
      _showError('Please enter a valid email address');
      return;
    }

    setState(() {
      _isCreatingWallet = true;
      _errorMessage = null;
    });

    try {
      final result = await _authService.createAiFERiDAccount(
        accountName: accountName,
        userEmail: email,
        fullName: accountName,
      );

      if (result['success'] == true && mounted) {
        final aiFERiD = result['aiferid'];
        _aiferidController.text = aiFERiD;

        _showSuccess('AiFERiD created successfully!\nYour AiFERiD: $aiFERiD');

        // Auto-authenticate with new AiFERiD
        await Future.delayed(Duration(seconds: 2));
        await _handleAiFERiDSignIn();
      } else {
        _showError(result['error'] ?? 'Account creation failed');
      }
    } catch (e) {
      _showError('Account creation failed: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isCreatingWallet = false;
        });
      }
    }
  }

  void _showError(String message) {
    if (mounted) {
      setState(() {
        _errorMessage = message;
        _successMessage = null;
      });
    }
  }

  void _showSuccess(String message) {
    if (mounted) {
      setState(() {
        _successMessage = message;
        _errorMessage = null;
      });
    }
  }

  void _loadDemoAiFERiD(String aiFERiD) {
    _aiferidController.text = aiFERiD;
    setState(() {
      _errorMessage = null;
      _successMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          child: Column(
            children: [
              // Header
              SizedBox(height: 8.h),

              // AiFER Network Branding
              Column(
                children: [
                  Container(
                    width: 20.w,
                    height: 20.w,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF6C63FF),
                          Color(0xFF3F51B5),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10.w),
                    ),
                    child: Icon(
                      Icons.account_balance_wallet_outlined,
                      color: Colors.white,
                      size: 10.w,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    'AiFER Network',
                    style: GoogleFonts.inter(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.headlineLarge?.color,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'Wallet-Based Authentication',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color
                          ?.withAlpha(179),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),

              SizedBox(height: 6.h),

              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Info Card
                      Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(3.w),
                          border: Border.all(
                            color: Theme.of(context).dividerColor.withAlpha(77),
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.security_outlined,
                              color: Color(0xFF6C63FF),
                              size: 6.w,
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'AiFERiD Authentication',
                              style: GoogleFonts.inter(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.color,
                              ),
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              'Your wallet address is your identity. Sign in securely using your blockchain wallet address (AiFERiD) instead of traditional passwords.',
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.color,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 4.h),

                      if (_isCreatingWallet) ...[
                        // Wallet creation in progress
                        AiFERiDWalletGeneratorWidget(),
                      ] else if (_isAuthenticating) ...[
                        // Authentication in progress
                        AiFERiDAuthLoadingWidget(),
                      ] else ...[
                        // Authentication form
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Demo AiFERiDs
                            Container(
                              padding: EdgeInsets.all(3.w),
                              decoration: BoxDecoration(
                                color: Colors.blue.withAlpha(26),
                                borderRadius: BorderRadius.circular(2.w),
                                border: Border.all(
                                    color: Colors.blue.withAlpha(77)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Demo AiFERiDs (Click to use):',
                                    style: GoogleFonts.inter(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  SizedBox(height: 1.h),
                                  GestureDetector(
                                    onTap: () => _loadDemoAiFERiD(
                                        'FER0xDemo987654321FeDcBa9876543210FeDcBa'),
                                    child: Container(
                                      padding: EdgeInsets.all(2.w),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(1.w),
                                      ),
                                      child: Text(
                                        'Demo: FER0xDemo987654321FeDcBa9876543210FeDcBa',
                                        style: GoogleFonts.inter(
                                          fontSize: 10.sp,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 1.h),
                                  GestureDetector(
                                    onTap: () => _loadDemoAiFERiD(
                                        'FER0xAdmin123456789AbCdEf0123456789AbCdEf'),
                                    child: Container(
                                      padding: EdgeInsets.all(2.w),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(1.w),
                                      ),
                                      child: Text(
                                        'Admin: FER0xAdmin123456789AbCdEf0123456789AbCdEf',
                                        style: GoogleFonts.inter(
                                          fontSize: 10.sp,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 4.h),

                            // AiFERiD Input
                            Text(
                              'Enter Your AiFERiD:',
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.color,
                              ),
                            ),
                            SizedBox(height: 1.h),
                            TextField(
                              controller: _aiferidController,
                              decoration: InputDecoration(
                                hintText:
                                    'FER0x... or paste your wallet address',
                                hintStyle: GoogleFonts.inter(fontSize: 12.sp),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(2.w),
                                ),
                                prefixIcon: Icon(Icons.wallet_outlined),
                                contentPadding: EdgeInsets.all(3.w),
                              ),
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                              ),
                            ),

                            SizedBox(height: 3.h),

                            // Sign In Button
                            AiFERiDSignInWidget(
                              onPressed: _handleAiFERiDSignIn,
                              isLoading: _isAuthenticating,
                            ),

                            SizedBox(height: 4.h),

                            // Divider
                            Row(
                              children: [
                                Expanded(child: Divider()),
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 3.w),
                                  child: Text(
                                    'OR',
                                    style: GoogleFonts.inter(
                                      fontSize: 12.sp,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.color
                                          ?.withAlpha(128),
                                    ),
                                  ),
                                ),
                                Expanded(child: Divider()),
                              ],
                            ),

                            SizedBox(height: 4.h),

                            // Create New Account Section
                            Text(
                              'Create New AiFERiD Account:',
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.color,
                              ),
                            ),
                            SizedBox(height: 2.h),

                            // Account Name Input
                            TextField(
                              controller: _accountNameController,
                              decoration: InputDecoration(
                                hintText: 'Account name (e.g., My Wallet)',
                                hintStyle: GoogleFonts.inter(fontSize: 12.sp),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(2.w),
                                ),
                                prefixIcon: Icon(Icons.person_outline),
                                contentPadding: EdgeInsets.all(3.w),
                              ),
                              style: GoogleFonts.inter(fontSize: 12.sp),
                            ),

                            SizedBox(height: 2.h),

                            // Email Input
                            TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                hintText: 'Email address',
                                hintStyle: GoogleFonts.inter(fontSize: 12.sp),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(2.w),
                                ),
                                prefixIcon: Icon(Icons.email_outlined),
                                contentPadding: EdgeInsets.all(3.w),
                              ),
                              style: GoogleFonts.inter(fontSize: 12.sp),
                            ),

                            SizedBox(height: 3.h),

                            // Create Account Button
                            ElevatedButton(
                              onPressed: _isCreatingWallet
                                  ? null
                                  : _handleCreateAiFERiDAccount,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.all(4.w),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(2.w),
                                ),
                              ),
                              child: _isCreatingWallet
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 5.w,
                                          height: 5.w,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.white),
                                          ),
                                        ),
                                        SizedBox(width: 3.w),
                                        Text(
                                          'Creating AiFERiD...',
                                          style: GoogleFonts.inter(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Text(
                                      'Create New AiFERiD Account',
                                      style: GoogleFonts.inter(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),

                            SizedBox(height: 4.h),

                            // Error/Success Messages
                            if (_errorMessage != null) ...[
                              Container(
                                padding: EdgeInsets.all(3.w),
                                decoration: BoxDecoration(
                                  color: Colors.red.withAlpha(26),
                                  borderRadius: BorderRadius.circular(2.w),
                                  border: Border.all(
                                      color: Colors.red.withAlpha(77)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.error_outline,
                                        color: Colors.red, size: 5.w),
                                    SizedBox(width: 2.w),
                                    Expanded(
                                      child: Text(
                                        _errorMessage!,
                                        style: GoogleFonts.inter(
                                          fontSize: 12.sp,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            if (_successMessage != null) ...[
                              Container(
                                padding: EdgeInsets.all(3.w),
                                decoration: BoxDecoration(
                                  color: Colors.green.withAlpha(26),
                                  borderRadius: BorderRadius.circular(2.w),
                                  border: Border.all(
                                      color: Colors.green.withAlpha(77)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.check_circle_outline,
                                        color: Colors.green, size: 5.w),
                                    SizedBox(width: 2.w),
                                    Expanded(
                                      child: Text(
                                        _successMessage!,
                                        style: GoogleFonts.inter(
                                          fontSize: 12.sp,
                                          color: Colors.green[800],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Footer
              Padding(
                padding: EdgeInsets.only(bottom: 4.h),
                child: Column(
                  children: [
                    Text(
                      'By continuing, you agree to AiFER Network privacy policy',
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        color: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.color
                            ?.withAlpha(153),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 1.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lock_outline,
                          size: 3.w,
                          color: Color(0xFF6C63FF),
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          'Blockchain secured authentication',
                          style: GoogleFonts.inter(
                            fontSize: 10.sp,
                            color: Color(0xFF6C63FF),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _aiferidController.dispose();
    _accountNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}