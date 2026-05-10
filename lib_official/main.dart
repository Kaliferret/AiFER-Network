<![CDATA[import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/aiferid_auth_service.dart';
import 'services/offline_first_database.dart';
import 'core/fer_quantum_encryption.dart';
import 'core/frequency_hopping.dart';
import 'widgets/unified_sliding_menu.dart';
import 'presentation/ferchat/chat_screen.dart';
import 'presentation/ferexplorer/file_manager_screen.dart';
import 'presentation/fergame/gaming_hub_screen.dart';

/// FER Network - Main Application Entry Point
/// Decentralized communication and gaming ecosystem
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  
  runApp(FERNetworkApp());
}

class FERNetworkApp extends StatefulWidget {
  @override
  _FERNetworkAppState createState() => _FERNetworkAppState();
}

class _FERNetworkAppState extends State<FERNetworkApp> {
  AiFERiDAuthService? _authService;
  OfflineFirstDatabase? _database;
  FERQuantumEncryption? _quantumEncryption;
  FERFrequencyHopping? _frequencyHopping;
  
  FERAppType _currentApp = FERAppType.chat;
  bool _isMenuOpen = false;
  bool _isInitialized = false;
  AiFERiDUserProfile? _currentUser;
  
  @override
  void initState() {
    super.initState();
    _initializeFERNetwork();
  }
  
  @override
  void dispose() {
    _frequencyHopping?.stop();
    _database?.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return _buildLoadingScreen();
    }
    
    return MaterialApp(
      title: 'FER Network',
      debugShowCheckedModeBanner: false,
      theme: _buildFERTheme(),
      home: _buildMainApp(),
    );
  }
  
  /// Build loading screen
  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: FERColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // FER Logo
            Container(
              width: 100.0,
              height: 100.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [FERColors.primary, FERColors.primaryDark],
                ),
                boxShadow: [
                  BoxShadow(
                    color: FERColors.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                Icons.network_check,
                size: 50.0,
                color: Colors.white,
              ),
            ),
            
            SizedBox(height: 24.0),
            
            // Loading text
            Text(
              'FER Network',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            
            SizedBox(height: 8.0),
            
            Text(
              'Quantum-Secured • Decentralized',
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            
            SizedBox(height: 32.0),
            
            // Loading indicator
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(FERColors.primary),
              strokeWidth: 3,
            ),
            
            SizedBox(height: 16.0),
            
            Text(
              'Initializing FER ecosystem...',
              style: TextStyle(
                fontSize: 12.0,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Build main application
  Widget _buildMainApp() {
    return Stack(
      children: [
        // Main content
        _buildCurrentApp(),
        
        // Sliding menu overlay
        UnifiedSlidingMenu(
          currentApp: _currentApp,
          onAppSelected: _handleAppSelected,
          userProfile: _currentUser,
          isMenuOpen: _isMenuOpen,
          onMenuToggle: _toggleMenu,
        ),
      ],
    );
  }
  
  /// Build current application screen
  Widget _buildCurrentApp() {
    switch (_currentApp) {
      case FERAppType.chat:
        return FERChatScreen(
          userProfile: _currentUser,
          onAppSelected: _handleAppSelected,
        );
      case FERAppType.explorer:
        return FERExplorerScreen(
          userProfile: _currentUser,
          onAppSelected: _handleAppSelected,
        );
      case FERAppType.game:
        return FERGameScreen(
          userProfile: _currentUser,
          onAppSelected: _handleAppSelected,
        );
      case FERAppType.settings:
        return _buildSettingsScreen();
      case FERAppType.security:
        return _buildSecurityScreen();
      case FERAppType.about:
        return _buildAboutScreen();
      default:
        return _buildDefaultScreen();
    }
  }
  
  /// Initialize FER Network services
  Future<void> _initializeFERNetwork() async {
    try {
      debugPrint('🚀 Initializing FER Network...');
      
      // Initialize core services
      _authService = AiFERiDAuthService.instance;
      _database = OfflineFirstDatabase.instance;
      _quantumEncryption = FERQuantumEncryption.instance;
      _frequencyHopping = FERFrequencyHopping.instance;
      
      // Initialize authentication
      await _authService!.initialize();
      
      // Initialize database
      await _database!.initialize();
      
      // Initialize quantum encryption
      await _quantumEncryption!.generateKeyPair();
      
      // Initialize frequency hopping
      await _frequencyHopping!.initialize('fer_main_app');
      
      // Listen for authentication events
      _authService!.authEvents.listen(_handleAuthEvent);
      
      // Check for existing user session
      _currentUser = _authService!.getCurrentUser();
      
      debugPrint('✅ FER Network initialized successfully');
      setState(() => _isInitialized = true);
      
    } catch (e) {
      debugPrint('❌ Failed to initialize FER Network: $e');
      // Show error state or retry logic
    }
  }
  
  /// Handle authentication events
  void _handleAuthEvent(AiFERiDAuthEvent event) {
    switch (event) {
      case AiFERiDAuthEvent.walletAuthenticationSuccess:
      case AiFERiDAuthEvent.anonymousAccessGranted:
        _currentUser = _authService!.getCurrentUser();
        setState(() {});
        debugPrint('🔐 User authenticated: ${_currentUser?.ferretId ?? _currentUser?.walletAddress}');
        break;
      
      case AiFERiDAuthEvent.walletAuthenticationFailed:
      case AiFERiDAuthEvent.anonymousAccessFailed:
        debugPrint('❌ Authentication failed');
        break;
      
      case AiFERiDAuthEvent.sessionEnded:
        _currentUser = null;
        setState(() {});
        debugPrint('👋 User logged out');
        break;
      
      default:
        debugPrint('🔐 Auth event: ${event.toString()}');
    }
  }
  
  /// Handle app selection from menu
  void _handleAppSelected(FERAppType appType) {
    switch (appType) {
      case FERAppType.signout:
        _handleSignOut();
        break;
      case FERAppType.walletAuth:
        _handleWalletAuthentication();
        break;
      default:
        setState(() {
          _currentApp = appType;
        });
        debugPrint('🔄 Switched to app: ${appType.toString()}');
    }
  }
  
  /// Handle sign out
  void _handleSignOut() async {
    if (_currentUser != null) {
      await _authService!.logoutAll();
    }
  }
  
  /// Handle wallet authentication
  void _handleWalletAuthentication() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Connect Wallet'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Connect your blockchain wallet to access FER Network'),
            SizedBox(height: 16.0),
            TextField(
              decoration: InputDecoration(
                labelText: 'Wallet Address',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12.0),
            TextField(
              decoration: InputDecoration(
                labelText: 'Signature',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _authenticateWithWallet();
            },
            child: Text('Connect'),
            style: ElevatedButton.styleFrom(backgroundColor: FERColors.primary),
          ),
        ],
      ),
    );
  }
  
  /// Authenticate with wallet (simulated)
  Future<void> _authenticateWithWallet() async {
    try {
      final result = await _authService!.authenticateWithWallet(
        '0x1234567890abcdef1234567890abcdef12345678',
        'signature_${DateTime.now().millisecondsSinceEpoch}',
        {'network': 'ethereum', 'chainId': 1},
      );
      
      if (result.success) {
        debugPrint('✅ Wallet authentication successful');
      } else {
        debugPrint('❌ Wallet authentication failed: ${result.error}');
      }
    } catch (e) {
      debugPrint('❌ Wallet authentication error: $e');
    }
  }
  
  /// Toggle menu
  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
  }
  
  /// Build settings screen
  Widget _buildSettingsScreen() {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: FERColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Profile'),
            subtitle: Text('Manage your profile'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Notifications'),
            subtitle: Text('Configure notifications'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.storage),
            title: Text('Storage'),
            subtitle: Text('Manage storage settings'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.security),
            title: Text('Security'),
            subtitle: Text('Privacy and security settings'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('About'),
            subtitle: Text('About FER Network'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
  
  /// Build security screen
  Widget _buildSecurityScreen() {
    return Scaffold(
      appBar: AppBar(
        title: Text('Security'),
        backgroundColor: FERColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          ListTile(
            leading: Icon(Icons.verified_user),
            title: Text('Authentication'),
            subtitle: Text(_currentUser != null ? 'Authenticated' : 'Not authenticated'),
            trailing: Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.enhanced_encryption),
            title: Text('Quantum Encryption'),
            subtitle: Text('Quantum-resistant encryption active'),
            trailing: Icon(Icons.check_circle, color: Colors.green),
          ),
          ListTile(
            leading: Icon(Icons.wifi),
            title: Text('Frequency Hopping'),
            subtitle: Text('Secure frequency hopping enabled'),
            trailing: Icon(Icons.check_circle, color: Colors.green),
          ),
          ListTile(
            leading: Icon(Icons.lock),
            title: Text('Data Encryption'),
            subtitle: Text('End-to-end encryption enabled'),
            trailing: Icon(Icons.check_circle, color: Colors.green),
          ),
        ],
      ),
    );
  }
  
  /// Build about screen
  Widget _buildAboutScreen() {
    return Scaffold(
      appBar: AppBar(
        title: Text('About'),
        backgroundColor: FERColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // FER Logo
            Container(
              width: 120.0,
              height: 120.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [FERColors.primary, FERColors.primaryDark],
                ),
              ),
              child: Icon(
                Icons.network_check,
                size: 60.0,
                color: Colors.white,
              ),
            ),
            
            SizedBox(height: 24.0),
            
            Text(
              'FER Network',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            SizedBox(height: 8.0),
            
            Text(
              'Version 1.0.0',
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.grey[600],
              ),
            ),
            
            SizedBox(height: 24.0),
            
            Text(
              'Quantum-Secured • Decentralized Communication',
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: 32.0),
            
            ListTile(
              leading: Icon(Icons.description),
              title: Text('Description'),
              subtitle: Text('FER Network is a revolutionary decentralized communication and gaming ecosystem built on quantum-resistant cryptography and blockchain technology.'),
            ),
            
            ListTile(
              leading: Icon(Icons.featured_play_list),
              title: Text('Features'),
              subtitle: Text('• FERChat - Secure messaging\n• FERExplorer - File management\n• FERGame - Gaming platform\n• AnonymousFerret - Private access'),
            ),
            
            ListTile(
              leading: Icon(Icons.security),
              title: Text('Security'),
              subtitle: Text('• Quantum-resistant encryption\n• Frequency hopping technology\n• Zero-knowledge proofs\n• End-to-end encryption'),
            ),
            
            SizedBox(height: 32.0),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Built with ❤️ on FER Network'),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  /// Build default screen
  Widget _buildDefaultScreen() {
    return Scaffold(
      appBar: AppBar(
        title: Text('FER Network'),
        backgroundColor: FERColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.apps,
              size: 80.0,
              color: Colors.grey,
            ),
            SizedBox(height: 16.0),
            Text(
              'Select an application from the menu',
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Build FER theme
  ThemeData _buildFERTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primarySwatch: Colors.green,
      colorScheme: ColorScheme.dark(
        primary: FERColors.primary,
        secondary: FERColors.secondary,
        background: FERColors.background,
        surface: FERColors.surface,
      ),
      scaffoldBackgroundColor: FERColors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: FERColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        color: FERColors.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: FERColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          fontSize: 24.0,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        titleLarge: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        bodyLarge: TextStyle(
          fontSize: 16.0,
          color: Colors.white.withOpacity(0.9),
        ),
        bodyMedium: TextStyle(
          fontSize: 14.0,
          color: Colors.white.withOpacity(0.7),
        ),
        bodySmall: TextStyle(
          fontSize: 12.0,
          color: Colors.white.withOpacity(0.5),
        ),
      ),
    );
  }
}

/// FER color scheme
class FERColors {
  static const Color primary = Color(0xFF00FF88);
  static const Color primaryDark = Color(0xFF00CC66);
  static const Color accent = Color(0xFFFF006E);
  static const Color secondary = Color(0xFF00CCFF);
  static const Color background = Color(0xFF1A1A1A);
  static const Color surface = Color(0xFF2A2A2A);
}
]]>