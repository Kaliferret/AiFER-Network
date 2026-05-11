import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

class FerCodeScreen extends StatefulWidget {
  const FerCodeScreen({super.key});

  @override
  State<FerCodeScreen> createState() => _FerCodeScreenState();
}

class _FerCodeScreenState extends State<FerCodeScreen> with TickerProviderStateMixin {
  final List<CodeFile> _files = [];
  int _currentFileIndex = 0;
  String _currentCode = '';
  final TextEditingController _codeController = TextEditingController();
  bool _showAiAssist = false;
  String _aiSuggestion = '';
  bool _isCompiling = false;
  String _compileResult = '';

  late AnimationController _typingController;
  late Animation<double> _typingAnimation;

  @override
  void initState() {
    super.initState();
    _initFiles();
    _currentCode = _files[_currentFileIndex].content;
    _codeController.text = _currentCode;

    _typingController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _typingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _typingController, curve: Curves.easeOut),
    );
  }

  void _initFiles() {
    _files.addAll([
      CodeFile(
        name: 'main.dart',
        language: 'Dart',
        icon: Icons.code,
        color: const Color(0xFF40C4FF),
        content: '''// Welcome to FERCode - Quantum Secure Editor
// AI-powered with real-time collaboration 🔐

import 'package:flutter/material.dart';

void main() {
  runApp(const FERApp());
}

class FERApp extends StatelessWidget {
  const FERApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FER Network',
      theme: ThemeData.dark(),
      home: const Dashboard(),
    );
  }
}

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🦦 FER Network')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to FER',
              style: TextStyle(fontSize: 24),
            ),
            ElevatedButton(
              onPressed: () {},
              child: Text('Get Started'),
            ),
          ],
        ),
      ),
    );
  }
}
''',
      ),
      CodeFile(
        name: 'quantum_crypto.py',
        language: 'Python',
        icon: Icons.security,
        color: const Color(0xFF69F0AE),
        content: '''# Quantum Cryptography Module for FER
# Lattice-based encryption implementation 🔐

from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2
import numpy as np

class QuantumEncryptor:
    """Post-quantum secure encryption using lattice-based cryptography"""
    
    def __init__(self, key_length: int = 256):
        self.key_length = key_length
        self.m = 256  # Lattice dimension
        self.n = 2    # Lattice rank
        
    def generate_keypair(self):
        """Generate public/private key pair"""
        # Generate random lattice basis
        B = np.random.randint(0, 256, (self.m, self.n))
        
        # Public key = random linear combination
        A = np.random.randint(0, 256, (self.m, self.n))
        
        return {
            'public_key': A.tolist(),
            'private_key': B.tolist()
        }
    
    def encrypt(self, message: str, public_key: list):
        """Encrypt message using lattice-based encryption"""
        # Quantum-resistant encryption
        encrypted = []
        for char in message:
            encrypted.append(ord(char) ^ 42)
        return ''.join(chr(c) for c in encrypted)
    
    def decrypt(self, ciphertext: str, private_key: list):
        """Decrypt quantum-encrypted message"""
        decrypted = []
        for char in ciphertext:
            decrypted.append(chr(ord(char) ^ 42))
        return ''.join(decrypted)

# Usage
encryptor = QuantumEncryptor()
keys = encryptor.generate_keypair()
print(f"Generated quantum keypair: {len(keys)} bytes")
''',
      ),
      CodeFile(
        name: 'smart_contract.sol',
        language: 'Solidity',
        icon: Icons.description,
        color: const Color(0xFFE040FB),
        content: '''// FER Network Smart Contract
// Decentralized identity and reputation system 🌐

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract FERIdentity {
    address public owner;
    mapping(address => FERUser) public users;
    mapping(address => uint256) public reputation;
    
    struct FERUser {
        string ferretId;
        uint256 joinedAt;
        uint256 transactions;
        bool verified;
    }
    
    event UserRegistered(address indexed user, string ferretId);
    event ReputationUpdated(address indexed user, uint256 score);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
    
    constructor() {
        owner = msg.sender;
    }
    
    function registerUser(string memory _ferretId) public {
        require(users[msg.sender].joinedAt == 0, "Already registered");
        
        users[msg.sender] = FERUser({
            ferretId: _ferretId,
            joinedAt: block.timestamp,
            transactions: 0,
            verified: false
        });
        
        reputation[msg.sender] = 100; // Initial reputation
        emit UserRegistered(msg.sender, _ferretId);
    }
    
    function updateReputation(address _user, uint256 _delta) public {
        require(users[_user].joinedAt > 0, "User not registered");
        
        reputation[_user] += _delta;
        emit ReputationUpdated(_user, reputation[_user]);
    }
}
''',
      ),
    ]);
  }

  @override
  void dispose() {
    _codeController.dispose();
    _typingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        title: Text(
          '🦦 FERCode',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 6.w, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.play_arrow, size: 5.w, color: const Color(0xFF39FF14)),
            onPressed: _compileCode,
          ),
          IconButton(
            icon: Icon(Icons.smart_toy, size: 5.w, color: const Color(0xFF00E5FF)),
            onPressed: _toggleAiAssist,
          ),
        ],
      ),
      body: Column(
        children: [
          // File Tabs
          _buildFileTabs(),
          // Editor
          Expanded(
            child: Column(
              children: [
                _buildEditor(),
                if (_showAiAssist) _buildAiAssistPanel(),
                if (_compileResult.isNotEmpty) _buildCompileResult(),
              ],
            ),
          ),
          // Toolbar
          _buildToolbar(),
        ],
      ),
    );
  }

  Widget _buildFileTabs() {
    return Container(
      height: 6.h,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        border: Border(
          bottom: BorderSide(color: const Color(0xFF39FF14), width: 1),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _files.length,
        itemBuilder: (context, index) {
          return _buildFileTab(index);
        },
      ),
    );
  }

  Widget _buildFileTab(int index) {
    final file = _files[index];
    final isSelected = index == _currentFileIndex;

    return GestureDetector(
      onTap: () => _switchFile(index),
      child: Container(
        margin: EdgeInsets.only(left: index == 0 ? 1.w : 0, right: 1.w),
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: isSelected
              ? file.color.withOpacity(0.2)
              : Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: isSelected ? file.color : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(file.icon, color: file.color, size: 4.w),
            SizedBox(width: 1.w),
            Text(
              file.name,
              style: GoogleFonts.firaCode(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: isSelected ? file.color : Colors.grey[400],
              ),
            ),
            if (index > 0) ...[
              SizedBox(width: 1.w),
              Icon(Icons.close, color: Colors.grey[500], size: 3.w),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEditor() {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          border: Border.all(color: const Color(0xFF39FF14).withOpacity(0.3)),
        ),
        child: TextField(
          controller: _codeController,
          maxLines: null,
          expands: true,
          style: GoogleFonts.firaCode(
            fontSize: 11.sp,
            color: Colors.white,
            height: 1.5,
          ),
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: (value) {
            _currentCode = value;
            _typingController.forward(from: 0.0);
          },
        ),
      ),
    );
  }

  Widget _buildAiAssistPanel() {
    return Container(
      margin: EdgeInsets.all(2.w),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF00E5FF).withOpacity(0.1),
            const Color(0xFF39FF14).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF00E5FF), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.smart_toy, color: const Color(0xFF00E5FF), size: 5.w),
              SizedBox(width: 2.w),
              Text(
                '🤖 FER AI Assistance',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF00E5FF),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.5.h),
          Text(
            _aiSuggestion.isNotEmpty
                ? _aiSuggestion
                : 'AI suggestions will appear here as you type. '
                  'FER\'s quantum-trained AI will help you write secure, efficient code.',
            style: GoogleFonts.firaCode(
              fontSize: 10.sp,
              color: Colors.grey[300],
              height: 1.4,
            ),
          ),
          SizedBox(height: 1.5.h),
          Row(
            children: [
              _buildAiButton('Fix Bugs', Icons.bug_report),
              SizedBox(width: 2.w),
              _buildAiButton('Optimize', Icons.speed),
              SizedBox(width: 2.w),
              _buildAiButton('Generate', Icons.auto_awesome),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAiButton(String label, IconData icon) {
    return ElevatedButton.icon(
      onPressed: () {
        setState(() {
          _aiSuggestion = _generateAiSuggestion(label);
        });
      },
      icon: Icon(icon, size: 4.w, color: Colors.black),
      label: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF00E5FF),
        foregroundColor: Colors.black,
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  String _generateAiSuggestion(String action) {
    const suggestions = {
      'Fix Bugs': '✨ Suggestion: Add null safety checks for all nullable variables. '
          'Consider adding try-catch blocks for async operations.',
      'Optimize': '⚡ Optimization tip: Use const constructors where possible. '
          'Implement memoization for expensive computations.',
      'Generate': '🚀 Auto-generated code: Ready to scaffold new component structure. '
          'FER AI can generate boilerplate in Dart, Python, and Solidity.',
    };
    return suggestions[action] ?? 'AI suggestion generated';
  }

  Widget _buildCompileResult() {
    return Container(
      margin: EdgeInsets.all(2.w),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF39FF14), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _isCompiling
                    ? Icons.hourglass_empty
                    : Icons.terminal,
                color: const Color(0xFF39FF14),
                size: 5.w,
              ),
              SizedBox(width: 2.w),
              Text(
                _isCompiling ? 'Compiling...' : 'Output',
                style: GoogleFonts.firaCode(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF39FF14),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            _compileResult,
            style: GoogleFonts.firaCode(
              fontSize: 10.sp,
              color: _isCompiling ? Colors.grey[400] : Colors.white,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      height: 7.h,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        border: Border(
          top: BorderSide(color: const Color(0xFF39FF14), width: 1),
        ),
      ),
      child: Row(
        children: [
          _buildToolButton(Icons.code, 'Code'),
          _buildToolButton(Icons.folder_open, 'Files'),
          _buildToolButton(Icons.search, 'Find'),
          _buildToolButton(Icons.history, 'Git'),
          _buildToolButton(Icons.settings, 'Settings'),
        ],
      ),
    );
  }

  Widget _buildToolButton(IconData icon, String label) {
    return Expanded(
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$label feature coming soon'),
              backgroundColor: Colors.grey[700],
            ),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.grey[400], size: 5.w),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 9.sp,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _switchFile(int index) {
    setState(() {
      _currentFileIndex = index;
      _currentCode = _files[index].content;
      _codeController.text = _currentCode;
    });
  }

  void _toggleAiAssist() {
    setState(() {
      _showAiAssist = !_showAiAssist;
    });
  }

  void _compileCode() {
    setState(() {
      _isCompiling = true;
      _compileResult = '';
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _isCompiling = false;
        _compileResult = '''✅ Build Successful!

[FER Compiler v2.0]
Analyzing ${_files[_currentFileIndex].name}...
✓ Syntax check passed
✓ Type inference complete
✓ Quantum security scan passed
✓ No vulnerabilities detected

Generated artifact: ${_files[_currentFileIndex].name.split('.')[0]}.fer

Build time: 1.83s
Size: 42.3 KB

Ready for FER Network deployment 🚀''';
      });
    });
  }
}

class CodeFile {
  final String name;
  final String language;
  final IconData icon;
  final Color color;
  String content;

  CodeFile({
    required this.name,
    required this.language,
    required this.icon,
    required this.color,
    required this.content,
  });
}