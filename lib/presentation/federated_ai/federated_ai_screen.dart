import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class FederatedAIScreen extends StatefulWidget {
  const FederatedAIScreen({super.key});

  @override
  State<FederatedAIScreen> createState() => _FederatedAIScreenState();
}

class _FederatedAIScreenState extends State<FederatedAIScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _promptController = TextEditingController();
  final List<AIRole> _aiRoles = [
    AIRole(
      name: 'AIFER Assistant',
      description: 'General AI assistant for FER Network',
      icon: Icons.smart_toy,
      color: const Color(0xFF39FF14),
      model: 'AIFER-v11-Base',
      active: true,
    ),
    AIRole(
      name: 'Security Sentinel',
      description: 'AI-powered threat detection and analysis',
      icon: Icons.security,
      color: const Color(0xFFFF5252),
      model: 'Sentinel-Pro',
      active: false,
    ),
    AIRole(
      name: 'Market Oracle',
      description: 'AI trading predictions and analysis',
      icon: Icons.trending_up,
      color: const Color(0xFF00E5FF),
      model: 'Oracle-X',
      active: false,
    ),
    AIRole(
      name: 'Code Guardian',
      description: 'AI code review and optimization',
      icon: Icons.code,
      color: const Color(0xFFFFD740),
      model: 'Guardian-2.0',
      active: false,
    ),
    AIRole(
      name: 'Network Optimizer',
      description: 'Mesh network optimization AI',
      icon: Icons.hub,
      color: const Color(0xFF7B61FF),
      model: 'NetOpt-AI',
      active: false,
    ),
  ];

  final List<AIConversation> _conversations = [
    AIConversation(
      id: '1',
      title: 'FER Network Overview',
      lastMessage: 'How does the mesh network work?',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      unread: 0,
    ),
    AIConversation(
      id: '2',
      title: 'Security Analysis',
      lastMessage: 'No threats detected in last 24h',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      unread: 0,
    ),
  ];

  final List<AIMessage> _currentMessages = [];
  bool _isProcessing = false;
  late TabController _tabController;
  late AnimationController _typingController;
  late Animation<double> _typingAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _typingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _typingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _typingController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _promptController.dispose();
    _tabController.dispose();
    _typingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF39FF14)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(
              'Federated AI',
              style: GoogleFonts.inter(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF39FF14),
              ),
            ),
            Text(
              'Decentralized AI Network',
              style: GoogleFonts.inter(
                fontSize: 10.sp,
                color: const Color(0xFF9E9E9E),
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Color(0xFF9E9E9E)),
            onPressed: _showSettingsDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildChatTab(),
                _buildRolesTab(),
                _buildModelsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(25),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: const Color(0xFF39FF14),
          borderRadius: BorderRadius.circular(25),
        ),
        labelColor: Colors.black,
        unselectedLabelColor: const Color(0xFF9E9E9E),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'Chat'),
          Tab(text: 'Roles'),
          Tab(text: 'Models'),
        ],
      ),
    );
  }

  Widget _buildChatTab() {
    return Column(
      children: [
        Expanded(
          child: _currentMessages.isEmpty
              ? _buildEmptyChat()
              : ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  itemCount: _currentMessages.length,
                  itemBuilder: (context, index) {
                    return _buildMessageBubble(_currentMessages[index]);
                  },
                ),
        ),
        _buildInputArea(),
      ],
    );
  }

  Widget _buildEmptyChat() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 25.w,
            height: 25.w,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF39FF14), Color(0xFF00E5FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(Icons.smart_toy, color: Colors.black, size: 10.w),
          ),
          SizedBox(height: 2.h),
          Text(
            'AIFER Assistant',
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Your federated AI companion',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: const Color(0xFF9E9E9E),
            ),
          ),
          SizedBox(height: 3.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildQuickPrompt('What is FER Network?'),
              _buildQuickPrompt('Explain mesh networking'),
              _buildQuickPrompt('Security features'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickPrompt(String prompt) {
    return GestureDetector(
      onTap: () {
        _promptController.text = prompt;
        _sendMessage();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFF39FF14).withOpacity(0.3)),
        ),
        child: Text(
          prompt,
          style: GoogleFonts.inter(
            fontSize: 10.sp,
            color: const Color(0xFF39FF14),
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildMessageBubble(AIMessage message) {
    final isUser = message.role == 'user';
    
    return Container(
      margin: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 8.w,
              height: 8.w,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF39FF14), Color(0xFF00E5FF)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.smart_toy, color: Colors.black, size: 4.w),
            ),
            SizedBox(width: 2.w),
          ],
          Flexible(
            child: Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: isUser
                    ? const Color(0xFF39FF14)
                    : const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: isUser
                      ? const Color(0xFF39FF14)
                      : const Color(0xFF39FF14).withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      color: isUser ? Colors.black : Colors.white,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    _formatTime(message.timestamp),
                    style: GoogleFonts.inter(
                      fontSize: 8.sp,
                      color: isUser ? Colors.black54 : const Color(0xFF6B6B6B),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            SizedBox(width: 2.w),
            Container(
              width: 8.w,
              height: 8.w,
              decoration: BoxDecoration(
                color: const Color(0xFF00E5FF).withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF00E5FF)),
              ),
              child: const Icon(Icons.person, color: const Color(0xFF00E5FF), size: 4.w),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        border: Border(
          top: BorderSide(color: const Color(0xFF39FF14).withOpacity(0.3)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _promptController,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 12.sp,
              ),
              decoration: InputDecoration(
                hintText: 'Ask AIFER anything...',
                hintStyle: GoogleFonts.inter(
                  color: const Color(0xFF9E9E9E),
                  fontSize: 12.sp,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: const Color(0xFF2A2A2A),
                contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
              ),
              maxLines: null,
            ),
          ),
          SizedBox(width: 2.w),
          Container(
            decoration: BoxDecoration(
              color: _isProcessing ? const Color(0xFF6B6B6B) : const Color(0xFF39FF14),
              borderRadius: BorderRadius.circular(25),
            ),
            child: IconButton(
              icon: _isProcessing
                  ? SizedBox(
                      width: 5.w,
                      height: 5.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.send, color: Colors.black),
              onPressed: _isProcessing ? null : _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRolesTab() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      itemCount: _aiRoles.length,
      itemBuilder: (context, index) {
        return _buildRoleCard(_aiRoles[index]);
      },
    );
  }

  Widget _buildRoleCard(AIRole role) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            role.color.withOpacity(0.15),
            const Color(0xFF1E1E1E),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: role.color.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 14.w,
            height: 14.w,
            decoration: BoxDecoration(
              color: role.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: role.color, width: 2),
            ),
            child: Icon(role.icon, color: role.color, size: 7.w),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        role.name,
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    if (role.active) ...[
                      Icon(Icons.check_circle, color: role.color, size: 14.sp),
                      SizedBox(width: 1.w),
                      Text(
                        'Active',
                        style: GoogleFonts.inter(
                          fontSize: 10.sp,
                          color: role.color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 0.5.h),
                Text(
                  role.description,
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    color: const Color(0xFF9E9E9E),
                  ),
                ),
                SizedBox(height: 0.5.h),
                Row(
                  children: [
                    Icon(Icons.memory, size: 10.sp, color: role.color),
                    SizedBox(width: 0.5.w),
                    Text(
                      role.model,
                      style: GoogleFonts.inter(
                        fontSize: 9.sp,
                        color: role.color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModelsTab() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 2.h),
            child: Text(
              'AI Model Details',
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          _buildModelInfo('Base Model', 'AIFER-v11-Base', Icons.smart_toy,
              'General purpose federated learning model'),
          _buildModelInfo('Parameters', '175 Billion', Icons.memory,
              'Large language model architecture'),
          _buildModelInfo('Training', 'Decentralized', Icons.network_check,
              'Trained across mesh nodes'),
          _buildModelInfo('Privacy', 'Federated Learning', Icons.security,
              'No data leaves your device'),
          _buildModelInfo('Updates', 'Continuous', Icons.update,
              'Real-time model improvements'),
          SizedBox(height: 2.h),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 1.h),
            child: Text(
              'Performance Metrics',
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          _buildMetricCard('Response Time', '150ms', Icons.timer,
              const Color(0xFF39FF14)),
          _buildMetricCard('Accuracy', '94.7%', Icons.assessment,
              const Color(0xFF00E5FF)),
          _buildMetricCard('Active Nodes', '12,847', Icons.hub,
              const Color(0xFF7B61FF)),
          _buildMetricCard('Daily Queries', '2.4M', Icons.query_stats,
              const Color(0xFFFFD740)),
          SizedBox(height: 2.h),
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF39FF14).withOpacity(0.1),
                  const Color(0xFF1E1E1E),
                ],
              ),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color(0xFF39FF14)),
            ),
            child: Row(
              children: [
                Icon(Icons.privacy_tip, color: const Color(0xFF39FF14), size: 5.w),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    'All AI processing happens locally on your device using federated learning. Your data never leaves the mesh network.',
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      color: const Color(0xFFBDBDBD),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModelInfo(String label, String value, IconData icon, String description) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF39FF14).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 10.w,
            height: 10.w,
            decoration: BoxDecoration(
              color: const Color(0xFF39FF14).withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF39FF14), size: 5.w),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    color: const Color(0xFF9E9E9E),
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF39FF14),
                  ),
                ),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    color: const Color(0xFF6B6B6B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.5.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 4.w),
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    color: const Color(0xFF9E9E9E),
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) return;

    setState(() {
      _currentMessages.add(AIMessage(
        role: 'user',
        content: prompt,
        timestamp: DateTime.now(),
      ));
      _isProcessing = true;
    });
    _promptController.clear();

    // Simulate AI response
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      
      final response = _generateAIResponse(prompt);
      setState(() {
        _currentMessages.add(AIMessage(
          role: 'assistant',
          content: response,
          timestamp: DateTime.now(),
        ));
        _isProcessing = false;
      });
    });
  }

  String _generateAIResponse(String prompt) {
    final lowerPrompt = prompt.toLowerCase();
    
    if (lowerPrompt.contains('fer network') || lowerPrompt.contains('what is')) {
      return 'FER Network is a decentralized, quantum-secure operating system designed for true digital sovereignty. It uses mesh networking for peer-to-peer communication, IPFS/Walrus for decentralized storage, and federated AI for intelligent assistance—all without relying on centralized servers.';
    } else if (lowerPrompt.contains('mesh')) {
      return 'Mesh networking in FER enables direct device-to-device communication using WebRTC. Each node can route traffic for others, creating a resilient network that works even when traditional infrastructure fails. The mesh is protected with quantum-resistant lattice-based cryptography.';
    } else if (lowerPrompt.contains('security')) {
      return 'FER Network implements multiple layers of security:\n\n• Quantum-resistant encryption (256-bit lattice-based)\n• End-to-end encrypted messaging\n• Zero-knowledge proofs for identity verification\n• Decentralized authentication via AIFER ID\n• AI-powered threat detection\n\nAll data remains encrypted and in your control.';
    } else if (lowerPrompt.contains('blockchain')) {
      return 'FERChain is our quantum-secure blockchain that powers the FER Network ecosystem. It uses Proof of Stake consensus with decentralized validation, enabling fast and secure transactions for trading, smart contracts, and governance—all protected against quantum computing attacks.';
    } else if (lowerPrompt.contains('future') || lowerPrompt.contains('vision')) {
      return '🚀 FER represents THE system of the future:\n\n• Complete digital sovereignty\n• No centralized control\n• Quantum-resistant security\n• AI-augmented everything\n• True peer-to-peer connectivity\n\nWe\'re building towards a world where technology serves humanity, not the other way around. Welcome to the future! 🦦';
    }
    
    final responses = [
      'I\'m here to help you navigate the FER Network! What would you like to know about?',
      'Great question! FER Network is designed to empower users with true digital sovereignty through decentralized technologies.',
      'I can help you understand any aspect of FER Network - from mesh networking to AI features. Just ask!',
      'As your AIFER Assistant, I\'m ready to assist you with anything related to the FER ecosystem.',
    ];
    
    return responses[Random().nextInt(responses.length)];
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(
          'AI Settings',
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSettingItem('Local processing only', true),
            _buildSettingItem('Enable federated learning', true),
            _buildSettingItem('Show confidence scores', false),
            _buildSettingItem('Voice input', false),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Color(0xFF9E9E9E))),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(String label, bool value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 12.sp, color: Colors.white),
          ),
          Switch(
            value: value,
            onChanged: (val) {},
            activeColor: const Color(0xFF39FF14),
          ),
        ],
      ),
    );
  }
}

class AIRole {
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final String model;
  bool active;

  AIRole({
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.model,
    required this.active,
  });
}

class AIConversation {
  final String id;
  final String title;
  final String lastMessage;
  final DateTime timestamp;
  int unread;

  AIConversation({
    required this.id,
    required this.title,
    required this.lastMessage,
    required this.timestamp,
    required this.unread,
  });
}

class AIMessage {
  final String role;
  final String content;
  final DateTime timestamp;

  AIMessage({
    required this.role,
    required this.content,
    required this.timestamp,
  });
}