import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';
import '../../../services/blockchain_wallet_service.dart';

class WalletCreationForm extends StatefulWidget {
  final Function(String accountName, WalletType type) onWalletCreated;
  final bool isLoading;

  const WalletCreationForm({
    Key? key,
    required this.onWalletCreated,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<WalletCreationForm> createState() => _WalletCreationFormState();
}

class _WalletCreationFormState extends State<WalletCreationForm> {
  final _formKey = GlobalKey<FormState>();
  final _accountNameController = TextEditingController();
  WalletType _selectedWalletType = WalletType.stellar;
  bool _showAdvancedOptions = false;

  @override
  void dispose() {
    _accountNameController.dispose();
    super.dispose();
  }

  void _createWallet() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onWalletCreated(
        _accountNameController.text.trim(),
        _selectedWalletType,
      );
    }
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
              'Create New Wallet',
              style: GoogleFonts.inter(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.headlineLarge?.color,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Generate a secure blockchain wallet for offline verification and account management.',
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
                  enabled: !widget.isLoading,
                  decoration: InputDecoration(
                    hintText: 'Enter a unique account name',
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
                      Icons.person_outline,
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
                    if (value.trim().length > 32) {
                      return 'Account name must be less than 32 characters';
                    }
                    if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(value.trim())) {
                      return 'Only letters, numbers, _ and - allowed';
                    }
                    return null;
                  },
                ),
              ],
            ),

            SizedBox(height: 3.h),

            // Wallet type selection
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Blockchain Network',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                SizedBox(height: 2.h),
                ...WalletType.values
                    .map((type) => _buildWalletTypeOption(type)),
              ],
            ),

            SizedBox(height: 3.h),

            // Advanced options toggle
            GestureDetector(
              onTap: () {
                setState(() {
                  _showAdvancedOptions = !_showAdvancedOptions;
                });
              },
              child: Row(
                children: [
                  Icon(
                    _showAdvancedOptions
                        ? Icons.expand_less
                        : Icons.expand_more,
                    color: Color(0xFF6C63FF),
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Advanced Options',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6C63FF),
                    ),
                  ),
                ],
              ),
            ),

            if (_showAdvancedOptions) ...[
              SizedBox(height: 2.h),
              _buildAdvancedOptions(),
            ],

            SizedBox(height: 5.h),

            // Create button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.isLoading ? null : _createWallet,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF6C63FF),
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3.w),
                  ),
                ),
                child: widget.isLoading
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
                            'Creating Wallet...',
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        'Create Wallet',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),

            SizedBox(height: 3.h),

            // Security notice
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: Colors.blue.withAlpha(26),
                borderRadius: BorderRadius.circular(3.w),
                border: Border.all(
                  color: Colors.blue.withAlpha(77),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.security,
                    color: Colors.blue,
                    size: 5.w,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Security Notice',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          'Your wallet will be encrypted and stored securely on this device. Keys are generated locally and never transmitted over the network.',
                          style: GoogleFonts.inter(
                            fontSize: 10.sp,
                            color: Colors.blue,
                          ),
                        ),
                      ],
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

  Widget _buildWalletTypeOption(WalletType type) {
    final isSelected = _selectedWalletType == type;

    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: GestureDetector(
        onTap: widget.isLoading
            ? null
            : () {
                setState(() {
                  _selectedWalletType = type;
                });
              },
        child: Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: isSelected
                ? Color(0xFF6C63FF).withAlpha(26)
                : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(3.w),
            border: Border.all(
              color: isSelected
                  ? Color(0xFF6C63FF)
                  : Theme.of(context).dividerColor.withAlpha(77),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _getWalletColors(type),
                  ),
                  borderRadius: BorderRadius.circular(2.w),
                ),
                child: Icon(
                  _getWalletIcon(type),
                  color: Colors.white,
                  size: 6.w,
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getWalletDisplayName(type),
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Color(0xFF6C63FF)
                            : Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      _getWalletDescription(type),
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
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: Color(0xFF6C63FF),
                  size: 6.w,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdvancedOptions() {
    return Container(
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
            'Advanced Configuration',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            '• Offline verification enabled by default\n'
            '• Keys encrypted with device security\n'
            '• Automatic backup to secure cloud (when online)\n'
            '• Cross-platform synchronization',
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              color:
                  Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(153),
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _getWalletColors(WalletType type) {
    switch (type) {
      case WalletType.stellar:
        return [Color(0xFF000000), Color(0xFF333333)];
      case WalletType.sui:
        return [Color(0xFF4DA6FF), Color(0xFF0066CC)];
      case WalletType.ethereum:
        return [Color(0xFF627EEA), Color(0xFF4B63C7)];
      case WalletType.fer:
        return [Color(0xFF6C63FF), Color(0xFF5548E0)];
    }
  }

  IconData _getWalletIcon(WalletType type) {
    switch (type) {
      case WalletType.stellar:
        return Icons.star;
      case WalletType.sui:
        return Icons.waves;
      case WalletType.ethereum:
        return Icons.diamond;
      case WalletType.fer:
        return Icons.account_balance_wallet;
    }
  }

  String _getWalletDisplayName(WalletType type) {
    switch (type) {
      case WalletType.stellar:
        return 'Stellar (XLM)';
      case WalletType.sui:
        return 'SUI Network';
      case WalletType.ethereum:
        return 'Ethereum (ETH)';
      case WalletType.fer:
        return 'FER Network';
    }
  }

  String _getWalletDescription(WalletType type) {
    switch (type) {
      case WalletType.stellar:
        return 'Fast, low-cost global payments';
      case WalletType.sui:
        return 'Next-generation smart contract platform';
      case WalletType.ethereum:
        return 'Decentralized applications and DeFi';
      case WalletType.fer:
        return 'AiFER Network blockchain';
    }
  }
}