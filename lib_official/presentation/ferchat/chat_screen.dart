<![CDATA[import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/aiferid_auth_service.dart';
import '../../services/offline_first_database.dart';
import '../../widgets/unified_sliding_menu.dart';
import '../../core/fer_quantum_encryption.dart';

/// FERChat Screen - Main messaging interface
/// WhatsApp-like functionality with quantum encryption
class FERChatScreen extends StatefulWidget {
  final AiFERiDUserProfile? userProfile;
  final Function(FERAppType) onAppSelected;
  
  const FERChatScreen({
    Key? key,
    this.userProfile,
    required this.onAppSelected,
  }) : super(key: key);
  
  @override
  _FERChatScreenState createState() => _FERChatScreenState();
}

class _FERChatScreenState extends State<FERChatScreen> 
    with TickerProviderStateMixin {
  
  final OfflineFirstDatabase _database = OfflineFirstDatabase.instance;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<ChatConversation> _conversations = [];
  List<FERMessage> _messages = [];
  ChatConversation? _activeConversation;
  bool _isLoading = false;
  bool _isRecording = false;
  Timer? _recordingTimer;
  int _recordingDuration = 0;
  
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeChat();
  }
  
  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _tabController.dispose();
    _recordingTimer?.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Row(
        children: [
          // Conversations sidebar
          Container(
            width: 380.0,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border(
                right: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 0.5,
                ),
              ),
            ),
            child: _buildConversationsSidebar(),
          ),
          
          // Chat area
          Expanded(
            child: _activeConversation != null
              ? _buildChatArea()
              : _buildEmptyState(),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }
  
  /// Build conversations sidebar
  Widget _buildConversationsSidebar() {
    return Column(
      children: [
        // Search bar
        _buildSearchBar(),
        
        // Tabs
        _buildConversationTabs(),
        
        // Conversations list
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildConversationsList(ChatConversationType.recent),
              _buildConversationsList(ChatConversationType.groups),
              _buildConversationsList(ChatConversationType.anonymous),
            ],
          ),
        ),
      ],
    );
  }
  
  /// Build search bar
  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search conversations...',
          prefixIcon: Icon(Icons.search, color: FERColors.primary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: FERColors.primary.withOpacity(0.1),
          contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        ),
        onChanged: _onSearchChanged,
      ),
    );
  }
  
  /// Build conversation tabs
  Widget _buildConversationTabs() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: FERColors.primary,
          borderRadius: BorderRadius.circular(10.0),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Theme.of(context).textTheme.caption?.color,
        tabs: [
          Tab(text: 'Recent'),
          Tab(text: 'Groups'),
          Tab(text: 'Anonymous'),
        ],
      ),
    );
  }
  
  /// Build conversations list
  Widget _buildConversationsList(ChatConversationType type) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      itemCount: _conversations.length,
      itemBuilder: (context, index) {
        final conversation = _conversations[index];
        return _buildConversationItem(conversation);
      },
    );
  }
  
  /// Build individual conversation item
  Widget _buildConversationItem(ChatConversation conversation) {
    final isActive = _activeConversation?.id == conversation.id;
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _selectConversation(conversation),
          borderRadius: BorderRadius.circular(12.0),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            padding: EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: isActive 
                ? FERColors.primary.withOpacity(0.1)
                : Colors.transparent,
              borderRadius: BorderRadius.circular(12.0),
              border: isActive 
                ? Border.all(color: FERColors.primary, width: 1)
                : null,
            ),
            child: Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 24.0,
                  backgroundColor: FERColors.primary.withOpacity(0.2),
                  backgroundImage: conversation.avatarUrl != null
                    ? NetworkImage(conversation.avatarUrl!)
                    : null,
                  child: conversation.avatarUrl == null
                    ? Icon(
                        conversation.isGroup ? Icons.group : Icons.person,
                        color: FERColors.primary,
                      )
                    : null,
                ),
                
                SizedBox(width: 12.0),
                
                // Conversation info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        conversation.displayName,
                        style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w600,
                          color: isActive 
                            ? FERColors.primary
                            : Theme.of(context).textTheme.titleLarge?.color,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2.0),
                      Text(
                        conversation.lastMessage,
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                // Message info
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatMessageTime(conversation.lastMessageTime),
                      style: TextStyle(
                        fontSize: 10.0,
                        color: Theme.of(context).textTheme.caption?.color,
                      ),
                    ),
                    SizedBox(height: 4.0),
                    if (conversation.unreadCount > 0)
                      Container(
                        padding: EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                          color: FERColors.accent,
                          shape: BoxShape.circle,
                        ),
                        constraints: BoxConstraints(
                          minWidth: 18.0,
                          minHeight: 18.0,
                        ),
                        child: Text(
                          conversation.unreadCount > 99 ? '99+' : conversation.unreadCount.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8.0,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  /// Build main chat area
  Widget _buildChatArea() {
    return Column(
      children: [
        // Chat header
        _buildChatHeader(),
        
        // Messages list
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/chat_background.png'),
                fit: BoxFit.cover,
                opacity: 0.03,
              ),
            ),
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
        ),
        
        // Message input area
        _buildMessageInputArea(),
      ],
    );
  }
  
  /// Build chat header
  Widget _buildChatHeader() {
    if (_activeConversation == null) return Container();
    
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 20.0,
            backgroundColor: FERColors.primary.withOpacity(0.2),
            backgroundImage: _activeConversation!.avatarUrl != null
              ? NetworkImage(_activeConversation!.avatarUrl!)
              : null,
            child: _activeConversation!.avatarUrl == null
              ? Icon(
                  _activeConversation!.isGroup ? Icons.group : Icons.person,
                  color: FERColors.primary,
                  size: 20.0,
                )
              : null,
          ),
          
          SizedBox(width: 12.0),
          
          // Conversation info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _activeConversation!.displayName,
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (_activeConversation!.isAnonymous) ...[
                      SizedBox(width: 6.0),
                      Icon(
                        Icons.privacy_tip,
                        size: 14.0,
                        color: FERColors.primary,
                      ),
                    ],
                  ],
                ),
                Text(
                  _activeConversation!.isOnline ? 'Active now' : 'Offline',
                  style: TextStyle(
                    fontSize: 12.0,
                    color: _activeConversation!.isOnline 
                      ? Colors.green
                      : Theme.of(context).textTheme.caption?.color,
                  ),
                ),
              ],
            ),
          ),
          
          // Action buttons
          Row(
            children: [
              IconButton(
                onPressed: _startVoiceCall,
                icon: Icon(Icons.phone, color: FERColors.primary),
                tooltip: 'Voice Call',
              ),
              IconButton(
                onPressed: _startVideoCall,
                icon: Icon(Icons.videocam, color: FERColors.primary),
                tooltip: 'Video Call',
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert),
                onSelected: _handleConversationMenu,
                itemBuilder: (context) => [
                  PopupMenuItem(value: 'info', child: Text('Conversation Info')),
                  PopupMenuItem(value: 'mute', child: Text('Mute Notifications')),
                  PopupMenuItem(value: 'clear', child: Text('Clear Chat')),
                  PopupMenuItem(value: 'block', child: Text('Block User')),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  /// Build message bubble
  Widget _buildMessageBubble(FERMessage message) {
    final isMyMessage = message.fromUserId == widget.userProfile?.id;
    
    return Container(
      margin: EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: isMyMessage 
          ? MainAxisAlignment.end 
          : MainAxisAlignment.start,
        children: [
          if (!isMyMessage) ...[
            // Sender avatar
            CircleAvatar(
              radius: 16.0,
              backgroundColor: FERColors.primary.withOpacity(0.2),
              child: Icon(
                Icons.person,
                size: 16.0,
                color: FERColors.primary,
              ),
            ),
            SizedBox(width: 8.0),
          ],
          
          // Message bubble
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: 280.0,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10.0,
              ),
              decoration: BoxDecoration(
                color: isMyMessage 
                  ? FERColors.primary
                  : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20.0).copyWith(
                  bottomLeft: isMyMessage ? Radius.circular(20.0) : Radius.circular(4.0),
                  bottomRight: isMyMessage ? Radius.circular(4.0) : Radius.circular(20.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Message content based on type
                  if (message.contentType == FERMessageContentType.text)
                    Text(
                      message.content,
                      style: TextStyle(
                        color: isMyMessage 
                          ? Colors.white
                          : Theme.of(context).textTheme.bodyLarge?.color,
                        fontSize: 14.0,
                      ),
                    )
                  else if (message.contentType == FERMessageContentType.image)
                    _buildImageMessage(message)
                  else if (message.contentType == FERMessageContentType.audio)
                    _buildAudioMessage(message)
                  else if (message.contentType == FERMessageContentType.file)
                    _buildFileMessage(message),
                  
                  SizedBox(height: 4.0),
                  
                  // Message metadata
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatMessageTime(message.timestamp),
                        style: TextStyle(
                          color: isMyMessage 
                            ? Colors.white70
                            : Theme.of(context).textTheme.caption?.color,
                          fontSize: 10.0,
                        ),
                      ),
                      SizedBox(width: 4.0),
                      if (isMyMessage)
                        Icon(
                          message.status == FERMessageStatus.read 
                            ? Icons.done_all
                            : message.status == FERMessageStatus.delivered
                              ? Icons.done_all
                              : Icons.done,
                          size: 12.0,
                          color: isMyMessage 
                            ? Colors.white70
                            : Theme.of(context).textTheme.caption?.color,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          if (isMyMessage) ...[
            SizedBox(width: 8.0),
            CircleAvatar(
              radius: 16.0,
              backgroundColor: FERColors.primary.withOpacity(0.2),
              backgroundImage: widget.userProfile?.ferretId.isNotEmpty == true
                ? null
                : NetworkImage('https://api.dicebear.com/7.x/avataaars/svg?seed=${widget.userProfile?.id}'),
              child: widget.userProfile?.ferretId.isNotEmpty == true
                ? Icon(Icons.pets, size: 16.0, color: FERColors.primary)
                : null,
            ),
          ],
        ],
      ),
    );
  }
  
  /// Build image message
  Widget _buildImageMessage(FERMessage message) {
    return Container(
      width: 200.0,
      height: 150.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: Colors.grey.withOpacity(0.1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: Image.network(
          message.content,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 200.0,
              height: 150.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image, size: 40.0, color: Colors.grey),
                  Text('Image not available', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
  
  /// Build audio message
  Widget _buildAudioMessage(FERMessage message) {
    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.play_circle, size: 24.0, color: FERColors.primary),
          SizedBox(width: 8.0),
          Text('0:12', style: TextStyle(fontSize: 12.0)),
        ],
      ),
    );
  }
  
  /// Build file message
  Widget _buildFileMessage(FERMessage message) {
    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.insert_drive_file, size: 20.0, color: FERColors.primary),
          SizedBox(width: 8.0),
          Flexible(
            child: Text(
              'document.pdf',
              style: TextStyle(fontSize: 12.0),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 4.0),
          Text('(2.3 MB)', style: TextStyle(fontSize: 10.0)),
        ],
      ),
    );
  }
  
  /// Build message input area
  Widget _buildMessageInputArea() {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        children: [
          // Typing indicator (for active conversation)
          if (_activeConversation != null && _activeConversation!.isTyping)
            Container(
              padding: EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 16.0,
                    height: 2.0,
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(FERColors.primary),
                    ),
                  ),
                  SizedBox(width: 8.0),
                  Text(
                    '${_activeConversation!.displayName} is typing...',
                    style: TextStyle(
                      fontSize: 12.0,
                      color: FERColors.primary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          
          Row(
            children: [
              // Attachment button
              IconButton(
                onPressed: _showAttachmentOptions,
                icon: Icon(Icons.attach_file),
                color: FERColors.primary,
                tooltip: 'Attach File',
              ),
              
              // Message input field
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey.withOpacity(0.1),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                  ),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: _onMessageChanged,
                ),
              ),
              
              SizedBox(width: 8.0),
              
              // Voice recording button or send button
              if (_messageController.text.trim().isEmpty)
                GestureDetector(
                  onLongPressStart: _startVoiceRecording,
                  onLongPressEnd: _stopVoiceRecording,
                  onTap: _isRecording ? _stopVoiceRecording : null,
                  child: Container(
                    width: 40.0,
                    height: 40.0,
                    decoration: BoxDecoration(
                      color: _isRecording ? Colors.red : FERColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isRecording ? Icons.stop : Icons.mic,
                      color: Colors.white,
                      size: 20.0,
                    ),
                  ),
                )
              else
                Container(
                  width: 40.0,
                  height: 40.0,
                  decoration: BoxDecoration(
                    color: FERColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: _sendMessage,
                    icon: Icon(Icons.send, color: Colors.white, size: 20.0),
                    padding: EdgeInsets.zero,
                  ),
                ),
            ],
          ),
          
          // Recording indicator
          if (_isRecording)
            Container(
              margin: EdgeInsets.only(top: 8.0),
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.mic, color: Colors.red, size: 16.0),
                  SizedBox(width: 8.0),
                  Text(
                    'Recording... ${_formatDuration(_recordingDuration)}',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12.0,
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
  
  /// Build empty state
  Widget _buildEmptyState() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat,
            size: 80.0,
            color: Colors.grey.withOpacity(0.3),
          ),
          SizedBox(height: 16.0),
          Text(
            'Select a conversation',
            style: TextStyle(
              fontSize: 18.0,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.0),
          Text(
            'Choose from your recent conversations or start a new one',
            style: TextStyle(
              fontSize: 14.0,
              color: Colors.grey.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
  
  /// Build floating action button
  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _startNewConversation,
      icon: Icon(Icons.add),
      label: Text('New Chat'),
      backgroundColor: FERColors.primary,
      foregroundColor: Colors.white,
    );
  }
  
  /// Initialize chat screen
  Future<void> _initializeChat() async {
    setState(() => _isLoading = true);
    
    try {
      await _database.initialize();
      await _loadConversations();
    } catch (e) {
      debugPrint('Failed to initialize chat: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  /// Load conversations
  Future<void> _loadConversations() async {
    // Simulate loading conversations
    final conversations = [
      ChatConversation(
        id: '1',
        displayName: 'Alice',
        avatarUrl: 'https://i.pravatar.cc/150?img=1',
        lastMessage: 'Hey! How are you?',
        lastMessageTime: DateTime.now().subtract(Duration(minutes: 5)),
        unreadCount: 2,
        isOnline: true,
        isGroup: false,
        isAnonymous: false,
      ),
      ChatConversation(
        id: '2',
        displayName: 'FER Gaming Group',
        avatarUrl: null,
        lastMessage: 'Anyone up for a game?',
        lastMessageTime: DateTime.now().subtract(Duration(hours: 1)),
        unreadCount: 0,
        isOnline: false,
        isGroup: true,
        isAnonymous: false,
      ),
      ChatConversation(
        id: '3',
        displayName: 'AnonymousFerret42',
        avatarUrl: null,
        lastMessage: 'Private message sent via FER network',
        lastMessageTime: DateTime.now().subtract(Duration(minutes: 30)),
        unreadCount: 1,
        isOnline: false,
        isGroup: false,
        isAnonymous: true,
      ),
    ];
    
    setState(() {
      _conversations = conversations;
    });
  }
  
  /// Load messages for conversation
  Future<void> _loadMessages(String conversationId) async {
    try {
      final messages = await _database.getMessages(
        userId: widget.userProfile?.id,
        limit: 50,
      );
      
      setState(() {
        _messages = messages;
      });
      
      _scrollToBottom();
    } catch (e) {
      debugPrint('Failed to load messages: $e');
    }
  }
  
  /// Select conversation
  void _selectConversation(ChatConversation conversation) {
    setState(() {
      _activeConversation = conversation;
    });
    
    _loadMessages(conversation.id);
    
    // Mark conversation as read
    if (conversation.unreadCount > 0) {
      conversation.unreadCount = 0;
      setState(() {});
    }
  }
  
  /// Send message
  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _activeConversation == null) return;
    
    final message = FERMessage(
      id: _generateMessageId(),
      fromUserId: widget.userProfile?.id ?? 'anonymous',
      toUserId: _activeConversation!.id,
      content: text,
      contentType: FERMessageContentType.text,
      timestamp: DateTime.now(),
      status: FERMessageStatus.sent,
      isEncrypted: true,
    );
    
    try {
      // Store message in database
      await _database.storeMessage(message);
      
      // Add to UI
      setState(() {
        _messages.add(message);
        _activeConversation!.lastMessage = text;
        _activeConversation!.lastMessageTime = DateTime.now();
      });
      
      // Clear input
      _messageController.clear();
      
      // Scroll to bottom
      _scrollToBottom();
      
      // Simulate message delivery
      _simulateMessageDelivery(message);
      
    } catch (e) {
      debugPrint('Failed to send message: $e');
    }
  }
  
  /// Simulate message delivery
  void _simulateMessageDelivery(FERMessage message) {
    Timer(Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          message.status = FERMessageStatus.delivered;
        });
      }
    });
    
    Timer(Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          message.status = FERMessageStatus.read;
        });
      }
    });
  }
  
  /// Start voice recording
  void _startVoiceRecording(LongPressStartDetails details) {
    setState(() {
      _isRecording = true;
      _recordingDuration = 0;
    });
    
    // Start recording timer
    _recordingTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _recordingDuration++;
      });
    });
    
    // Trigger haptic feedback
    HapticFeedback.heavyImpact();
  }
  
  /// Stop voice recording
  void _stopVoiceRecording([LongPressEndDetails? details]) {
    if (!_isRecording) return;
    
    _recordingTimer?.cancel();
    
    setState(() {
      _isRecording = false;
    });
    
    // Create audio message
    if (_recordingDuration > 1) {
      final audioMessage = FERMessage(
        id: _generateMessageId(),
        fromUserId: widget.userProfile?.id ?? 'anonymous',
        toUserId: _activeConversation!.id,
        content: 'audio_${DateTime.now().millisecondsSinceEpoch}.aac',
        contentType: FERMessageContentType.audio,
        timestamp: DateTime.now(),
        status: FERMessageStatus.sent,
        isEncrypted: true,
      );
      
      _database.storeMessage(audioMessage);
      
      setState(() {
        _messages.add(audioMessage);
        _activeConversation!.lastMessage = '🎵 Audio message';
        _activeConversation!.lastMessageTime = DateTime.now();
      });
      
      _scrollToBottom();
    }
    
    setState(() {
      _recordingDuration = 0;
    });
    
    HapticFeedback.lightImpact();
  }
  
  /// Start new conversation
  void _startNewConversation() {
    showDialog(
      context: context,
      builder: (context) => _buildNewConversationDialog(),
    );
  }
  
  /// Build new conversation dialog
  Widget _buildNewConversationDialog() {
    return AlertDialog(
      title: Text('Start New Conversation'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Direct Message'),
            subtitle: 'Chat with another FER user'),
            onTap: () {
              Navigator.of(context).pop();
              _createDirectMessage();
            },
          ),
          ListTile(
            leading: Icon(Icons.group),
            title: Text('Create Group'),
            subtitle: 'Start a group conversation'),
            onTap: () {
              Navigator.of(context).pop();
              _createGroupConversation();
            },
          ),
          ListTile(
            leading: Icon(Icons.privacy_tip, color: FERColors.primary),
            title: Text('Anonymous Message'),
            subtitle: 'Send a private anonymous message'),
            onTap: () {
              Navigator.of(context).pop();
              _createAnonymousConversation();
            },
          ),
        ],
      ),
    );
  }
  
  /// Create direct message conversation
  void _createDirectMessage() {
    final newConversation = ChatConversation(
      id: _generateConversationId(),
      displayName: 'New Contact',
      avatarUrl: null,
      lastMessage: 'Start a conversation',
      lastMessageTime: DateTime.now(),
      unreadCount: 0,
      isOnline: false,
      isGroup: false,
      isAnonymous: false,
    );
    
    setState(() {
      _conversations.insert(0, newConversation);
    });
    
    _selectConversation(newConversation);
  }
  
  /// Create group conversation
  void _createGroupConversation() {
    final newConversation = ChatConversation(
      id: _generateConversationId(),
      displayName: 'New Group',
      avatarUrl: null,
      lastMessage: 'Group created',
      lastMessageTime: DateTime.now(),
      unreadCount: 0,
      isOnline: false,
      isGroup: true,
      isAnonymous: false,
    );
    
    setState(() {
      _conversations.insert(0, newConversation);
    });
    
    _selectConversation(newConversation);
  }
  
  /// Create anonymous conversation
  void _createAnonymousConversation() {
    final newConversation = ChatConversation(
      id: _generateConversationId(),
      displayName: 'AnonymousFerret${Random().nextInt(999)}',
      avatarUrl: null,
      lastMessage: 'Anonymous conversation started',
      lastMessageTime: DateTime.now(),
      unreadCount: 0,
      isOnline: false,
      isGroup: false,
      isAnonymous: true,
    );
    
    setState(() {
      _conversations.insert(0, newConversation);
    });
    
    _selectConversation(newConversation);
  }
  
  /// Show attachment options
  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo),
              title: Text('Photo'),
              onTap: () => _attachPhoto(),
            ),
            ListTile(
              leading: Icon(Icons.videocam),
              title: Text('Video'),
              onTap: () => _attachVideo(),
            ),
            ListTile(
              leading: Icon(Icons.insert_drive_file),
              title: Text('Document'),
              onTap: () => _attachDocument(),
            ),
            ListTile(
              leading: Icon(Icons.location_on),
              title: Text('Location'),
              onTap: () => _attachLocation(),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Handle attachment options
  void _attachPhoto() {
    Navigator.of(context).pop();
    // Implement photo attachment
    debugPrint('Photo attachment');
  }
  
  void _attachVideo() {
    Navigator.of(context).pop();
    // Implement video attachment
    debugPrint('Video attachment');
  }
  
  void _attachDocument() {
    Navigator.of(context).pop();
    // Implement document attachment
    debugPrint('Document attachment');
  }
  
  void _attachLocation() {
    Navigator.of(context).pop();
    // Implement location attachment
    debugPrint('Location attachment');
  }
  
  /// Start voice call
  void _startVoiceCall() {
    debugPrint('Starting voice call with ${_activeConversation?.displayName}');
    // Implement voice call functionality
  }
  
  /// Start video call
  void _startVideoCall() {
    debugPrint('Starting video call with ${_activeConversation?.displayName}');
    // Implement video call functionality
  }
  
  /// Handle conversation menu
  void _handleConversationMenu(String value) {
    switch (value) {
      case 'info':
        _showConversationInfo();
        break;
      case 'mute':
        _muteConversation();
        break;
      case 'clear':
        _clearConversation();
        break;
      case 'block':
        _blockConversation();
        break;
    }
  }
  
  /// Show conversation info
  void _showConversationInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Conversation Info'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_activeConversation != null) ...[
              CircleAvatar(
                radius: 30.0,
                backgroundColor: FERColors.primary.withOpacity(0.2),
                backgroundImage: _activeConversation!.avatarUrl != null
                  ? NetworkImage(_activeConversation!.avatarUrl!)
                  : null,
              ),
              SizedBox(height: 16.0),
              Text(
                _activeConversation!.displayName,
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8.0),
              Text(
                _activeConversation!.isGroup ? 'Group Chat' : 'Direct Message',
                style: TextStyle(color: Colors.grey),
              ),
              if (_activeConversation!.isAnonymous) ...[
                SizedBox(height: 8.0),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.privacy_tip, size: 16.0, color: FERColors.primary),
                    SizedBox(width: 4.0),
                    Text('Anonymous', style: TextStyle(color: FERColors.primary)),
                  ],
                ),
              ],
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
  
  /// Mute conversation
  void _muteConversation() {
    debugPrint('Muting conversation');
    // Implement mute functionality
  }
  
  /// Clear conversation
  void _clearConversation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear Chat'),
        content: Text('Are you sure you want to clear all messages in this conversation?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _messages.clear();
              });
            },
            child: Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  
  /// Block conversation
  void _blockConversation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Block User'),
        content: Text('Are you sure you want to block this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Implement block functionality
            },
            child: Text('Block', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  
  /// Handle search change
  void _onSearchChanged(String query) {
    // Implement search functionality
    debugPrint('Searching for: $query');
  }
  
  /// Handle message text change
  void _onMessageChanged(String text) {
    // Implement typing indicators
    if (text.isNotEmpty && _activeConversation != null) {
      // Notify other user that we're typing
    }
  }
  
  /// Scroll to bottom of messages
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
  
  /// Format message time
  String _formatMessageTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
  
  /// Format duration
  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
  
  /// Generate message ID
  String _generateMessageId() {
    return 'msg_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
  }
  
  /// Generate conversation ID
  String _generateConversationId() {
    return 'conv_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
  }
}

/// Chat conversation model
class ChatConversation {
  final String id;
  final String displayName;
  final String? avatarUrl;
  String lastMessage;
  DateTime lastMessageTime;
  int unreadCount;
  bool isOnline;
  bool isGroup;
  bool isAnonymous;
  bool isTyping;
  
  ChatConversation({
    required this.id,
    required this.displayName,
    this.avatarUrl,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.isOnline = false,
    this.isGroup = false,
    this.isAnonymous = false,
    this.isTyping = false,
  });
}

/// Chat conversation types
enum ChatConversationType {
  recent,
  groups,
  anonymous,
}

/// Import message type from database
import '../../services/offline_first_database.dart';
]]>