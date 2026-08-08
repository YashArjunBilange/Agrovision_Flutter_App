import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../main.dart';
import '../../farm/providers/farm_provider.dart';
import '../data/assistant_repository.dart';
import '../domain/assistant_model.dart';

final assistantRepositoryProvider = Provider<AssistantRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AssistantRepository(apiClient);
});

final quickPromptsProvider = FutureProvider<List<QuickPrompt>>((ref) async {
  final repository = ref.watch(assistantRepositoryProvider);
  return await repository.getQuickPrompts();
});

class ChatState {
  final List<ChatMessage> messages;
  final bool isThinking;
  final String? error;

  const ChatState({
    this.messages = const [],
    this.isThinking = false,
    this.error,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isThinking,
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isThinking: isThinking ?? this.isThinking,
      error: error,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final AssistantRepository _repository;
  final Ref _ref;

  ChatNotifier(this._repository, this._ref)
      : super(
          ChatState(
            messages: [
              ChatMessage(
                text: 'नमस्कार शेतकरी मित्र! 🙏 मी ॲग्रोव्हिजन AI कृषी सल्लागार आहे. मका पीक, खत व्यवस्थापन, लष्करी अळी नियंत्रण किंवा फवारणीविषयी विचारा.',
                isUser: false,
                timestamp: DateTime.now(),
                suggestions: [
                  'लष्करी अळी नियंत्रण',
                  'खताचे वेळापत्रक',
                  'पाणी नियोजन',
                  'तणनाशक फवारणी',
                ],
              ),
            ],
          ),
        );

  Future<void> sendUserMessage(String message, String langCode) async {
    if (message.trim().isEmpty) return;

    final userMsg = ChatMessage(
      text: message.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isThinking: true,
      error: null,
    );

    try {
      final activeFarm = _ref.read(activeFarmProvider);
      final res = await _repository.sendMessage(
        message: message.trim(),
        farmId: activeFarm?.id,
        language: langCode,
      );

      final replyText = res['reply'] as String? ?? 'उत्तरामध्ये अडचण आली.';
      final suggestions = (res['suggestions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [];
      final contextUsed = res['context_used'] as bool? ?? false;

      final botMsg = ChatMessage(
        text: replyText,
        isUser: false,
        timestamp: DateTime.now(),
        suggestions: suggestions,
        contextUsed: contextUsed,
      );

      state = state.copyWith(
        messages: [...state.messages, botMsg],
        isThinking: false,
      );
    } catch (e) {
      state = state.copyWith(
        isThinking: false,
        error: e.toString(),
        messages: [
          ...state.messages,
          ChatMessage(
            text: langCode == 'mr'
                ? 'माफ करा, सर्व्हरशी संपर्क साधण्यात अडचण आली. कृपया पुन्हा प्रयत्न करा.'
                : 'Sorry, connection error occurred. Please try again.',
            isUser: false,
            timestamp: DateTime.now(),
          ),
        ],
      );
    }
  }

  void clearConversation(bool isMr) {
    state = ChatState(
      messages: [
        ChatMessage(
          text: isMr
              ? 'नमस्कार शेतकरी मित्र! 🙏 मी ॲग्रोव्हिजन AI कृषी सल्लागार आहे. मका पीक, खत व्यवस्थापन, लष्करी अळी नियंत्रण किंवा फवारणीविषयी विचारा.'
              : 'Namaste Farmer Friend! 🙏 I am your AgroVision AI Agronomist. Ask anything about maize, FAW control, fertilizer doses or spraying.',
          isUser: false,
          timestamp: DateTime.now(),
          suggestions: isMr
              ? ['लष्करी अळी नियंत्रण', 'खताचे वेळापत्रक', 'पाणी नियोजन', 'तणनाशक फवारणी']
              : ['Fall Armyworm Control', 'Fertilizer Schedule', 'Irrigation Timing', 'Weed Control'],
        ),
      ],
    );
  }
}

final chatNotifierProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  final repository = ref.watch(assistantRepositoryProvider);
  return ChatNotifier(repository, ref);
});
