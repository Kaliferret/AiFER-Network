import 'package:dio/dio.dart';
import 'dart:convert';

/// AiFER (AI over FER) Service
///
/// Provides AI-powered chat functionality for the FERMesh network
/// Integrates OpenAI GPT models with FER packet types for intelligent messaging
class AiFERService {
  static final AiFERService _instance = AiFERService._internal();
  late final Dio _dio;
  static const String apiKey = String.fromEnvironment('OPENAI_API_KEY');

  // AI personality context for FERMesh network
  static const String _aiPersonalityContext = '''
You are AiFER, an AI assistant integrated into the FERMesh decentralized network. You communicate through frequency-based packets (.AiF, .AiFp) and help users with:

- FERMesh network optimization and troubleshooting
- Blockchain transaction guidance and security
- Emergency mesh network coordination
- Technical questions about decentralized communications
- General assistance while maintaining the FER network theme

Keep responses concise, technical when appropriate, and always consider the mesh network context. Use Dutch phrases occasionally since this is a Netherlands-based network.
''';

  factory AiFERService() {
    return _instance;
  }

  AiFERService._internal() {
    _initializeService();
  }

  void _initializeService() {
    if (apiKey.isEmpty) {
      throw Exception('OPENAI_API_KEY must be provided via --dart-define');
    }

    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.openai.com/v1',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
  }

  /// Generate AI response for chat messages
  ///
  /// Takes conversation history and generates contextual responses
  /// Uses GPT-5-mini for fast, efficient responses in chat context
  Future<AiFERResponse> generateChatResponse({
    required List<AiFERMessage> conversationHistory,
    required String currentMessage,
    String packageType = '.AiF',
    String? userContext,
  }) async {
    try {
      // Prepare conversation context
      final messages = <Map<String, dynamic>>[
        {
          'role': 'system',
          'content': _buildSystemPrompt(packageType, userContext),
        },

        // Add conversation history (last 10 messages for context)
        ...conversationHistory.take(10).map((msg) => {
              'role': msg.isFromUser ? 'user' : 'assistant',
              'content': msg.content,
            }),

        // Add current message
        {
          'role': 'user',
          'content': currentMessage,
        },
      ];

      final requestData = {
        'model': 'gpt-5-mini', // Fast, efficient model for chat
        'messages': messages,
        'max_completion_tokens': 500, // Limit response length for chat
        'reasoning_effort': 'minimal', // Fast responses for real-time chat
        'verbosity': 'low', // Concise responses
      };

      final response = await _dio.post('/chat/completions', data: requestData);

      final aiResponse =
          response.data['choices'][0]['message']['content'] as String;
      final usage = response.data['usage'];

      return AiFERResponse(
        content: aiResponse,
        packageType: packageType,
        reasoning: 'AiFER processed via FERMesh network',
        tokensUsed: usage?['total_tokens'] ?? 0,
        processingTime: DateTime.now(),
      );
    } on DioException catch (e) {
      // Handle network errors gracefully
      if (e.type == DioExceptionType.connectionTimeout) {
        return AiFERResponse(
          content:
              'FERMesh network latency detected. AI response delayed. Probeer het opnieuw (try again).',
          packageType: packageType,
          reasoning: 'Network timeout - fallback response',
          tokensUsed: 0,
          processingTime: DateTime.now(),
          isError: true,
        );
      }

      return AiFERResponse(
        content:
            'AiFER temporarily offline. FERMesh network operating in standard mode.',
        packageType: packageType,
        reasoning: 'API error - fallback response',
        tokensUsed: 0,
        processingTime: DateTime.now(),
        isError: true,
      );
    } catch (e) {
      return AiFERResponse(
        content:
            'Error processing through AiFER. Check your FERMesh connection.',
        packageType: packageType,
        reasoning: 'General error - fallback response',
        tokensUsed: 0,
        processingTime: DateTime.now(),
        isError: true,
      );
    }
  }

  /// Stream AI responses for real-time chat
  ///
  /// Provides streaming responses for better user experience
  Stream<String> streamChatResponse({
    required List<AiFERMessage> conversationHistory,
    required String currentMessage,
    String packageType = '.AiF',
    String? userContext,
  }) async* {
    try {
      final messages = <Map<String, dynamic>>[
        {
          'role': 'system',
          'content': _buildSystemPrompt(packageType, userContext),
        },
        ...conversationHistory.take(10).map((msg) => {
              'role': msg.isFromUser ? 'user' : 'assistant',
              'content': msg.content,
            }),
        {
          'role': 'user',
          'content': currentMessage,
        },
      ];

      final requestData = {
        'model': 'gpt-5-mini',
        'messages': messages,
        'max_completion_tokens': 500,
        'reasoning_effort': 'minimal',
        'verbosity': 'low',
        'stream': true,
      };

      final response = await _dio.post(
        '/chat/completions',
        data: requestData,
        options: Options(responseType: ResponseType.stream),
      );

      final stream = response.data.stream;
      await for (var line
          in LineSplitter().bind(utf8.decoder.bind(stream.stream))) {
        if (line.startsWith('data: ')) {
          final data = line.substring(6);
          if (data == '[DONE]') break;

          try {
            final json = jsonDecode(data) as Map<String, dynamic>;
            final delta = json['choices'][0]['delta'] as Map<String, dynamic>;
            final content = delta['content'] ?? '';

            if (content.isNotEmpty) {
              yield content;
            }

            final finishReason = json['choices'][0]['finish_reason'];
            if (finishReason != null) break;
          } catch (e) {
            // Skip malformed JSON chunks
            continue;
          }
        }
      }
    } catch (e) {
      yield 'AiFER connection interrupted. Switching to offline mode...';
    }
  }

