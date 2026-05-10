import 'package:flutter/material.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/onboarding_flow/onboarding_flow.dart';
import '../presentation/authentication_setup/authentication_setup.dart';
import '../presentation/authentication_setup/aiferid_login_screen.dart';
import '../presentation/google_authentication_setup/google_authentication_setup.dart';
import '../presentation/offline_authentication/offline_authentication_screen.dart';
import '../presentation/network_dashboard/network_dashboard.dart';
import '../presentation/messaging_interface/messaging_interface.dart';
import '../presentation/voice_call_interface/voice_call_interface.dart';
import '../presentation/gaming_hub/gaming_hub_screen.dart';
import '../presentation/ferexplorer/ferexplorer_screen.dart';
import '../presentation/blockchain_wallet_manager/blockchain_wallet_manager_screen.dart';
import '../presentation/admin_panel_dashboard/admin_panel_dashboard.dart';
import '../presentation/device_settings/device_settings_screen.dart';
import '../presentation/todo_list/todo_list_screen.dart';

class AppRoutes {
  static const String initialRoute = '/';
  static const String splashScreen = '/';
  static const String onboardingFlow = '/onboarding-flow';
  static const String authenticationSetup = '/authentication-setup';
  static const String googleAuthenticationSetup =
      '/google-authentication-setup';
  // Updated route for new AiFERiD login screen
  static const String aiferidLoginScreen = '/aiferid-login';
  // Legacy aliases for backward compatibility
  static const String aiferidAuthenticationSetup =
      '/aiferid-authentication-setup';
  static const String offlineAuthentication = '/offline-authentication';
  static const String networkDashboard = '/network-dashboard';
  static const String messagingInterface = '/messaging-interface';
  static const String voiceCallInterface = '/voice-call-interface';
  static const String ferexplorer = '/ferexplorer';
  static const String gamingHub = '/gaming-hub';
  static const String blockchainWalletManager = '/blockchain-wallet-manager';
  static const String adminPanelDashboard = '/admin-panel-dashboard';
  static const String deviceSettings = '/device-settings';
  static const String todoList = '/todo-list';

  static Map<String, WidgetBuilder> routes = {
    splashScreen: (context) => const SplashScreen(),
    onboardingFlow: (context) => const OnboardingFlow(),
    authenticationSetup: (context) => const AuthenticationSetup(),
    googleAuthenticationSetup: (context) => const AiFERiDAuthenticationSetup(),
    // New enhanced login screen
    aiferidLoginScreen: (context) => const AiFERiDLoginScreen(),
    // Backward compatibility - redirect to new login screen
    aiferidAuthenticationSetup: (context) => const AiFERiDLoginScreen(),
    offlineAuthentication: (context) => const OfflineAuthenticationScreen(),
    networkDashboard: (context) => const NetworkDashboard(),
    messagingInterface: (context) => const MessagingInterface(),
    voiceCallInterface: (context) => const VoiceCallInterface(),
    gamingHub: (context) => const GamingHubScreen(),
    ferexplorer: (context) => const FERExplorerScreen(),
    blockchainWalletManager: (context) => const BlockchainWalletManagerScreen(),
    adminPanelDashboard: (context) => const AdminPanelDashboard(),
    deviceSettings: (context) => const DeviceSettingsScreen(),
    todoList: (context) => const TodoListScreen(),
  };
}
