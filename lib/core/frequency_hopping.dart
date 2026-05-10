import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';

/// FER Frequency Hopping Protocol
/// Implements adaptive frequency selection for secure data transmission
class FERFrequencyHopping {
  static FERFrequencyHopping? _instance;
  static FERFrequencyHopping get instance => _instance ??= FERFrequencyHopping._();
  FERFrequencyHopping._();

  static const List<double> frequencyBands = [
    2.4, 2.45, 2.5, 3.5, 3.7, 4.9, 5.0, 5.8, // GHz
  ];
  
  static const Duration hopInterval = Duration(milliseconds: 100);
  static const int sequenceLength = 256;
  
  Timer? _hoppingTimer;
  List<double> _currentSequence = [];
  int _currentHopIndex = 0;
  final Map<double, double> _channelQuality = {};
  bool _isInitialized = false;
  
  /// Initialize frequency hopping system
  Future<void> initialize(String nodeId) async {
    if (_isInitialized) return;
    
    try {
      _currentSequence = await _generateHoppingSequence(nodeId);
      _startHopping();
      _monitorChannelQuality();
      _isInitialized = true;
      
      debugPrint('✅ FER Frequency Hopping initialized for node: $nodeId');
    } catch (e) {
      debugPrint('❌ Failed to initialize frequency hopping: $e');
      rethrow;
    }
  }
  
  /// Generate secure frequency hopping sequence
  Future<List<double>> _generateHoppingSequence(String nodeId) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final seed = _generateCryptographicSeed(nodeId, timestamp);
    final random = math.Random(seed);
    final sequence = <double>[];
    
    // Generate weighted sequence based on channel quality
    for (int i = 0; i < sequenceLength; i++) {
      final weights = frequencyBands.map((freq) {
        return _calculateChannelWeight(freq, _channelQuality[freq] ?? 1.0);
      }).toList();
      
      final selectedFreq = _weightedRandom(frequencyBands, weights, random);
      sequence.add(selectedFreq);
    }
    
