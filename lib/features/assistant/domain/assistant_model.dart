class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<String> suggestions;
  final bool contextUsed;

  const ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.suggestions = const [],
    this.contextUsed = false,
  });
}

class QuickPrompt {
  final String titleEn;
  final String titleMr;
  final String promptEn;
  final String promptMr;

  const QuickPrompt({
    required this.titleEn,
    required this.titleMr,
    required this.promptEn,
    required this.promptMr,
  });

  factory QuickPrompt.fromJson(Map<String, dynamic> json) {
    return QuickPrompt(
      titleEn: json['title_en'] as String? ?? '',
      titleMr: json['title_mr'] as String? ?? '',
      promptEn: json['prompt_en'] as String? ?? '',
      promptMr: json['prompt_mr'] as String? ?? '',
    );
  }
}
