import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RecoveryPhraseDisplay extends StatefulWidget {
  final List<String> recoveryPhrase;
  final VoidCallback onContinue;
  final VoidCallback onBack;

  const RecoveryPhraseDisplay({
    super.key,
    required this.recoveryPhrase,
    required this.onContinue,
    required this.onBack,
  });

  @override
  State<RecoveryPhraseDisplay> createState() => _RecoveryPhraseDisplayState();
}

class _RecoveryPhraseDisplayState extends State<RecoveryPhraseDisplay>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _warningController;
  late List<Animation<double>> _wordAnimations;
  late Animation<double> _warningAnimation;
  bool _isRevealed = false;
  bool _isCopied = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _warningController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _warningAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _warningController,
      curve: Curves.easeInOut,
    ));

    _wordAnimations = List.generate(
      widget.recoveryPhrase.length,
      (index) => Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          index * 0.08,
          (index * 0.08) + 0.3,
          curve: Curves.elasticOut,
        ),
      )),
    );

    _warningController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _warningController.dispose();
    super.dispose();
  }

  void _revealPhrase() {
    setState(() {
      _isRevealed = true;
    });
    _animationController.forward();
    HapticFeedback.mediumImpact();
  }

  void _copyToClipboard() {
    final phraseText = widget.recoveryPhrase.join(' ');
    Clipboard.setData(ClipboardData(text: phraseText));
    setState(() {
      _isCopied = true;
    });
    HapticFeedback.lightImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Herstelzin gekopieerd naar klembord',
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: AppTheme.successColor,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );

    // Reset copied state after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isCopied = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            GestureDetector(
              onTap: widget.onBack,
              child: Container(
                width: 10.w,
                height: 10.w,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppTheme.surfaceDark.withValues(alpha: 0.8)
                      : AppTheme.surfaceLight.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? AppTheme.dividerDark.withValues(alpha: 0.3)
                        : AppTheme.dividerLight.withValues(alpha: 0.3),
                  ),
                ),
                child: Center(
                  child: CustomIconWidget(
                    iconName: 'arrow_back_ios',
                    color: isDark
                        ? AppTheme.textPrimaryDark
                        : AppTheme.textPrimary,
                    size: 5.w,
                  ),
                ),
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Text(
                'Herstelzin Genereren',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color:
                      isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 3.h),

        // Security Warning
        AnimatedBuilder(
          animation: _warningAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _warningAnimation.value,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: AppTheme.warningColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.warningColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'warning',
                      color: AppTheme.warningColor,
                      size: 6.w,
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Beveiligingswaarschuwing',
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.warningColor,
                            ),
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            'Bewaar deze woorden veilig. Verlies betekent permanent verlies van toegang tot je FERMesh wallet.',
                            style: GoogleFonts.inter(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w400,
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
              ),
            );
          },
        ),

        SizedBox(height: 3.h),

        // Recovery Phrase Container
        Container(
          width: double.infinity,
          constraints: BoxConstraints(
            minHeight: 30.h,
          ),
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: isDark
                ? AppTheme.surfaceDark.withValues(alpha: 0.5)
                : AppTheme.surfaceLight.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? AppTheme.dividerDark.withValues(alpha: 0.3)
                  : AppTheme.dividerLight.withValues(alpha: 0.3),
            ),
          ),
          child: _isRevealed
              ? _buildRevealedPhrase(isDark)
              : _buildHiddenPhrase(isDark),
        ),

        SizedBox(height: 3.h),

        // Action Buttons
        if (_isRevealed) ...[
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _copyToClipboard,
                  icon: CustomIconWidget(
                    iconName: _isCopied ? 'check' : 'copy',
                    color: _isCopied
                        ? AppTheme.successColor
                        : AppTheme.surfaceLight,
                    size: 4.w,
                  ),
                  label: Text(
                    _isCopied ? 'Gekopieerd!' : 'Kopiëren',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isCopied
                        ? AppTheme.successColor
                        : AppTheme.accentColor,
                    foregroundColor: AppTheme.surfaceLight,
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: widget.onContinue,
                  child: Text(
                    'Doorgaan',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryLight,
                    foregroundColor: AppTheme.surfaceLight,
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ] else ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _revealPhrase,
              icon: CustomIconWidget(
                iconName: 'visibility',
                color: AppTheme.surfaceLight,
                size: 5.w,
              ),
              label: Text(
                'Herstelzin Tonen',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
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
      ],
    );
  }

  Widget _buildHiddenPhrase(bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomIconWidget(
          iconName: 'visibility_off',
          color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
          size: 12.w,
        ),
        SizedBox(height: 2.h),
        Text(
          'Herstelzin Verborgen',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          'Tik op "Herstelzin Tonen" om je 12-woord herstelzin te bekijken',
          style: GoogleFonts.inter(
            fontSize: 11.sp,
            fontWeight: FontWeight.w400,
            color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRevealedPhrase(bool isDark) {
    return Column(
      children: [
        Text(
          'Je 12-Woord Herstelzin',
          style: GoogleFonts.inter(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 2.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 2.w,
            mainAxisSpacing: 1.h,
            childAspectRatio: 2.5,
          ),
          itemCount: widget.recoveryPhrase.length,
          itemBuilder: (context, index) {
            return AnimatedBuilder(
              animation: _wordAnimations[index],
              builder: (context, child) {
                return Transform.scale(
                  scale: _wordAnimations[index].value,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.accentColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${index + 1}',
                          style: GoogleFonts.inter(
                            fontSize: 8.sp,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.accentColor,
                          ),
                        ),
                        Text(
                          widget.recoveryPhrase[index],
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppTheme.textPrimaryDark
                                : AppTheme.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