  /// Analyze message for AI assistance triggers
  ///
  /// Determines if a message should trigger AI response
  bool shouldTriggerAI(String message) {
    final lowerMessage = message.toLowerCase();

    // Trigger AI on specific patterns
    final triggers = [
      'aifer',
      'ai',
      'help',
      'hulp', // Dutch for help
      '?',
      'how to',
      'wat is', // Dutch for what is
      'explain',
      'uitleg', // Dutch for explanation
      'fermesh',
      'blockchain',
      'network',
      'emergency',
      'noodgeval', // Dutch for emergency
    ];

    return triggers.any((trigger) => lowerMessage.contains(trigger));
  }

  /// Build system prompt based on package type and context
  String _buildSystemPrompt(String packageType, String? userContext) {
    String basePrompt = _aiPersonalityContext;

    // Add package-specific instructions
    switch (packageType) {
      case '.AiFp':
        basePrompt +=
            '\n\nThis is a private encrypted message. Be extra cautious about security and privacy advice.';
        break;
      case '.FERg':
        basePrompt +=
            '\n\nThis is gaming context. Provide gaming-optimized network advice and fun responses.';
        break;
      default:
        basePrompt += '\n\nStandard FERMesh communication active.';
    }

    // Add user context if provided
    if (userContext != null && userContext.isNotEmpty) {
      basePrompt += '\n\nUser context: $userContext';
    }

    return basePrompt;
  }

  /// Check if AI service is available
  Future<bool> isAIServiceAvailable() async {
    if (apiKey.isEmpty) return false;

    try {
      final response = await _dio.get('/models');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Get available AI models for FERMesh network
  Future<List<String>> getAvailableModels() async {
    try {
      final response = await _dio.get('/models');
      final models = response.data['data'] as List;

      // Filter to FER-compatible models
      return models
          .map((m) => m['id'] as String)
          .where((id) => id.startsWith('gpt-') || id.startsWith('o'))
          .toList();
    } catch (e) {
      return ['gpt-5-mini', 'gpt-5-nano']; // Default fallback models
    }
  }
}

/// AiFER Message data structure
class AiFERMessage {
  final String content;
  final bool isFromUser;
  final DateTime timestamp;
  final String packageType;
  final String? blockchainHash;

  AiFERMessage({
    required this.content,
    required this.isFromUser,
    required this.timestamp,
    this.packageType = '.AiF',
    this.blockchainHash,
  });

  factory AiFERMessage.fromChatMessage(Map<String, dynamic> message) {
    return AiFERMessage(
      content: message['content'] ?? '',
      isFromUser: message['isCurrentUser'] ?? false,
      timestamp: DateTime.now(), // Could parse from message timestamp
      packageType: message['packageType'] ?? '.AiF',
      blockchainHash: message['blockchainHash'],
    );
  }
}

/// AiFER Response data structure
class AiFERResponse {
  final String content;
  final String packageType;
  final String reasoning;
  final int tokensUsed;
  final DateTime processingTime;
  final bool isError;

  AiFERResponse({
    required this.content,
    required this.packageType,
    required this.reasoning,
    required this.tokensUsed,
    required this.processingTime,
    this.isError = false,
  });

  /// Convert to chat message format
  Map<String, dynamic> toChatMessage() {
    return {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'content': content,
      'type': 'text',
      'timestamp': _formatTimestamp(processingTime),
      'isCurrentUser': false,
      'senderName': 'AiFER',
      'senderAvatar':
          'https://images.pexels.com/photos/8386440/pexels-photo-8386440.jpeg',
      'senderAvatarSemanticLabel':
          'AI avatar showing digital neural network pattern in cyan and blue colors',
      'deliveryStatus': 'delivered',
      'packageType': packageType,
      'blockchainHash': isError
          ? null
          : 'aifer_0x${DateTime.now().millisecondsSinceEpoch.toRadixString(16)}',
      'aiGenerated': true,
      'reasoning': reasoning,
      'tokensUsed': tokensUsed,
    };
  }

  String _formatTimestamp(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
