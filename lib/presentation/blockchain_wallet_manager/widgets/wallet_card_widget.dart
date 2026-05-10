import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';
import '../../../services/blockchain_wallet_service.dart';

class WalletCardWidget extends StatelessWidget {
  final BlockchainWallet wallet;
  final VoidCallback? onVerify;

  const WalletCardWidget({
    Key? key,
    required this.wallet,
    this.onVerify,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(4.w),
        border: Border.all(
          color: Theme.of(context).dividerColor.withAlpha(77),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with wallet type and verification status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 10.w,
                    height: 10.w,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _getWalletColors(wallet.type),
                      ),
                      borderRadius: BorderRadius.circular(2.w),
                    ),
                    child: Icon(
                      _getWalletIcon(wallet.type),
                      color: Colors.white,
                      size: 5.w,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        wallet.accountName,
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color:
                              Theme.of(context).textTheme.headlineMedium?.color,
                        ),
                      ),
                      Text(
                        '${wallet.type.toString().split('.').last.toUpperCase()} Wallet',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color
                              ?.withAlpha(153),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: wallet.isVerified
                      ? Colors.green.withAlpha(26)
                      : Colors.orange.withAlpha(26),
                  borderRadius: BorderRadius.circular(1.w),
                ),
                child: Text(
                  wallet.isVerified ? 'Verified' : 'Pending',
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                    color: wallet.isVerified ? Colors.green : Colors.orange,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Wallet address
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(2.w),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Wallet Address',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withAlpha(153),
                  ),
                ),
                SizedBox(height: 1.h),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        wallet.address,
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: wallet.address));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Address copied to clipboard'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Icon(
                        Icons.copy,
                        size: 4.w,
                        color: Color(0xFF6C63FF),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 2.h),

          // Public key
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(2.w),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Public Key',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withAlpha(153),
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  wallet.publicKey,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
            ),
          ),

          SizedBox(height: 3.h),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onVerify,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF6C63FF),
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2.w),
                    ),
                  ),
                  child: Text(
                    wallet.isVerified ? 'Re-verify' : 'Verify Account',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _showWalletDetails(context);
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Color(0xFF6C63FF)),
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2.w),
                    ),
                  ),
                  child: Text(
                    'Details',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6C63FF),
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Creation date
          Text(
            'Created: ${_formatDate(wallet.createdAt)}',
            style: GoogleFonts.inter(
              fontSize: 10.sp,
              color:
                  Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(102),
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
        return [Color(0xFF6C63FF), Color(0xFF4B4ACF)];
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
        return Icons.bolt;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showWalletDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(5.w),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(5.w)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Wallet Details',
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.headlineLarge?.color,
              ),
            ),
            SizedBox(height: 3.h),
            _buildDetailRow('Account Name', wallet.accountName),
            _buildDetailRow('Wallet Type',
                wallet.type.toString().split('.').last.toUpperCase()),
            _buildDetailRow('Address', wallet.address),
            _buildDetailRow('Status',
                wallet.isVerified ? 'Verified' : 'Pending Verification'),
            _buildDetailRow('Created', _formatDate(wallet.createdAt)),
            SizedBox(height: 3.h),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 30.w,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}