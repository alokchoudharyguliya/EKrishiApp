class ChatbotConversation {
  final String id;
  final String userId;
  final String sessionId;
  final List<ChatbotMessage> messages;
  final ChatbotMetadata metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChatbotConversation({
    required this.id,
    required this.userId,
    required this.sessionId,
    this.messages = const [],
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      '_id': id,
      'userId': userId,
      'sessionId': sessionId,
      'messages': messages.map((m) => m.toJson()).toList(),
      'metadata': metadata.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ChatbotConversation.fromJson(Map<String, dynamic> json) {
    try {
      return ChatbotConversation(
        id: json['id'] ?? json['_id'] ?? '',
        userId: json['userId']?.toString() ?? '',
        sessionId: json['sessionId'] ?? '',
        messages:
            json['messages'] is List
                ? (json['messages'] as List)
                    .map((m) => ChatbotMessage.fromJson(m))
                    .toList()
                : [],
        metadata:
            json['metadata'] != null
                ? ChatbotMetadata.fromJson(json['metadata'])
                : ChatbotMetadata(),
        createdAt: _parseDateTime(json['createdAt']) ?? DateTime.now(),
        updatedAt: _parseDateTime(json['updatedAt']) ?? DateTime.now(),
      );
    } catch (e) {
      throw FormatException(
        'Failed to parse ChatbotConversation: $e\nJSON: $json',
      );
    }
  }

  static DateTime? _parseDateTime(dynamic date) {
    if (date is DateTime) return date;
    if (date == null) return null;

    try {
      if (date is String) {
        return DateTime.parse(date);
      }
      return null;
    } catch (e) {
      print('Failed to parse date: $date');
      return null;
    }
  }

  ChatbotConversation copyWith({
    String? id,
    String? userId,
    String? sessionId,
    List<ChatbotMessage>? messages,
    ChatbotMetadata? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChatbotConversation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      sessionId: sessionId ?? this.sessionId,
      messages: messages ?? this.messages,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'ChatbotConversation(id: $id, sessionId: $sessionId, messages: ${messages.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatbotConversation && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class ChatbotMessage {
  final String role; // 'user', 'assistant', 'system'
  final String content;
  final String? provider; // 'gemini', 'openai', 'error', null
  final int tokensUsed;
  final DateTime timestamp;
  final bool isError;

  ChatbotMessage({
    required this.role,
    required this.content,
    this.provider,
    this.tokensUsed = 0,
    required this.timestamp,
    this.isError = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'content': content,
      'provider': provider,
      'tokensUsed': tokensUsed,
      'timestamp': timestamp.toIso8601String(),
      'isError': isError,
    };
  }

  factory ChatbotMessage.fromJson(Map<String, dynamic> json) {
    return ChatbotMessage(
      role: json['role'] ?? 'user',
      content: json['content'] ?? '',
      provider: json['provider'],
      tokensUsed: json['tokensUsed'] as int? ?? 0,
      timestamp: _parseDateTime(json['timestamp']) ?? DateTime.now(),
      isError: json['isError'] ?? false,
    );
  }

  static DateTime? _parseDateTime(dynamic date) {
    if (date is DateTime) return date;
    if (date == null) return null;

    try {
      if (date is String) {
        return DateTime.parse(date);
      }
      return null;
    } catch (e) {
      print('Failed to parse date: $date');
      return null;
    }
  }

  ChatbotMessage copyWith({
    String? role,
    String? content,
    String? provider,
    int? tokensUsed,
    DateTime? timestamp,
    bool? isError,
  }) {
    return ChatbotMessage(
      role: role ?? this.role,
      content: content ?? this.content,
      provider: provider ?? this.provider,
      tokensUsed: tokensUsed ?? this.tokensUsed,
      timestamp: timestamp ?? this.timestamp,
      isError: isError ?? this.isError,
    );
  }

  @override
  String toString() {
    return 'ChatbotMessage(role: $role, content: ${content.substring(0, content.length > 50 ? 50 : content.length)}...)';
  }
}

class ChatbotMetadata {
  final int totalTokensGemini;
  final int totalTokensOpenAI;
  final int fallbackCount;
  final String? lastProvider; // 'gemini', 'openai', null

  ChatbotMetadata({
    this.totalTokensGemini = 0,
    this.totalTokensOpenAI = 0,
    this.fallbackCount = 0,
    this.lastProvider,
  });

  Map<String, dynamic> toJson() {
    return {
      'totalTokensGemini': totalTokensGemini,
      'totalTokensOpenAI': totalTokensOpenAI,
      'fallbackCount': fallbackCount,
      'lastProvider': lastProvider,
    };
  }

  factory ChatbotMetadata.fromJson(Map<String, dynamic> json) {
    return ChatbotMetadata(
      totalTokensGemini: json['totalTokensGemini'] as int? ?? 0,
      totalTokensOpenAI: json['totalTokensOpenAI'] as int? ?? 0,
      fallbackCount: json['fallbackCount'] as int? ?? 0,
      lastProvider: json['lastProvider'],
    );
  }

  ChatbotMetadata copyWith({
    int? totalTokensGemini,
    int? totalTokensOpenAI,
    int? fallbackCount,
    String? lastProvider,
  }) {
    return ChatbotMetadata(
      totalTokensGemini: totalTokensGemini ?? this.totalTokensGemini,
      totalTokensOpenAI: totalTokensOpenAI ?? this.totalTokensOpenAI,
      fallbackCount: fallbackCount ?? this.fallbackCount,
      lastProvider: lastProvider ?? this.lastProvider,
    );
  }
}
