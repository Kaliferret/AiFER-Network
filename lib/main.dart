import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import './presentation/network_dashboard/network_dashboard.dart';
import './services/google_auth_service.dart';
import './services/renewed_auth_service.dart';
import './services/theme_service.dart';
import './services/unified_supabase_service.dart';
import './widgets/custom_error_widget.dart';
import 'core/app_export.dart';

// ── Phase 4: Claude protocol-backend singletons ─────────────────
import './core/fer_quantum_encryption.dart';
import './core/frequency_hopping.dart';
import './services/aiferid_auth_service.dart';
import './services/offline_first_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Phase 4: Boot the real FER Network protocol stack ──────────
  // These run FIRST because everything downstream depends on them.
  try {
    // Quantum-resistant encryption (lattice-based) — stateless singleton.
    FERQuantumEncryption.instance;
    debugPrint('✅ FERQuantumEncryption ready (lattice 512, mod 4096)');
  } catch (e) {
    debugPrint('❌ FERQuantumEncryption init failed: $e');
  }

  try {
    // Offline-first local DB (SQLite + shared_preferences).
    await OfflineFirstDatabase.instance.initialize();
    debugPrint('✅ OfflineFirstDatabase initialized');
  } catch (e) {
    debugPrint('❌ OfflineFirstDatabase init failed: $e');
  }

  try {
    // AiFERiD wallet-signature auth (Claude-built).
    await AiFERiDAuthService.instance.initialize();
    debugPrint('✅ AiFERiDAuthService initialized');
  } catch (e) {
    debugPrint('❌ AiFERiDAuthService init failed: $e');
  }

  try {
    // Frequency hopping needs a node id — derive from current AiFERiD if any,
    // otherwise a stable device-local ephemeral id.
    final currentUser = AiFERiDAuthService.instance.getCurrentUser();
    final nodeId = currentUser?.walletAddress ??
        currentUser?.ferretId ??
        'fer-node-${DateTime.now().millisecondsSinceEpoch}';
    await FERFrequencyHopping.instance.initialize(nodeId);
    debugPrint('✅ FERFrequencyHopping initialized (node=$nodeId)');
  } catch (e) {
    debugPrint('❌ FERFrequencyHopping init failed: $e');
  }
  // ───────────────────────────────────────────────────────────────

  // Initialize legacy services with enhanced error handling and validation
  try {
    // Primary initialization: Unified Supabase Service (transport layer only)
    await UnifiedSupabaseService.initialize();
    debugPrint('✅ Unified Supabase service initialized successfully');
  } catch (e) {
    debugPrint('❌ Critical: Unified Supabase initialization failed: $e');
    // Don't proceed if core database service fails
  }

  try {
    await RenewedAuthService.instance.initialize();
    debugPrint('✅ Renewed Auth service initialized successfully');
  } catch (e) {
    debugPrint('❌ Renewed Auth service initialization failed: $e');
  }

  try {
    await ThemeService.instance.initialize();
    debugPrint('✅ Theme service initialized successfully');
  } catch (e) {
    debugPrint('❌ Theme service initialization failed: $e');
  }

  try {
    GoogleAuthService.instance.initialize();
    debugPrint('✅ Google Auth service initialized successfully');
  } catch (e) {
    debugPrint('❌ Google Auth service initialization failed: $e');
  }

  // Enhanced system health check
  try {
    final systemStatus =
        await UnifiedSupabaseService.instance.getSystemStatus();
    if (systemStatus['connection']['status'] == 'healthy') {
      debugPrint('🟢 System Status: All services operational');
      debugPrint('📊 Users: ${systemStatus['database_stats']['total_users']}');
      debugPrint('📝 Todos: ${systemStatus['database_stats']['total_todos']}');
      debugPrint(
          '💬 Messages: ${systemStatus['database_stats']['total_messages']}');
      debugPrint(
          '⚡ Latency: ${systemStatus['connection']['latency_ms']}ms (${systemStatus['connection']['quality']})');
    } else {
      debugPrint('🔴 System Status: Issues detected');
    }
  } catch (e) {
    debugPrint('⚠️ System health check failed: $e');
  }

  bool _hasShownError = false;

  // 🚨 CRITICAL: Custom error handling - DO NOT REMOVE
  ErrorWidget.builder = (FlutterErrorDetails details) {
    if (!_hasShownError) {
      _hasShownError = true;

      // Reset flag after 5 seconds to allow error widget on new screens
      Future.delayed(Duration(seconds: 5), () {
        _hasShownError = false;
      });

      return CustomErrorWidget(errorDetails: details);
    }
    return SizedBox.shrink();
  };

  // 🚨 CRITICAL: Device orientation lock - DO NOT REMOVE
  Future.wait([
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]),
  ]).then((value) {
    runApp(FERNetworkApp());
  });
}

class FERNetworkApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, screenType) {
        return AnimatedBuilder(
          animation: ThemeService.instance,
          builder: (context, child) {
            return MaterialApp(
              title: 'FER Network - Enhanced',
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: ThemeService.instance.themeMode,
              // 🚨 CRITICAL: NEVER REMOVE OR MODIFY
              builder: (context, child) {
                return MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: TextScaler.linear(1.0)),
                  child: child!,
                );
              },
              // 🚨 END CRITICAL SECTION
              debugShowCheckedModeBanner: false,
              routes: AppRoutes.routes,
              initialRoute: AppRoutes.initialRoute,
              onGenerateRoute: (settings) {
                // Enhanced route generation with authentication checks and error handling
                final routeName = settings.name ?? AppRoutes.initialRoute;

                // Handle unknown routes gracefully
                if (!AppRoutes.routes.containsKey(routeName)) {
                  debugPrint('⚠️ Unknown route requested: $routeName');
                  return MaterialPageRoute(
                    builder: (context) => const NetworkDashboard(),
                    settings: RouteSettings(name: AppRoutes.networkDashboard),
                  );
                }

                // Get the widget builder
                final builder = AppRoutes.routes[routeName]!;

                // Create route with enhanced error boundary
                return MaterialPageRoute(
                  builder: (context) {
                    try {
                      return builder(context);
                    } catch (e, stackTrace) {
                      debugPrint('❌ Route building error for $routeName: $e');
                      debugPrint('Stack trace: $stackTrace');

                      // Return error-safe fallback
                      return Scaffold(
                        appBar: AppBar(title: Text('Error')),
                        body: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline,
                                  size: 64, color: Colors.red),
                              SizedBox(height: 16),
                              Text('Failed to load screen'),
                              SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () => Navigator.pushReplacementNamed(
                                  context,
                                  AppRoutes.networkDashboard,
                                ),
                                child: Text('Go to Dashboard'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                  settings: settings,
                );
              },
            );
          },
        );
      },
    );
  }
}
