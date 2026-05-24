import 'package:flutter/material.dart';
import '../presentation/network_dashboard/network_dashboard.dart';
import '../presentation/onboarding/fer_vision_screen.dart';

/// App routes for FER Network
/// Includes the new FerVisionScreen that explains the deep purpose.
class AppRoutes {
  static const String initial = '/';
  static const String networkDashboard = '/network_dashboard';
  static const String ferVision = '/fer_vision';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const NetworkDashboard(),
    networkDashboard: (context) => const NetworkDashboard(),
    ferVision: (context) => const FerVisionScreen(),
  };

  static const String initialRoute = initial;
}
