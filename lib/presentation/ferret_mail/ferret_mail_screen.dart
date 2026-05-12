import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

/// FerretMail - Mesh Email Client
/// Placeholder implementation for AIFER v11 integration
class FerretMailScreen extends StatefulWidget {
  const FerretMailScreen({Key? key}) : super(key: key);

  @override
  State<FerretMailScreen> createState() => _FerretMailScreenState();
}

class _FerretMailScreenState extends State<FerretMailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<Email> _inboxEmails = [];
  final List<Email> _sentEmails = [];
  final List<Email> _drafts = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadEmails();
  }

  void _loadEmails() {
    setState(() {
      _inboxEmails.clear();
      _inboxEmails.addAll(_getPlaceholderInbox());
      
      _sentEmails.clear();
      _sentEmails.addAll(_getPlaceholderSent());
      
      _drafts.clear();
      _drafts.addAll(_getPlaceholderDrafts());
    });
  }

  List<Email> _getPlaceholderInbox() {
    return [
      Email(
        id: '1',
        sender: 'AiFER Team',
        senderEmail: 'team@aifer.os',
        subject: 'Welcome to AiFER OS v11! 🦦',
        preview: 'Thank you for joining the Neon Ferret community...',
        body: '''Dear Ferret User,

Welcome to AiFER OS v11 - Neon Ferret! 🦦

We're thrilled to have you as part of our decentralized community. This version brings you:

✨ New Features:
• Enhanced mesh networking with 42 active nodes
• Quantum encryption for all communications
• AI assistant (FERCompanion) ready to help
• 8 OS apps and 8 mini-games included
• Zero-knowledge authentication (zkLogin)

🎮 Quick Start:
1. Explore the SlideOutMenu (17 apps!)
2. Try the mini-games in the Games hub
3. Use FERCompanion for assistance
4. Connect to the mesh network

🔒 Your Privacy:
• End-to-end encryption
• No central server
• Your data stays with you
• Zero-knowledge proofs

Need help? Just ask FERCompanion or check our documentation!

Best regards,
The AiFER Team 🦦

---
AiFER OS v11 • Neon Ferret
Quantum Secure • Decentralized''',
        timestamp: DateTime.now().subtract(Duration(minutes: 5)),
        isUnread: true,
        isStarred: true,
        isMesh: true,
      ),
      Email(
        id: '2',
        sender: 'Mesh Network Notification',
        senderEmail: 'network@aifer.os',
        subject: 'New node connected: node-theta',
        preview: 'A new node has joined your mesh network...',
        body: '''MESH NETWORK NOTIFICATION

Node Information:
• Node ID: node-theta
• Location: ME-Central
• Latency: 95ms
• Status: Active

Your mesh network now has 42 active nodes.

Connection Quality: Excellent
Encryption: Quantum-256
Protocol: WebRTC + Yjs CRDT

Stay secure, stay connected. 🦦''',
        timestamp: DateTime.now().subtract(Duration(hours: 1)),
        isUnread: true,
        isStarred: false,
        isMesh: true,
      ),
      Email(
        id: '3',
        sender: 'John Doe',
        senderEmail: 'john.doe@mesh.net',
        subject: 'Project collaboration update',
        preview: 'Hey, I pushed the latest changes to the repo...',
        body: '''Hey,

I pushed the latest changes to the repository. Here's what's new:

1. Fixed the mesh node detection issue
2. Added support for biometric auth
3. Updated the neon green theme

Let me know when you have a chance to review!

Best,
John''',
        timestamp: DateTime.now().subtract(Duration(hours: 3)),
        isUnread: false,
        isStarred: false,
        isMesh: true,
      ),
      Email(
        id: '4',
        sender: 'FER Companion',
        senderEmail: 'companion@aifer.os',
        subject: 'Daily Summary',
        preview: 'Here\'s your activity summary for today...',
        body: '''🦦 FERCompanion Daily Summary

Your Activity Today:
• 3 files uploaded to FerretFiles
• 2 notes created in FerretNotes
• 5 games played
• Mesh uptime: 24/7
• 42 active connections

Recommendations:
• Consider backing up your notes
• Explore the new Games hub
• Check out the Terminal features

Have a great day! 🦦''',
        timestamp: DateTime.now().subtract(Duration(days: 1)),
        isUnread: false,
        isStarred: true,
        isMesh: false,
      ),
      Email(
        id: '5',
        sender: 'Security Alert',
        senderEmail: 'security@aifer.os',
        subject: 'Authentication attempt detected',
        preview: 'A new device attempted to access your account...',
        body: '''SECURITY ALERT

We detected a new authentication attempt:

Device Information:
• Type: Mobile (Android)
• Location: US-East
• IP: 192.168.1.*** (masked)
• Time: 2024-01-15 14:32:45

Action Required:
If this was you, no action is needed.
If this wasn't you, please:
1. Change your password
2. Enable biometric auth
3. Review your connected devices

Your security is our top priority. 🦦''',
        timestamp: DateTime.now().subtract(Duration(days: 2)),
        isUnread: false,
        isStarred: false,
        isMesh: false,
      ),
    ];
  }

  List<Email> _getPlaceholderSent() {
    return [
      Email(
        id: 's1',
        sender: 'Me',
        senderEmail: 'me@aifer.os',
        subject: 'Re: Project collaboration',
        preview: 'Thanks for the update! I\'ll review it shortly...',
        body: '''Thanks for the update! I'll review it shortly.

On another note, have you tried the new mini-games? They're pretty fun! 🎮

Best,''',
        timestamp: DateTime.now().subtract(Duration(hours: 2)),
        isUnread: false,
        isStarred: false,
        isMesh: true,
      ),
    ];
  }

  List<Email> _getPlaceholderDrafts() {
    return [
      Email(
        id: 'd1',
        sender: 'Me',
        senderEmail: 'me@aifer.os',
        subject: 'Feature request: Dark mode toggle',
        preview: 'I think it would be great to have a manual dark mode...',
        body: '''I think it would be great to have a manual dark mode toggle, even though the app defaults to it based on system settings.

This would allow users to:
• Override system preference
• Schedule dark mode
• Create custom themes

What do you think?''',
        timestamp: DateTime.now().subtract(Duration(minutes: 30)),
        isUnread: false,
        isStarred: false,
        isMesh: false,
      ),
    ];
  }

  void _toggleStar(Email email, List<Email> emailList) {
    setState(() {
      email.isStarred = !email.isStarred;
    });
  }

  void _deleteEmail(Email email, List<Email> emailList) {
    setState(() {
      emailList.removeWhere((e) => e.id == email.id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Email deleted'),
        backgroundColor: Color(0xFF39FF14),
      ),
    );
  }

  void _showEmailDetail(Email email) {
    setState(() {
      email.isUnread = false;
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Color(0xFF39FF14).withValues(alpha: 0.2),
                  child: Text(
                    email.sender[0],
                    style: TextStyle(
                      color: Color(0xFF39FF14),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        email.sender,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        email.senderEmail,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                if (email.isMesh)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: Color(0xFF39FF14).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2.w),
                    ),
                    child: Text(
                      '🦦 Mesh',
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF39FF14),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 2.h),
            Text(
              email.subject,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              _formatDate(email.timestamp),
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(
            email.body,
            style: TextStyle(height: 1.5),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              email.isStarred ? Icons.star : Icons.star_border,
              color: email.isStarred ? Color(0xFFFFD740) : Colors.grey,
            ),
            onPressed: () {
              Navigator.pop(context);
              _toggleStar(email, _tabController.index == 0
                  ? _inboxEmails
                  : _tabController.index == 1 ? _sentEmails : _drafts);
            },
          ),
          IconButton(
            icon: Icon(Icons.reply),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Reply coming soon!')),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            color: Colors.red,
            onPressed: () {
              Navigator.pop(context);
              _deleteEmail(email, _tabController.index == 0
                  ? _inboxEmails
                  : _tabController.index == 1 ? _sentEmails : _drafts);
            },
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.mail_outline, color: Color(0xFF39FF14)),
            SizedBox(width: 2.w),
            Text('FerretMail'),
          ],
        ),
        backgroundColor: isDark ? Color(0xFF0A0A0A) : Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Color(0xFF39FF14),
          labelColor: Color(0xFF39FF14),
          unselectedLabelColor: Colors.grey,
          tabs: [
            Tab(
              text: 'Inbox (${_inboxEmails.where((e) => e.isUnread).length})',
            ),
            Tab(
              text: 'Sent',
            ),
            Tab(
              text: 'Drafts',
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Search coming soon!')),
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$value coming soon!')),
              );
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'Compose',
                child: Text('Compose'),
              ),
              const PopupMenuItem(
                value: 'Mark All Read',
                child: Text('Mark All Read'),
              ),
              const PopupMenuItem(
                value: 'Settings',
                child: Text('Settings'),
              ),
            ],
          ),
        ],
      ),
      backgroundColor: isDark ? Color(0xFF0A0A0A) : Colors.white,
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildEmailList(_inboxEmails),
          _buildEmailList(_sentEmails),
          _buildEmailList(_drafts),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Compose coming soon!'),
              backgroundColor: Color(0xFF39FF14),
            ),
          );
        },
        backgroundColor: Color(0xFF39FF14),
        child: const Icon(Icons.edit, color: Colors.black),
      ),
    );
  }

  Widget _buildEmailList(List<Email> emails) {
    if (emails.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 15.w,
              color: Colors.grey,
            ),
            SizedBox(height: 2.h),
            Text(
              'No emails here',
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: emails.length,
      itemBuilder: (context, index) {
        return _buildEmailItem(emails[index]);
      },
    );
  }

  Widget _buildEmailItem(Email email) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _showEmailDetail(email),
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: email.isUnread
              ? (isDark ? Color(0xFF1A1A1A).withValues(alpha: 0.5) : Colors.grey[200])
              : Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: isDark ? Colors.white12 : Colors.black12,
              width: 1,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar / Mesh indicator
            Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: email.isMesh
                    ? Color(0xFF39FF14).withValues(alpha: 0.2)
                    : Color(0xFF00E5FF).withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: email.isMesh
                    ? Text(
                        '🦦',
                        style: TextStyle(fontSize: 6.w),
                      )
                    : Text(
                        email.sender[0],
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00E5FF),
                        ),
                      ),
              ),
            ),
            SizedBox(width: 3.w),

            // Email content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          email.sender,
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: email.isUnread
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isDark ? Colors.white : Colors.black54,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _formatDate(email.timestamp),
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(width: 1.w),
                      Icon(
                        email.isStarred ? Icons.star : Icons.star_border,
                        size: 4.w,
                        color: email.isStarred
                            ? Color(0xFFFFD740)
                            : Colors.grey[400],
                      ),
                    ],
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    email.subject,
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      fontWeight: email.isUnread
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 0.3.h),
                  Text(
                    email.preview,
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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

/// Email data class
class Email {
  final String id;
  final String sender;
  final String senderEmail;
  final String subject;
  final String preview;
  final String body;
  final DateTime timestamp;
  bool isUnread;
  bool isStarred;
  final bool isMesh;

  Email({
    required this.id,
    required this.sender,
    required this.senderEmail,
    required this.subject,
    required this.preview,
    required this.body,
    required this.timestamp,
    required this.isUnread,
    required this.isStarred,
    required this.isMesh,
  });
}