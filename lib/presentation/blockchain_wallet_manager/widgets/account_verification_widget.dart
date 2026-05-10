import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';
import '../../../services/blockchain_wallet_service.dart';

class AccountVerificationWidget extends StatefulWidget {
  const AccountVerificationWidget({Key? key}) : super(key: key);

  @override
  State<AccountVerificationWidget> createState() =>
      _AccountVerificationWidgetState();
}

class _AccountVerificationWidgetState extends State<AccountVerificationWidget> {
  final _formKey = GlobalKey<FormState>();
  final _accountNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _walletService = BlockchainWalletService.instance;

  bool _isVerifying = false;
  String? _verificationResult;
  bool? _isVerificationSuccess;

  @override
  void dispose() {
    _accountNameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _verifyAccount() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isVerifying = true;
      _verificationResult = null;
      _isVerificationSuccess = null;
    });

    try {
      final success = await _walletService.verifyAccountName(
        _accountNameController.text.trim(),
        _addressController.text.trim(),
      );

      setState(() {
        _isVerifying = false;
        _isVerificationSuccess = success;
        _verificationResult = success
            ? 'Account verified successfully! This account is now trusted for offline use.'
            : 'Verification failed. Please check the account name and wallet address.';
      });
    } catch (e) {
      setState(() {
        _isVerifying = false;
        _isVerificationSuccess = false;
        _verificationResult = 'Verification error: ${e.toString()}';
      });
    }
  }

  void _clearForm() {
    _accountNameController.clear();
    _addressController.clear();
    setState(() {
      _verificationResult = null;
      _isVerificationSuccess = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(5.w),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Verify Account',
              style: GoogleFonts.inter(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.headlineLarge?.color,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Verify blockchain account credentials for secure offline authentication and transactions.',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.color
                    ?.withAlpha(153),
              ),
            ),

            SizedBox(height: 4.h),

            // Account name input
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Account Name',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                SizedBox(height: 1.h),
                TextFormField(
                  controller: _accountNameController,
                  enabled: !_isVerifying,
                  decoration: InputDecoration(
                    hintText: 'Enter account name to verify',
                    hintStyle: GoogleFonts.inter(
                      color: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color
                          ?.withAlpha(102),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(3.w),
                      borderSide: BorderSide(
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(3.w),
                      borderSide: BorderSide(
                        color: Color(0xFF6C63FF),
                        width: 2,
                      ),
                    ),
                    prefixIcon: Icon(
                      Icons.account_circle_outlined,
                      color: Color(0xFF6C63FF),
                      size: 5.w,
                    ),
                  ),
                  validator: (value) {
                    if (value?.trim().isEmpty ?? true) {
                      return 'Account name is required';
                    }
                    if (value!.trim().length < 3) {
                      return 'Account name must be at least 3 characters';
                    }
                    return null;
                  },
                ),
              ],
            ),

            SizedBox(height: 3.h),

            // Wallet address input
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Wallet Address',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                SizedBox(height: 1.h),
                TextFormField(
                  controller: _addressController,
                  enabled: !_isVerifying,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Enter blockchain wallet address',
                    hintStyle: GoogleFonts.inter(
                      color: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color
                          ?.withAlpha(102),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(3.w),
                      borderSide: BorderSide(
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(3.w),
                      borderSide: BorderSide(
                        color: Color(0xFF6C63FF),
                        width: 2,
                      ),
                    ),
                    prefixIcon: Icon(
                      Icons.wallet_outlined,
                      color: Color(0xFF6C63FF),
                      size: 5.w,
                    ),
                  ),
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                  ),
                  validator: (value) {
                    if (value?.trim().isEmpty ?? true) {
                      return 'Wallet address is required';
                    }
                    if (value!.trim().length < 20) {
                      return 'Invalid wallet address format';
                    }
                    return null;
                  },
                ),
              ],
            ),

            SizedBox(height: 4.h),

            // Verify button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isVerifying ? null : _verifyAccount,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF6C63FF),
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3.w),
                  ),
                ),
                child: _isVerifying
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 5.w,
                            height: 5.w,
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Text(
                            'Verifying Account...',
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        'Verify Account',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),

            if (_verificationResult != null) ...[
              SizedBox(height: 3.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: _isVerificationSuccess == true
                      ? Colors.green.withAlpha(26)
                      : Colors.red.withAlpha(26),
                  borderRadius: BorderRadius.circular(3.w),
                  border: Border.all(
                    color: _isVerificationSuccess == true
                        ? Colors.green.withAlpha(77)
                        : Colors.red.withAlpha(77),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      _isVerificationSuccess == true
                          ? Icons.check_circle_outline
                          : Icons.error_outline,
                      color: _isVerificationSuccess == true
                          ? Colors.green
                          : Colors.red,
                      size: 6.w,
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Text(
                        _verificationResult!,
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          color: _isVerificationSuccess == true
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            SizedBox(height: 3.h),

            // Clear form button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _isVerifying ? null : _clearForm,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Color(0xFF6C63FF).withAlpha(128)),
                  padding: EdgeInsets.symmetric(vertical: 1.5.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3.w),
                  ),
                ),
                child: Text(
                  'Clear Form',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6C63FF),
                  ),
                ),
              ),
            ),

            SizedBox(height: 4.h),

            // Verification methods info
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: Colors.blue.withAlpha(26),
                borderRadius: BorderRadius.circular(3.w),
                border: Border.all(
                  color: Colors.blue.withAlpha(77),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue,
                        size: 5.w,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Verification Methods',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '1. Online Database Check - Verifies against stored accounts\n'
                    '2. Offline Cache Lookup - Uses previously verified accounts\n'
                    '3. Cryptographic Validation - Validates wallet address format\n'
                    '4. Blockchain Network Query - Direct network verification (when online)',
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 3.h),

            // Supported formats
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor.withAlpha(128),
                borderRadius: BorderRadius.circular(3.w),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withAlpha(77),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Supported Wallet Formats',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    '• Stellar (XLM): G... (56 characters)\n'
                    '• Ethereum (ETH): 0x... (42 characters)\n'
                    '• SUI Network: 32-64 character strings',
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      color: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color
                          ?.withAlpha(153),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}