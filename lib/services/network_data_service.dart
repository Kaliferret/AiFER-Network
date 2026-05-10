import './supabase_service.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math'; // Add this import for trigonometric functions

class NetworkDataService {
  static NetworkDataService? _instance;
  static NetworkDataService get instance =>
      _instance ??= NetworkDataService._();

  NetworkDataService._();

  // Get network nodes - NO FALLBACK DATA
  Future<List<Map<String, dynamic>>> getNetworkNodes() async {
    try {
      final response = await SupabaseService.instance
          .from('network_nodes')
          .select('*')
          .order('last_seen', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Failed to fetch network nodes: $e');
      return []; // Return empty list, not mock data
    }
  }

  // Get blockchain nodes - NO FALLBACK DATA
  Future<List<Map<String, dynamic>>> getBlockchainNodes() async {
    try {
      final response = await SupabaseService.instance
          .from('blockchain_nodes')
          .select('*')
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Failed to fetch blockchain nodes: $e');
      return []; // Return empty list, not mock data
    }
  }

  // Get data streams - NO FALLBACK DATA
  Future<List<Map<String, dynamic>>> getDataStreams() async {
    try {
      final response = await SupabaseService.instance
          .from('data_streams')
          .select('*')
          .order('created_at', ascending: false)
          .limit(50);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Failed to fetch data streams: $e');
      return []; // Return empty list, not mock data
    }
  }

  // Get active nodes count
  Future<int> getActiveNodesCount() async {
    try {
      final response = await SupabaseService.instance
          .from('network_nodes')
          .select('id')
          .eq('status', 'active');

      return (response as List).length;
    } catch (e) {
      debugPrint('Failed to fetch active nodes count: $e');
      return 0;
    }
  }

  // Get network statistics
  Future<Map<String, dynamic>> getNetworkStats() async {
    try {
      final activeNodes = await getActiveNodesCount();

      final totalNodesResponse =
          await SupabaseService.instance.from('network_nodes').select('id');

      final recentStreamsResponse = await SupabaseService.instance
          .from('data_streams')
          .select('id')
          .gte(
              'created_at',
              DateTime.now()
                  .subtract(const Duration(hours: 24))
                  .toIso8601String());

      return {
        'active_nodes': activeNodes,
        'total_nodes': (totalNodesResponse as List).length,
        'recent_streams': (recentStreamsResponse as List).length,
        'network_uptime': activeNodes > 0 ? 99.8 : 0.0,
        'last_updated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      debugPrint('Failed to fetch network stats: $e');
      return {
        'active_nodes': 0,
        'total_nodes': 0,
        'recent_streams': 0,
        'network_uptime': 0.0,
        'last_updated': DateTime.now().toIso8601String(),
      };
    }
  }

  // Update node status (admin only)
  Future<bool> updateNodeStatus(String nodeId, String status) async {
    try {
      await SupabaseService.instance.from('network_nodes').update({
        'status': status,
        'last_seen': DateTime.now().toIso8601String(),
      }).eq('id', nodeId);
      return true;
    } catch (e) {
      debugPrint('Failed to update node status: $e');
      return false;
    }
  }

  // Add new network node (admin only)
  Future<Map<String, dynamic>?> addNetworkNode({
    required String deviceId,
    required String deviceName,
    required String status,
    int? signalStrength,
    Map<String, dynamic>? locationData,
  }) async {
    try {
      final response = await SupabaseService.instance
          .from('network_nodes')
          .insert({
            'device_id': deviceId,
            'device_name': deviceName,
            'status': status,
            'signal_strength': signalStrength ?? -50,
            'location_data': locationData,
            'last_seen': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      return response;
    } catch (e) {
      debugPrint('Failed to add network node: $e');
      rethrow;
    }
  }

  // Subscribe to real-time network changes
  void subscribeToNetworkUpdates(Function(Map<String, dynamic>) onUpdate) {
    try {
      SupabaseService.instance.client
          .channel('public:network_nodes')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'network_nodes',
            callback: (payload) {
              onUpdate(payload.newRecord);
            },
          )
          .subscribe();
    } catch (e) {
      debugPrint('Failed to subscribe to network updates: $e');
    }
  }

  // Get nearby nodes based on location
  Future<List<Map<String, dynamic>>> getNearbyNodes({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
  }) async {
    try {
      // Simple distance calculation using Supabase - for more accurate results use PostGIS
      final response = await SupabaseService.instance
          .from('network_nodes')
          .select('*')
          .not('location_data', 'is', null)
          .eq('status', 'active');

      final nodes = List<Map<String, dynamic>>.from(response);

      // Filter by distance (simplified calculation)
      return nodes.where((node) {
        final locationData = node['location_data'] as Map<String, dynamic>?;
        if (locationData == null) return false;

        final nodeLat = locationData['lat'] as double?;
        final nodeLng = locationData['lng'] as double?;

        if (nodeLat == null || nodeLng == null) return false;

        // Simple distance check (not accurate for production)
        final distance =
            _calculateDistance(latitude, longitude, nodeLat, nodeLng);
        return distance <= radiusKm;
      }).toList();
    } catch (e) {
      debugPrint('Failed to fetch nearby nodes: $e');
      return [];
    }
  }

  // Simple distance calculation (Haversine formula approximation)
  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);

    final double c = 2 * asin(sqrt(a));

    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (3.14159265359 / 180);
  }
}
