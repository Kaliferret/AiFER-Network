import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

/// Blockchain Wallet Generator Widget showing wallet generation status
class BlockchainWalletGeneratorWidget extends StatelessWidget {
  final Map<String, dynamic>? walletInfo;
  final VoidCallback onViewDetails;

  const BlockchainWalletGeneratorWidget({
    Key? key,
    this.walletInfo,
    required this.onViewDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool walletsGenerated = walletInfo?['wallets_generated'] == true;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: walletsGenerated
              ? [Colors.green.withAlpha(26), Colors.green.withAlpha(13)]
              : [
                  Theme.of(context).primaryColor.withAlpha(26),
                  Theme.of(context).primaryColor.withAlpha(13),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: walletsGenerated
              ? Colors.green.withAlpha(77)
              : Theme.of(context).primaryColor.withAlpha(77),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  color: walletsGenerated
                      ? Colors.green
                      : Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (walletsGenerated
                              ? Colors.green
                              : Theme.of(context).primaryColor)
                          .withAlpha(77),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  walletsGenerated
                      ? Icons.account_balance_wallet
                      : Icons.generating_tokens,
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
                      'Blockchain Wallets',
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                    SizedBox(height: 1.w),
                    Text(
                      walletsGenerated
                          ? 'Stellar & SUI wallets configured'
                          : 'Generating secure wallets...',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: walletsGenerated
                            ? Colors.green
                            : Theme.of(context).textTheme.bodyMedium?.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (walletsGenerated)
                IconButton(
                  onPressed: onViewDetails,
                  icon: Icon(
                    Icons.visibility,
                    color: Theme.of(context).primaryColor,
                    size: 6.w,
                  ),
                ),
            ],
          ),
          if (walletInfo != null) ...[
            SizedBox(height: 4.w),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor.withAlpha(128),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withAlpha(51),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWalletStatus(
                      'FERMesh Node ID', walletInfo!['fermesh_node_id']),
                  SizedBox(height: 2.w),
                  Row(
                    children: [
                      Expanded(
                        child: _buildWalletChain(
                          'Stellar',
                          walletInfo!['stellar_address'] != null,
                          Colors.blue,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: _buildWalletChain(
                          'SUI',
                          walletInfo!['sui_address'] != null,
                          Colors.cyan,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWalletStatus(String label, String? value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11.sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 1.w),
        Text(
          value ?? 'Generating...',
          style: GoogleFonts.robotoMono(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: value != null ? Colors.green : Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildWalletChain(
      String chainName, bool isGenerated, Color chainColor) {
    return Container(
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: chainColor.withAlpha(26),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: chainColor.withAlpha(77),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 6.w,
            height: 6.w,
            decoration: BoxDecoration(
              color: isGenerated ? chainColor : Colors.grey,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isGenerated ? Icons.check : Icons.hourglass_empty,
              color: Colors.white,
              size: 3.w,
            ),
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              chainName,
              style: GoogleFonts.inter(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: isGenerated ? chainColor : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
