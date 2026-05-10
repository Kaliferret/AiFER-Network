
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class MessageInputWidget extends StatefulWidget {
  final Function(String, String) onSendMessage;
  final Function(String, String) onSendVoiceMessage;
  final Function(String, String, String) onSendImageMessage;
  final Function(String, String, String) onSendFileMessage;
  final bool isAIChat; // New parameter

  const MessageInputWidget({
    super.key,
    required this.onSendMessage,
    required this.onSendVoiceMessage,
    required this.onSendImageMessage,
    required this.onSendFileMessage,
    this.isAIChat = false, // Default to false
  });

  @override
  State<MessageInputWidget> createState() => _MessageInputWidgetState();
}

class _MessageInputWidgetState extends State<MessageInputWidget>
    with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  late AnimationController _sendButtonController;
  late Animation<double> _sendButtonScaleAnimation;

  String _selectedPackageType = '.AiF';
  bool _isRecording = false;
  bool _showAttachmentMenu = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _textController.addListener(_onTextChanged);
  }

  void _initializeAnimations() {
    _sendButtonController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _sendButtonScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _sendButtonController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    _sendButtonController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _textController.text.trim().isNotEmpty;
    if (hasText && !_sendButtonController.isCompleted) {
      _sendButtonController.forward();
    } else if (!hasText && _sendButtonController.isCompleted) {
      _sendButtonController.reverse();
    }
  }

  void _sendMessage() {
    final message = _textController.text.trim();
    if (message.isEmpty) return;

    widget.onSendMessage(message, _selectedPackageType);
    _textController.clear();
    _sendButtonController.reverse();
  }

  void _showPackageTypeSelector() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.isAIChat ? 'AiFER Package Type' : 'FERMesh Package Type',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color:
                      isDark ? AppTheme.textPrimaryDark : AppTheme.primaryLight,
                ),
              ),
              SizedBox(height: 3.h),

              // AI-optimized package types
              if (widget.isAIChat) ...[
                _buildPackageOption(
                  '.AiF',
                  'AI Standard',
                  'Fast AI responses with public visibility',
                  Icons.smart_toy,
                  AppTheme.accentColor,
                ),
                _buildPackageOption(
                  '.AiFp',
                  'AI Private',
                  'Private AI conversations with encryption',
                  Icons.lock_person,
                  AppTheme.warningColor,
                ),
              ] else ...[
                // Standard package types
                _buildPackageOption(
                  '.AiF',
                  'Standard',
                  'Public mesh network transmission',
                  Icons.wifi,
                  AppTheme.successColor,
                ),
                _buildPackageOption(
                  '.AiFp',
                  'Private',
                  'Encrypted with burn-after-reading',
                  Icons.lock,
                  AppTheme.warningColor,
                ),
                _buildPackageOption(
                  '.FERg',
                  'Gaming',
                  'Low-latency for gaming applications',
                  Icons.games,
                  AppTheme.errorColor,
                ),
              ],

              SizedBox(height: 2.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPackageOption(
    String packageType,
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isSelected = _selectedPackageType == packageType;

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedPackageType = packageType;
          });
          Navigator.pop(context);

          Fluttertoast.showToast(
            msg:
                widget.isAIChat ? "AiFER mode: $title" : "Package type: $title",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected
                  ? color
                  : (isDark
                      ? AppTheme.dividerDark.withValues(alpha: 0.3)
                      : AppTheme.dividerLight.withValues(alpha: 0.3)),
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
            color:
                isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          packageType,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: color,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'monospace',
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppTheme.textPrimaryDark
                                : AppTheme.primaryLight,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppTheme.textSecondaryDark.withValues(alpha: 0.8)
                            : AppTheme.textSecondary.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: color,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        border: Border(
          top: BorderSide(
            color: isDark
                ? AppTheme.dividerDark.withValues(alpha: 0.3)
                : AppTheme.dividerLight.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Package type indicator for AI chat
          if (widget.isAIChat) ...[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              margin: EdgeInsets.only(bottom: 1.h),
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.accentColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.auto_awesome,
                    color: AppTheme.accentColor,
                    size: 16,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    'AiFER Active • ${_selectedPackageType}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppTheme.accentColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Main input row
          Row(
            children: [
              // Package type selector
              InkWell(
                onTap: _showPackageTypeSelector,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: _getPackageTypeColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _getPackageTypeColor().withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _selectedPackageType,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: _getPackageTypeColor(),
                      fontWeight: FontWeight.w600,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),

              SizedBox(width: 2.w),

              // Message input field
              Expanded(
                child: TextField(
                  controller: _textController,
                  focusNode: _focusNode,
                  maxLines: null,
                  minLines: 1,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: widget.isAIChat
                        ? 'Ask AiFER anything...'
                        : 'Type a message...',
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark
                          ? AppTheme.textSecondaryDark.withValues(alpha: 0.6)
                          : AppTheme.textSecondary.withValues(alpha: 0.6),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: isDark
                        ? AppTheme.backgroundDark
                        : AppTheme.backgroundLight,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 2.h,
                    ),
                    suffixIcon: widget.isAIChat
                        ? Icon(
                            Icons.auto_awesome,
                            color: AppTheme.accentColor.withValues(alpha: 0.5),
                            size: 20,
                          )
                        : null,
                  ),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppTheme.textPrimaryDark
                        : AppTheme.primaryLight,
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),

              SizedBox(width: 2.w),

              // Send button
              AnimatedBuilder(
                animation: _sendButtonScaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _sendButtonScaleAnimation.value,
                    child: Container(
                      decoration: BoxDecoration(
                        color: _textController.text.trim().isNotEmpty
                            ? (widget.isAIChat
                                ? AppTheme.accentColor
                                : _getPackageTypeColor())
                            : (isDark
                                ? AppTheme.textSecondaryDark
                                    .withValues(alpha: 0.3)
                                : AppTheme.textSecondary
                                    .withValues(alpha: 0.3)),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: _textController.text.trim().isNotEmpty
                            ? _sendMessage
                            : null,
                        icon: Icon(
                          widget.isAIChat ? Icons.auto_awesome : Icons.send,
                          color: _textController.text.trim().isNotEmpty
                              ? AppTheme.surfaceLight
                              : (isDark
                                  ? AppTheme.textSecondaryDark
                                      .withValues(alpha: 0.5)
                                  : AppTheme.textSecondary
                                      .withValues(alpha: 0.5)),
                          size: 20,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),

          // AI suggestions for AI chat
          if (widget.isAIChat && _textController.text.isEmpty) ...[
            SizedBox(height: 2.h),
            _buildAISuggestions(),
          ],
        ],
      ),
    );
  }

  Widget _buildAISuggestions() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final suggestions = [
      'How to optimize FERMesh?',
      'Network status check',
      'Blockchain security tips',
      'Emergency protocols',
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: suggestions.map((suggestion) {
          return Container(
            margin: EdgeInsets.only(right: 2.w),
            child: InkWell(
              onTap: () {
                _textController.text = suggestion;
                _onTextChanged();
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.accentColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  suggestion,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppTheme.accentColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _getPackageTypeColor() {
    switch (_selectedPackageType) {
      case '.AiFp':
        return AppTheme.warningColor;
      case '.FERg':
        return AppTheme.errorColor;
      default:
        return AppTheme.successColor;
    }
  }
}