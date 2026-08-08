import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app.dart';
import '../../../core/constants/app_colors.dart';
import '../../farm/providers/farm_provider.dart';
import '../domain/assistant_model.dart';
import '../providers/assistant_provider.dart';

class AssistantScreen extends ConsumerStatefulWidget {
  const AssistantScreen({super.key});

  @override
  ConsumerState<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends ConsumerState<AssistantScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isListening = false;

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage([String? customText]) {
    final text = customText ?? _textController.text;
    if (text.trim().isEmpty) return;

    final langCode = ref.read(appLocaleProvider).languageCode;
    ref.read(chatNotifierProvider.notifier).sendUserMessage(text, langCode);

    if (customText == null) {
      _textController.clear();
    }
    _scrollToBottom();
  }

  void _simulateVoiceInput(bool isMr) {
    setState(() => _isListening = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isMr ? '🎤 ऐकत आहे... (मराठी/English मध्ये बोला)' : '🎤 Listening... (Speak in English/Marathi)',
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.primaryGreen,
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isListening = false);
        _sendMessage(isMr ? 'मक्यावरील लष्करी अळी नियंत्रण' : 'Fall Armyworm control');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMr = ref.watch(appLocaleProvider).languageCode == 'mr';
    final chatState = ref.watch(chatNotifierProvider);
    final activeFarm = ref.watch(activeFarmProvider);
    final quickPromptsAsync = ref.watch(quickPromptsProvider);

    ref.listen<ChatState>(chatNotifierProvider, (previous, next) {
      if (next.messages.length != (previous?.messages.length ?? 0)) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primaryGreen,
              child: Icon(Icons.smart_toy_outlined, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isMr ? 'ॲग्रोव्हिजन AI सल्लागार' : 'AgroVision AI Assistant',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  activeFarm != null
                      ? '🌱 ${activeFarm.name}'
                      : (isMr ? '🟢 कृषी सहाय्यक सज्ज' : '🟢 Agronomist Online'),
                  style: const TextStyle(fontSize: 11, color: AppColors.primaryGreen),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: isMr ? 'संवाद साफ करा' : 'Clear Chat',
            onPressed: () {
              ref.read(chatNotifierProvider.notifier).clearConversation(isMr);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick Questions Row
          quickPromptsAsync.when(
            data: (prompts) => _buildQuickPromptsBar(prompts, isMr),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          const Divider(height: 1, color: Color(0xFFEEEEEE)),

          // Chat Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              itemCount: chatState.messages.length + (chatState.isThinking ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < chatState.messages.length) {
                  return _buildMessageBubble(chatState.messages[index], isMr);
                } else {
                  return _buildThinkingIndicator(isMr);
                }
              },
            ),
          ),

          // Message Input Field
          _buildInputBar(isMr),
        ],
      ),
    );
  }

  Widget _buildQuickPromptsBar(List<QuickPrompt> prompts, bool isMr) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(vertical: 6),
      color: Colors.grey.shade50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: prompts.length,
        itemBuilder: (context, index) {
          final p = prompts[index];
          final title = isMr ? p.titleMr : p.titleEn;
          final prompt = isMr ? p.promptMr : p.promptEn;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              avatar: const Icon(Icons.bolt, size: 14, color: AppColors.primaryGreen),
              label: Text(
                title,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              backgroundColor: Colors.white,
              side: BorderSide(color: AppColors.primaryGreen.withValues(alpha: 0.3)),
              onPressed: () => _sendMessage(prompt),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg, bool isMr) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment:
            msg.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                msg.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!msg.isUser) ...[
                const CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColors.primaryGreen,
                  child: Icon(Icons.eco, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: msg.isUser
                        ? AppColors.primaryGreen
                        : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(msg.isUser ? 16 : 4),
                      bottomRight: Radius.circular(msg.isUser ? 4 : 16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    border: msg.isUser ? null : Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SelectableText(
                        msg.text,
                        style: TextStyle(
                          color: msg.isUser ? Colors.white : Colors.black87,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                      if (!msg.isUser) ...[
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkWell(
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: msg.text));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(isMr ? 'मजकूर कॉपी केला!' : 'Copied to clipboard!'),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(4),
                                child: Icon(Icons.copy_rounded, size: 14, color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (msg.isUser) ...[
                const SizedBox(width: 8),
                const CircleAvatar(
                  radius: 14,
                  backgroundColor: Color(0xFF2E7D32),
                  child: Icon(Icons.person, color: Colors.white, size: 16),
                ),
              ],
            ],
          ),

          // Follow-up Suggestions Chips
          if (!msg.isUser && msg.suggestions.isNotEmpty) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 36),
              child: Wrap(
                spacing: 6,
                runSpacing: 4,
                children: msg.suggestions.map((sug) {
                  return ActionChip(
                    label: Text(
                      sug,
                      style: const TextStyle(fontSize: 11, color: AppColors.primaryGreen, fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.08),
                    side: BorderSide(color: AppColors.primaryGreen.withValues(alpha: 0.3)),
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                    onPressed: () => _sendMessage(sug),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildThinkingIndicator(bool isMr) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 14,
            backgroundColor: AppColors.primaryGreen,
            child: Icon(Icons.eco, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 8),
                Text(
                  isMr ? 'विचार करत आहे...' : 'Analyzing agronomy data...',
                  style: const TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar(bool isMr) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: Icon(
                _isListening ? Icons.mic : Icons.mic_none_rounded,
                color: _isListening ? Colors.red : AppColors.primaryGreen,
              ),
              tooltip: isMr ? 'आवाजाने विचारा' : 'Voice Input',
              onPressed: () => _simulateVoiceInput(isMr),
            ),
            Expanded(
              child: TextField(
                controller: _textController,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  hintText: isMr ? 'मका, खत, किडींविषयी विचारा...' : 'Ask about maize, pests, fertilizers...',
                  hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primaryGreen,
              child: IconButton(
                icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                onPressed: () => _sendMessage(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
