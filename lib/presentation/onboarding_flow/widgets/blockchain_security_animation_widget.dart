import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class BlockchainSecurityAnimationWidget extends StatefulWidget {
  const BlockchainSecurityAnimationWidget({super.key});

  @override
  State<BlockchainSecurityAnimationWidget> createState() =>
      _BlockchainSecurityAnimationWidgetState();
}

class _BlockchainSecurityAnimationWidgetState
    extends State<BlockchainSecurityAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _blockController;
  late AnimationController _packageController;
  late Animation<double> _blockAnimation;
  late Animation<double> _packageAnimation;
  late Animation<Color?> _colorAnimation;

  final List<BlockData> _blocks = [
    BlockData(id: 'genesis', hash: '0x1a2b3c', isGenesis: true),
    BlockData(id: 'block1', hash: '0x4d5e6f', isGenesis: false),
    BlockData(id: 'block2', hash: '0x7g8h9i', isGenesis: false),
    BlockData(id: 'block3', hash: '0xjklmno', isGenesis: false),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _blockController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );

    _packageController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _blockAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _blockController,
      curve: Curves.easeInOut,
    ));

    _packageAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _packageController,
      curve: Curves.bounceOut,
    ));

    _colorAnimation = ColorTween(
      begin: AppTheme.textSecondary,
      end: AppTheme.accentColor,
    ).animate(CurvedAnimation(
      parent: _packageController,
      curve: Curves.easeInOut,
    ));

    _blockController.repeat();
    _packageController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _blockController.dispose();
    _packageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        _packageController.reset();
        _packageController.forward();
      },
      child: Container(
        width: 100.w,
        height: 50.h,
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              isDark
                  ? AppTheme.primaryLight.withValues(alpha: 0.1)
                  : AppTheme.primaryLight.withValues(alpha: 0.05),
              Colors.transparent,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            // Blockchain visualization
            Expanded(
              flex: 3,
              child: AnimatedBuilder(
                animation: _blockAnimation,
                builder: (context, child) {
                  return _buildBlockchain(isDark);
                },
              ),
            ),

            SizedBox(height: 3.h),

            // Package creation area
            Expanded(
              flex: 2,
              child: AnimatedBuilder(
                animation: _packageAnimation,
                builder: (context, child) {
                  return _buildPackageCreation(isDark);
                },
              ),
            ),

            SizedBox(height: 2.h),

            // Interaction hint
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: isDark
                    ? AppTheme.surfaceDark.withValues(alpha: 0.9)
                    : AppTheme.surfaceLight.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.accentColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: 'security',
                    color: AppTheme.accentColor,
                    size: 16,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Tik om .AiF pakket te maken',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.accentColor,
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

  Widget _buildBlockchain(bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _blocks.asMap().entries.map((entry) {
          final index = entry.key;
          final block = entry.value;

          return Row(
            children: [
              _buildBlock(block, isDark, index),
              if (index < _blocks.length - 1) _buildConnection(isDark),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBlock(BlockData block, bool isDark, int index) {
    final animationDelay = index * 0.25;
    final blockProgress =
        (_blockAnimation.value - animationDelay).clamp(0.0, 1.0);

    return Transform.scale(
      scale: 0.8 + (blockProgress * 0.2),
      child: Container(
        width: 20.w,
        height: 15.h,
        margin: EdgeInsets.symmetric(horizontal: 1.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: block.isGenesis
                ? [
                    AppTheme.warningColor,
                    AppTheme.warningColor.withValues(alpha: 0.8),
                  ]
                : [
                    AppTheme.accentColor,
                    AppTheme.accentColor.withValues(alpha: 0.8),
                  ],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: (block.isGenesis
                      ? AppTheme.warningColor
                      : AppTheme.accentColor)
                  .withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: block.isGenesis ? 'diamond' : 'lock',
              color: AppTheme.primaryLight,
              size: 24,
            ),
            SizedBox(height: 1.h),
            Text(
              block.isGenesis ? 'Genesis' : 'Block ${index}',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryLight,
              ),
            ),
            SizedBox(height: 0.5.h),
            Text(
              block.hash,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 8.sp,
                fontWeight: FontWeight.w400,
                color: AppTheme.primaryLight.withValues(alpha: 0.8),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnection(bool isDark) {
    return Container(
      width: 8.w,
      height: 2,
      decoration: BoxDecoration(
        color: AppTheme.accentColor,
        borderRadius: BorderRadius.circular(1),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentColor.withValues(alpha: 0.4),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildPackageCreation(bool isDark) {
    return Container(
      width: 100.w,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.surfaceDark.withValues(alpha: 0.5)
            : AppTheme.surfaceLight.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _colorAnimation.value ?? AppTheme.textSecondary,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          // Message input simulation
          Expanded(
            flex: 3,
            child: Container(
              height: 6.h,
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color:
                    isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'message',
                    color: isDark
                        ? AppTheme.textSecondaryDark
                        : AppTheme.textSecondary,
                    size: 20,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      'Veilig bericht...',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: isDark
                            ? AppTheme.textSecondaryDark
                            : AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(width: 3.w),

          // Encryption arrow
          Transform.scale(
            scale: _packageAnimation.value,
            child: CustomIconWidget(
              iconName: 'arrow_forward',
              color: _colorAnimation.value ?? AppTheme.textSecondary,
              size: 24,
            ),
          ),

          SizedBox(width: 3.w),

          // Encrypted package
          Expanded(
            flex: 2,
            child: Transform.scale(
              scale: 0.8 + (_packageAnimation.value * 0.2),
              child: Container(
                height: 6.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.successColor,
                      AppTheme.successColor.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.successColor.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIconWidget(
                        iconName: 'verified_user',
                        color: AppTheme.primaryLight,
                        size: 20,
                      ),
                      Text(
                        '.AiF',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BlockData {
  final String id;
  final String hash;
  final bool isGenesis;

  BlockData({
    required this.id,
    required this.hash,
    required this.isGenesis,
  });
}
