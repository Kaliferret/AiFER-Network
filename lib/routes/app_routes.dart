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
import '../widgets/ferret_companion.dart';
import '../widgets/aifer_hud.dart';
import '../presentation/ferret_files/ferret_files_screen.dart';
import '../presentation/ferret_notes/ferret_notes_screen.dart';
import '../presentation/ferret_terminal/ferret_terminal_screen.dart';
import '../presentation/ferret_mail/ferret_mail_screen.dart';
import '../presentation/ferret_gallery/ferret_gallery_screen.dart';
import '../presentation/ferret_calendar/ferret_calendar_screen.dart';
import '../presentation/ferret_media/ferret_media_screen.dart';
import '../presentation/fer_code/fer_code_screen.dart';
import '../presentation/fer_trade/fer_trade_screen.dart';
import '../presentation/fer_chain/fer_chain_screen.dart';
import '../presentation/marketplace/marketplace_screen.dart';

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
  // Phase 1: AIFER v11 Integration routes
  static const String ferretCompanionDemo = '/ferret-companion-demo';
  static const String aiferHudDemo = '/aifer-hud-demo';
  static const String settings = '/settings';
  // Phase 3: OS Apps routes
  static const String ferretFiles = '/ferret-files';
  static const String ferretNotes = '/ferret-notes';
  // Phase 3-2: OS Apps routes
  static const String ferretTerminal = '/ferret-terminal';
  static const String ferretMail = '/ferret-mail';
  static const String ferretGallery = '/ferret-gallery';
  static const String ferretCalendar = '/ferret-calendar';
  static const String ferretMedia = '/ferret-media';

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
    // Phase 1: AIFER v11 Integration routes
    ferretCompanionDemo: (context) => const FERCompanionDemoScreen(),
    aiferHudDemo: (context) => const AiFERHUDDemoScreen(),
    settings: (context) => const DeviceSettingsScreen(),
    // Phase 3: OS Apps routes
    ferretFiles: (context) => const FerretFilesScreen(),
    ferretNotes: (context) => const FerretNotesScreen(),
    // Phase 3-2: OS Apps routes
    ferretTerminal: (context) => const FerretTerminalScreen(),
    ferretMail: (context) => const FerretMailScreen(),
    ferretGallery: (context) => const FerretGalleryScreen(),
    ferretCalendar: (context) => const FerretCalendarScreen(),
    ferretMedia: (context) => const FerretMediaScreen(),
    ferCode: (context) => const FerCodeScreen(),
    ferTrade: (context) => const FerTradeScreen(),
    ferChain: (context) => const FerChainScreen(),
    marketplace: (context) => const MarketplaceScreen(),
  };
}
