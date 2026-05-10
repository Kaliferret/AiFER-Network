import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../core/app_export.dart';
import '../routes/app_routes.dart';

class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  static NavigationService get instance => _instance;

  // Navigation history for back gestures
  final List<String> _navigationHistory = [];
  int _currentIndex = 0;

  // Quick action handlers
  final Map<String, VoidCallback> _quickActionHandlers = {};

  void registerQuickActionHandler(String action, VoidCallback handler) {
    _quickActionHandlers[action] = handler;
  }

  void handleQuickAction(String action) {
    if (_quickActionHandlers.containsKey(action)) {
      _quickActionHandlers[action]!();
    } else {
      _handleDefaultQuickAction(action);
    }
  }

  void _handleDefaultQuickAction(String action) {
    switch (action) {
      case 'scan_network':
        _performNetworkScan();
        break;
      case 'speed_test':
        _performSpeedTest();
        break;
      case 'emergency_mode':
        _toggleEmergencyMode();
        break;
      case 'security_scan':
        _performSecurityScan();
        break;
      case 'network_settings':
        _openNetworkSettings();
        break;
      case 'backup_data':
        _performDataBackup();
        break;
      default:
        Fluttertoast.showToast(
          msg: "Action '$action' not available",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
    }
  }

  void _performNetworkScan() {
    HapticFeedback.mediumImpact();
    Fluttertoast.showToast(
      msg: "Starting network scan...",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );

    // Simulate network scan
    Future.delayed(const Duration(seconds: 3), () {
      Fluttertoast.showToast(
        msg: "Network scan complete: 47 nodes discovered",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    });
  }

  void _performSpeedTest() {
    HapticFeedback.mediumImpact();
    Fluttertoast.showToast(
      msg: "Running network speed test...",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );

    // Simulate speed test
    Future.delayed(const Duration(seconds: 5), () {
      Fluttertoast.showToast(
        msg: "Speed test complete: ↓125 Mbps ↑87 Mbps",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
    });
  }

  void _toggleEmergencyMode() {
    HapticFeedback.heavyImpact();
    Fluttertoast.showToast(
      msg: "Emergency mode activated",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _performSecurityScan() {
    HapticFeedback.mediumImpact();
    Fluttertoast.showToast(
      msg: "Running security scan...",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );

    // Simulate security scan
    Future.delayed(const Duration(seconds: 4), () {
      Fluttertoast.showToast(
        msg: "Security scan complete: All systems secure",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    });
  }

  void _openNetworkSettings() {
    // Navigate to network settings or device settings
    // This would need to be implemented with proper context
    Fluttertoast.showToast(
      msg: "Opening network settings...",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _performDataBackup() {
    HapticFeedback.mediumImpact();
    Fluttertoast.showToast(
      msg: "Starting data backup...",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );

    // Simulate backup process
    Future.delayed(const Duration(seconds: 3), () {
      Fluttertoast.showToast(
        msg: "Backup complete: 2.4GB saved to secure cloud",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    });
  }

  // Navigation history management
  void addToHistory(String route) {
    _navigationHistory.add(route);
    if (_navigationHistory.length > 10) {
      _navigationHistory.removeAt(0);
    }
  }

  void updateCurrentIndex(int index) {
    _currentIndex = index;
  }

  int getCurrentIndex() => _currentIndex;

  List<String> getNavigationHistory() => List.from(_navigationHistory);

  // Gesture navigation helpers
  bool canNavigateBack() => _navigationHistory.length > 1;

  String? getPreviousRoute() {
    if (_navigationHistory.length > 1) {
      return _navigationHistory[_navigationHistory.length - 2];
    }
    return null;
  }

  // Keyboard shortcuts
  void handleKeyboardShortcut(LogicalKeyboardKey key, BuildContext context) {
    if (HardwareKeyboard.instance.isControlPressed) {
      switch (key) {
        case LogicalKeyboardKey.keyS:
          handleQuickAction('scan_network');
          break;
        case LogicalKeyboardKey.keyT:
          handleQuickAction('speed_test');
          break;
        case LogicalKeyboardKey.keyE:
          handleQuickAction('emergency_mode');
          break;
        case LogicalKeyboardKey.keyR:
          handleQuickAction('security_scan');
          break;
        case LogicalKeyboardKey.keyN:
          handleQuickAction('network_settings');
          break;
        case LogicalKeyboardKey.keyB:
          handleQuickAction('backup_data');
          break;
        case LogicalKeyboardKey.digit1:
          _navigateToIndex(0, context);
          break;
        case LogicalKeyboardKey.digit2:
          _navigateToIndex(1, context);
          break;
        case LogicalKeyboardKey.digit3:
          _navigateToIndex(2, context);
          break;
        case LogicalKeyboardKey.digit4:
          _navigateToIndex(3, context);
          break;
        case LogicalKeyboardKey.digit5:
          _navigateToIndex(4, context);
          break;
      }
    }
  }

  void _navigateToIndex(int index, BuildContext context) {
    final routes = [
      AppRoutes.networkDashboard,
      AppRoutes.messagingInterface,
      AppRoutes.blockchainWalletManager,
      AppRoutes.ferexplorer,
      AppRoutes.adminPanelDashboard,
    ];

    if (index < routes.length) {
      Navigator.pushReplacementNamed(context, routes[index]);
      updateCurrentIndex(index);
      addToHistory(routes[index]);
    }
  }

  // Search functionality
  List<Map<String, dynamic>> searchAll(String query) {
    final results = <Map<String, dynamic>>[];
    final lowerQuery = query.toLowerCase();

    // Search in navigation routes
    final routeResults = _searchRoutes(lowerQuery);
    results.addAll(routeResults);

    // Search in quick actions
    final actionResults = _searchQuickActions(lowerQuery);
    results.addAll(actionResults);

    // Search in network nodes (mock data)
    final networkResults = _searchNetworkNodes(lowerQuery);
    results.addAll(networkResults);

    return results;
  }

  List<Map<String, dynamic>> _searchRoutes(String query) {
    final routes = [
      {
        'name': 'Dashboard',
        'route': AppRoutes.networkDashboard,
        'type': 'screen'
      },
      {
        'name': 'Messages',
        'route': AppRoutes.messagingInterface,
        'type': 'screen'
      },
      {'name': 'Chat', 'route': AppRoutes.messagingInterface, 'type': 'screen'},
      {
        'name': 'Wallets',
        'route': AppRoutes.blockchainWalletManager,
        'type': 'screen'
      },
      {
        'name': 'Blockchain',
        'route': AppRoutes.blockchainWalletManager,
        'type': 'screen'
      },
      {'name': 'Explorer', 'route': AppRoutes.ferexplorer, 'type': 'screen'},
      {'name': 'FERExplorer', 'route': AppRoutes.ferexplorer, 'type': 'screen'},
      {
        'name': 'Admin',
        'route': AppRoutes.adminPanelDashboard,
        'type': 'screen'
      },
      {
        'name': 'Settings',
        'route': AppRoutes.deviceSettings,
        'type': 'screen'
      },
    ];

    return routes
        .where((route) =>
            (route['name'] as String? ?? '').toLowerCase().contains(query))
        .toList();
  }

  List<Map<String, dynamic>> _searchQuickActions(String query) {
    final actions = [
      {'name': 'Network Scan', 'action': 'scan_network', 'type': 'action'},
      {'name': 'Speed Test', 'action': 'speed_test', 'type': 'action'},
      {'name': 'Emergency Mode', 'action': 'emergency_mode', 'type': 'action'},
      {'name': 'Security Scan', 'action': 'security_scan', 'type': 'action'},
      {
        'name': 'Network Settings',
        'action': 'network_settings',
        'type': 'action'
      },
      {'name': 'Backup Data', 'action': 'backup_data', 'type': 'action'},
    ];

    return actions
        .where((action) =>
            (action['name'] as String? ?? '').toLowerCase().contains(query))
        .toList();
  }

  List<Map<String, dynamic>> _searchNetworkNodes(String query) {
    final nodes = [
      {
        'name': 'Gateway Alpha',
        'type': 'network_node',
        'info': 'Primary gateway node'
      },
      {
        'name': 'Mesh Relay Beta',
        'type': 'network_node',
        'info': 'Mesh relay point'
      },
      {
        'name': 'Quantum Hub Delta',
        'type': 'network_node',
        'info': 'Quantum encryption hub'
      },
      {
        'name': 'Edge Node Gamma',
        'type': 'network_node',
        'info': 'Edge computing node'
      },
    ];

    return nodes
        .where((node) =>
            (node['name'] as String? ?? '').toLowerCase().contains(query) ||
            ((node['info'] as String?) ?? '').toLowerCase().contains(query))
        .toList();
  }
}

// Keyboard shortcut widget for global shortcuts
class KeyboardShortcutHandler extends StatefulWidget {
  final Widget child;

  const KeyboardShortcutHandler({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<KeyboardShortcutHandler> createState() =>
      _KeyboardShortcutHandlerState();
}

class _KeyboardShortcutHandlerState extends State<KeyboardShortcutHandler> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          NavigationService.instance.handleKeyboardShortcut(
            event.logicalKey,
            context,
          );
        }
        return KeyEventResult.ignored;
      },
      child: widget.child,
    );
  }
}