    return sequence;
  }
  
  /// Calculate channel weight for frequency selection
  double _calculateChannelWeight(double frequency, double quality) {
    // Weight based on signal quality, interference, and congestion
    final signalWeight = quality;
    final congestionWeight = _estimateCongestion(frequency);
    final interferenceWeight = _estimateInterference(frequency);
    
    return signalWeight * congestionWeight * interferenceWeight;
  }
  
  /// Estimate network congestion for frequency
  double _estimateCongestion(double frequency) {
    // Simulate congestion estimation - in real implementation this would
    // monitor actual network traffic
    final baseCongestion = math.Random().nextDouble() * 0.3; // 0-30% base congestion
    return 1.0 - baseCongestion; // Higher weight = less congestion
  }
  
  /// Estimate interference for frequency
  double _estimateInterference(double frequency) {
    // Simulate interference estimation based on frequency band
    double baseInterference;
    if (frequency < 3.0) {
      baseInterference = 0.2; // Lower bands have more interference
    } else if (frequency < 5.0) {
      baseInterference = 0.1;
    } else {
      baseInterference = 0.05; // Higher bands have less interference
    }
    
    return 1.0 - baseInterference;
  }
  
  /// Weighted random selection for frequency hopping
  double _weightedRandom(
    List<double> frequencies,
    List<double> weights,
    math.Random random,
  ) {
    final totalWeight = weights.reduce((a, b) => a + b);
    var cumulativeWeight = 0.0;
    final randomValue = random.nextDouble() * totalWeight;
    
    for (int i = 0; i < frequencies.length; i++) {
      cumulativeWeight += weights[i];
      if (randomValue <= cumulativeWeight) {
        return frequencies[i];
      }
    }
    
    return frequencies.last;
  }
  
  /// Start frequency hopping process
  void _startHopping() {
    _hoppingTimer = Timer.periodic(hopInterval, (timer) {
      _hopToNextFrequency();
    });
  }
  
  /// Hop to next frequency in sequence
  void _hopToNextFrequency() {
    if (_currentSequence.isEmpty) return;
    
    final nextFrequency = _currentSequence[_currentHopIndex];
    _switchToFrequency(nextFrequency);
    
    _currentHopIndex = (_currentHopIndex + 1) % _currentSequence.length;
    
    // Generate new sequence when nearing end
    if (_currentHopIndex > sequenceLength * 0.8) {
      _regenerateSequence();
    }
  }
  
  /// Switch to specific frequency
  Future<void> _switchToFrequency(double frequency) async {
    try {
      // Hardware-level frequency switching (simulated)
      await _configureRadioFrequency(frequency);
      
      // Update quality metrics
      await _measureChannelQuality(frequency);
      
      debugPrint('📡 Hopped to frequency: ${frequency}GHz');
    } catch (e) {
      debugPrint('❌ Failed to hop to frequency ${frequency}GHz: $e');
      // Fallback to next frequency
      _hopToNextFrequency();
    }
  }
  
  /// Configure radio hardware for specific frequency
  Future<void> _configureRadioFrequency(double frequency) async {
    // Simulate radio hardware configuration
    await Future.delayed(Duration(milliseconds: 5));
    debugPrint('🔧 Radio configured for ${frequency}GHz');
  }
  
  /// Monitor channel quality in real-time
  void _monitorChannelQuality() {
    Timer.periodic(Duration(seconds: 5), (timer) {
      for (final frequency in frequencyBands) {
        _measureChannelQuality(frequency);
      }
    });
  }
  
  /// Measure quality of specific frequency channel
  Future<void> _measureChannelQuality(double frequency) async {
    try {
      final metrics = await _scanFrequency(frequency);
      final quality = _calculateQualityScore(metrics);
      _channelQuality[frequency] = quality;
      
      debugPrint('📊 Channel ${frequency}GHz quality: ${(quality * 100).toStringAsFixed(1)}%');
    } catch (e) {
      debugPrint('❌ Failed to measure quality for ${frequency}GHz: $e');
    }
  }
  
  /// Scan frequency for metrics (simulated)
  Future<FrequencyMetrics> _scanFrequency(double frequency) async {
    // Simulate frequency scanning
    await Future.delayed(Duration(milliseconds: 50));
    
    return FrequencyMetrics(
      signalStrength: 60 + math.Random().nextDouble() * 40, // 60-100%
      interferenceLevel: math.Random().nextDouble() * 20, // 0-20%
      congestionLevel: math.Random().nextDouble() * 30, // 0-30%
      timestamp: DateTime.now(),
    );
  }
  
  /// Calculate quality score from frequency metrics
  double _calculateQualityScore(FrequencyMetrics metrics) {
    final signalStrength = metrics.signalStrength / 100.0;
    final interference = (100 - metrics.interferenceLevel) / 100.0;
    final congestion = (100 - metrics.congestionLevel) / 100.0;
    
    return (signalStrength + interference + congestion) / 3.0;
  }
  
  /// Regenerate hopping sequence with updated channel data
  Future<void> _regenerateSequence() async {
    try {
      final nodeId = await _getCurrentNodeId();
      final newSequence = await _generateHoppingSequence(nodeId);
      
      // Smooth transition to new sequence
      _blendSequences(_currentSequence, newSequence);
      
      debugPrint('🔄 Frequency sequence regenerated');
    } catch (e) {
      debugPrint('❌ Failed to regenerate sequence: $e');
    }
  }
  
  /// Blend old and new sequences for smooth transition
  void _blendSequences(List<double> oldSequence, List<double> newSequence) {
    for (int i = 0; i < math.min(oldSequence.length, newSequence.length); i++) {
      final blendFactor = i / sequenceLength;
      if (math.Random().nextDouble() < blendFactor) {
        _currentSequence[i] = newSequence[i];
      }
    }
  }
  
  /// Get current frequency
  double getCurrentFrequency() {
    if (_currentSequence.isEmpty) return frequencyBands.first;
    return _currentSequence[_currentHopIndex];
  }
  
  /// Get hopping sequence for external use
  List<double> getCurrentSequence() {
    return List.from(_currentSequence);
  }
  
  /// Generate cryptographic seed from node ID and timestamp
  int _generateCryptographicSeed(String nodeId, int timestamp) {
    final combined = '$nodeId$timestamp';
    final hash = _hashString(combined);
    return hash.hashCode % 2147483647; // Ensure positive int32
  }
  
  /// Hash string for seed generation
  String _hashString(String input) {
    // Simple hash simulation - in real implementation use crypto package
    var hash = 0;
    for (int i = 0; i < input.length; i++) {
      hash = ((hash << 5) - hash) + input.codeUnitAt(i);
      hash = hash & 0xffffffff; // Convert to 32bit integer
    }
    return hash.toString();
  }
  
  /// Get current node ID (simulated)
  Future<String> _getCurrentNodeId() async {
    // In real implementation, this would get the actual node ID
    return 'fer_node_${DateTime.now().millisecondsSinceEpoch}';
  }
  
  /// Stop frequency hopping
  void stop() {
    _hoppingTimer?.cancel();
    _hoppingTimer = null;
    _isInitialized = false;
    debugPrint('🛑 Frequency hopping stopped');
  }
}

/// Frequency metrics for channel quality assessment
class FrequencyMetrics {
  final double signalStrength;
  final double interferenceLevel;
  final double congestionLevel;
  final DateTime timestamp;
  
  FrequencyMetrics({
    required this.signalStrength,
    required this.interferenceLevel,
    required this.congestionLevel,
    required this.timestamp,
  });
  
  @override
  String toString() {
    return 'FrequencyMetrics(signal: ${signalStrength.toStringAsFixed(1)}%, '
           'interference: ${interferenceLevel.toStringAsFixed(1)}%, '
           'congestion: ${congestionLevel.toStringAsFixed(1)}%)';
  }
}

/// Frequency hopping exception
class FrequencyHoppingException implements Exception {
  final String message;
  FrequencyHoppingException(this.message);
  
  @override
  String toString() => 'FrequencyHoppingException: $message';
}
