import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';
import '../services/chat_service.dart';

class ChatDetailScreen extends StatefulWidget {
  final int conversationIndex;
  final bool isAdminView;
  final String? adminUserId;
  final String? adminUserName;

  const ChatDetailScreen({
    super.key,
    required this.conversationIndex,
    this.isAdminView = false,
    this.adminUserId,
    this.adminUserName,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _supabase = Supabase.instance.client;
  late ChatConversation _conversation;
  bool _isTyping = false;
  bool _isWaitingForAgent = false;
  bool _agentConnected = false;
  bool _chatEnded = false;
  Timer? _agentCheckTimer;
  int _lastMessageCount = 0;
  bool _hasNewMessage = false;
  bool _agentAlreadyJoined = false;

  @override
  void initState() {
    super.initState();
    if (widget.isAdminView) {
      _setupAdminChat();
    } else {
      _conversation = ChatService().conversations[widget.conversationIndex];
      _checkWaitingStatus();
    }
    _startPolling();
    _lastMessageCount = _conversation.messages.length;
  }

  void _setupAdminChat() {
    _conversation = ChatConversation(
      name: widget.adminUserName ?? 'Guest',
      avatar: (widget.adminUserName ?? 'G')[0].toUpperCase(),
      lastMessage: '',
      time: '',
      unread: 0,
      icon: LucideIcons.user,
      isOnline: true,
      messages: [],
    );
    _loadUserMessages();
  }

  Future<void> _loadUserMessages() async {
    if (widget.adminUserId == null) return;
    try {
      final response = await _supabase
          .from('messages')
          .select()
          .eq('sender_id', widget.adminUserId!)
          .order('created_at', ascending: true);
      final messages = response as List;
      for (final m in messages) {
        _conversation.messages.add(ChatMessage(
            text: m['text'] as String? ?? '',
            isMe: false,
            time: _formatTime(m['created_at'] as String?),
            isRead: true));
      }
      if (_conversation.messages.isNotEmpty) {
        _conversation.lastMessage = _conversation.messages.last.text;
        _conversation.time = _conversation.messages.last.time;
      }
      _lastMessageCount = _conversation.messages.length;
      if (mounted) setState(() {});
    } catch (e) {}
  }

  void _checkWaitingStatus() {
    if (!widget.isAdminView) {
      _isWaitingForAgent = ChatService().isWaitingForAgent;
      _agentConnected = ChatService().isAgentConnected;
    }
  }

  void _startPolling() {
    _agentCheckTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      if (widget.isAdminView) {
        _pollAdminMessages();
      } else {
        _pollUserMessages();
      }
      setState(() {});
    });
  }

  Future<void> _pollUserMessages() async {
    if (_isWaitingForAgent && !_agentAlreadyJoined) {
      await ChatService().checkAgentJoined();
      _checkWaitingStatus();
      if (_agentConnected) {
        _agentAlreadyJoined = true;
        return;
      }
    }
    // Check if admin has ended the chat
    if (_agentConnected) {
      await _checkIfAdminEndedChat();
      await _loadMessagesFromDB();
    }
  }

  Future<void> _checkIfAdminEndedChat() async {
    final user = _supabase.auth.currentUser;
    if (user == null || !_agentConnected || _chatEnded) return;
    try {
      final response = await _supabase
          .from('live_chat_requests')
          .select('status')
          .eq('user_id', user.id)
          .eq('status', 'active')
          .order('created_at', ascending: false)
          .limit(1);
      final requests = response as List;
      // If no active request found, admin has ended the chat
      if (requests.isEmpty) {
        _agentLeft();
      }
    } catch (e) {
      print('[ChatDetailScreen] Error checking chat status: $e');
    }
  }

  void _agentLeft() {
    if (_chatEnded) return; // Already ended
    setState(() {
      _chatEnded = true;
      _agentConnected = false;
      _isWaitingForAgent = false;
    });
    _agentCheckTimer?.cancel();
    final replyTime =
        '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}';
    _conversation.messages.add(ChatMessage(
        text:
            "😢 The live agent has left the chat.\n\nWe're sorry! Here's what you can do:",
        isMe: false,
        time: replyTime,
        isRead: true));
    _conversation.messages.add(ChatMessage(
        text: "What would you like to do next?",
        isMe: false,
        time: replyTime,
        isRead: true,
        quickReplies: [
          '📞 Call Us',
          '💬 WhatsApp',
          '📧 Email',
          '🔄 New Chat',
          '🏠 Back to Home'
        ]));
    setState(() {});
    _scrollToBottom();
  }

  Future<void> _pollAdminMessages() async {
    if (widget.adminUserId == null) return;
    try {
      // BUG FIX #2: Fetch BOTH sent and received messages, and don't clear previous messages
      final response = await _supabase
          .from('messages')
          .select()
          .or('sender_id.eq.${widget.adminUserId!},receiver_id.eq.${widget.adminUserId!}')
          .order('created_at', ascending: true);
      final dbMessages = response as List;
      if (dbMessages.length > _lastMessageCount) {
        _hasNewMessage = true;
        HapticFeedback.lightImpact();
        // Append only new messages instead of clearing all
        for (int i = _lastMessageCount; i < dbMessages.length; i++) {
          final m = dbMessages[i];
          _conversation.messages.add(ChatMessage(
              text: m['text'] as String? ?? '',
              isMe: m['sender_id'] == _supabase.auth.currentUser?.id,
              time: _formatTime(m['created_at'] as String?),
              isRead: true));
        }
        if (_conversation.messages.isNotEmpty) {
          _conversation.lastMessage = _conversation.messages.last.text;
          _conversation.time = _conversation.messages.last.time;
        }
        _lastMessageCount = dbMessages.length;
        _scrollToBottom();
        if (mounted) setState(() {});
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) setState(() => _hasNewMessage = false);
        });
      }
    } catch (e) {}
  }

  Future<void> _loadMessagesFromDB() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    try {
      // BUG FIX #2: Don't clear all messages - append only new ones to prevent losing admin messages
      final response = await _supabase
          .from('messages')
          .select()
          .or('sender_id.eq.${user.id},receiver_id.eq.${user.id}')
          .order('created_at', ascending: true);
      final dbMessages = response as List;
      if (dbMessages.isNotEmpty) {
        // Get the last non-greeting message timestamp from UI
        DateTime? lastUIMessageTime;
        for (int i = _conversation.messages.length - 1; i >= 0; i--) {
          final msg = _conversation.messages[i];
          // Skip greeting message
          if (!msg.text.contains('virtual assistant')) {
            // Try to find corresponding DB message
            for (final dbMsg in dbMessages) {
              if (dbMsg['text'] == msg.text && dbMsg['sender_id'] == user.id) {
                lastUIMessageTime =
                    DateTime.tryParse(dbMsg['created_at'] as String? ?? '');
                break;
              }
            }
            break;
          }
        }

        // Only add messages newer than the last UI message
        int newMessagesAdded = 0;
        for (final m in dbMessages) {
          final msgTime = DateTime.tryParse(m['created_at'] as String? ?? '');
          final msgText = m['text'] as String? ?? '';
          final msgIsMe = m['sender_id'] == user.id;

          // Skip if this message is already in the UI
          bool alreadyInUI = false;
          for (final uiMsg in _conversation.messages) {
            if (uiMsg.text == msgText && uiMsg.isMe == msgIsMe) {
              alreadyInUI = true;
              break;
            }
          }

          // Add only if it's newer than last UI message and not already there
          if (!alreadyInUI &&
              (lastUIMessageTime == null ||
                  msgTime == null ||
                  msgTime.isAfter(lastUIMessageTime))) {
            _conversation.messages.add(ChatMessage(
              text: msgText,
              isMe: msgIsMe,
              time: _formatTime(m['created_at'] as String?),
              isRead: true,
            ));
            newMessagesAdded++;
          }
        }

        if (newMessagesAdded > 0) {
          if (_conversation.messages.isNotEmpty) {
            _conversation.lastMessage = _conversation.messages.last.text;
            _conversation.time = _conversation.messages.last.time;
          }
          _lastMessageCount = _conversation.messages.length;
          _hasNewMessage = true;
          _scrollToBottom();
          if (mounted) setState(() {});
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) setState(() => _hasNewMessage = false);
          });
        } else {
          _lastMessageCount = _conversation.messages.length;
        }
      }
    } catch (e) {}
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _agentCheckTimer?.cancel();
    super.dispose();
  }

  void _sendMessage({String? text}) {
    if (_isWaitingForAgent || _chatEnded) return;
    final messageText = text ?? _messageController.text.trim();
    if (messageText.isEmpty) return;
    if (widget.isAdminView && widget.adminUserId != null) {
      _sendAdminMessage(messageText);
      return;
    }
    ChatService().sendMessage(widget.conversationIndex, messageText);
    _messageController.clear();
    _isTyping = true;
    setState(() {});
    Future.delayed(200.ms, () {
      if (mounted) {
        _checkWaitingStatus();
        setState(() {});
      }
    });
    Future.delayed(100.ms, _scrollToBottom);
    Future.delayed(2.seconds, () {
      if (mounted) {
        _isTyping = false;
        _checkWaitingStatus();
        setState(() {});
        _scrollToBottom();
      }
    });
  }

  void _sendAdminMessage(String text) async {
    final now = DateTime.now();
    final time = '${now.hour}:${now.minute.toString().padLeft(2, '0')}';
    _conversation.messages
        .add(ChatMessage(text: text, isMe: true, time: time, isRead: true));
    _conversation.lastMessage = text;
    _conversation.time = 'Just now';
    // Increment message count to prevent duplicates when polling
    _lastMessageCount++;
    _messageController.clear();
    _scrollToBottom();
    setState(() {});
    try {
      await _supabase.from('messages').insert({
        'sender_id': _supabase.auth.currentUser?.id,
        'receiver_id': widget.adminUserId,
        'text': text
      });
    } catch (e) {}
  }

  void _handleQuickReply(String reply) {
    // BUG FIX #3: Allow "Back to Menu" quick reply even when waiting for agent or agent is connected
    final lower = reply.toLowerCase();
    if (lower.contains('back') ||
        lower.contains('back to menu') ||
        lower.contains('back to home')) {
      _sendMessage(text: reply);
      return;
    }

    // Handle agent left options
    if (lower.contains('call')) {
      _sendMessage(text: '📞 Call Us');
      return;
    }
    if (lower.contains('whatsapp') || lower.contains('💬')) {
      _sendMessage(text: '💬 WhatsApp Us');
      return;
    }
    if (lower.contains('email') || lower.contains('📧')) {
      _sendMessage(text: '📧 Email Us');
      return;
    }
    if (lower.contains('new chat') || lower.contains('🔄')) {
      _startNewChat();
      return;
    }

    if (_isWaitingForAgent || _chatEnded || _agentConnected) return;
    if (lower.contains('yes') || lower.contains('connect')) {
      _sendMessage(text: 'yes, connect me');
      return;
    }
    _sendMessage(text: reply);
  }

  void _startNewChat() {
    _chatEnded = false;
    _agentConnected = false;
    _isWaitingForAgent = false;
    _agentAlreadyJoined = false;
    _lastMessageCount = 0;
    _conversation.messages.clear();
    _conversation.messages.add(ChatMessage(
        text:
            "Hi! I'm your GeesTrip virtual assistant. I can help you book hotels, flights, shuttles, tours, and more! What would you like to do? 👋",
        isMe: false,
        time: '',
        quickReplies: [
          '🏨 Find Hotels',
          '✈️ Book Flight',
          '🚗 Shuttle',
          '🗺️ Tours',
          '🍽️ Dining',
          '🤝 Companion'
        ]));
    setState(() {});
    _agentCheckTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      if (widget.isAdminView) {
        _pollAdminMessages();
      } else {
        _pollUserMessages();
      }
      setState(() {});
    });
  }

  void _endChat() async {
    setState(() => _chatEnded = true);
    _isWaitingForAgent = false;
    _agentConnected = false;
    _agentAlreadyJoined = false;
    _agentCheckTimer?.cancel();
    final replyTime =
        '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}';
    _conversation.messages.add(ChatMessage(
        text: "Chat ended. Thank you! 🙏",
        isMe: false,
        time: replyTime,
        isRead: true,
        quickReplies: widget.isAdminView
            ? null
            : ['🔄 Start New Chat', '🏠 Back to Home']));
    ChatService().endWaiting();
    setState(() {});
    _scrollToBottom();
    if (widget.isAdminView) {
      try {
        await _supabase
            .from('live_chat_requests')
            .update({'status': 'ended'})
            .eq('user_id', widget.adminUserId!)
            .eq('status', 'active');
      } catch (e) {}
    }
  }

  void _scrollToBottom() {
    Future.delayed(50.ms, () {
      if (_scrollController.hasClients)
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: 300.ms, curve: Curves.easeOutCubic);
    });
  }

  String _formatTime(String? dateString) {
    if (dateString == null) return '';
    try {
      final d = DateTime.parse(dateString);
      final diff = DateTime.now().difference(d);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      return '${diff.inHours}h ago';
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages = _conversation.messages;
    final lastMessage = messages.isNotEmpty ? messages.last : null;
    final showQuickReplies = lastMessage != null &&
        !lastMessage.isMe &&
        lastMessage.quickReplies != null &&
        lastMessage.quickReplies!.isNotEmpty &&
        !_isTyping &&
        !_chatEnded &&
        !widget.isAdminView &&
        !_agentConnected;

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(8, 8, 12, 12),
              decoration: BoxDecoration(color: AppColors.bgWhite, boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2))
              ]),
              child: Row(children: [
                GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                            color: AppColors.bgPrimary,
                            borderRadius: BorderRadius.circular(12)),
                        child: const Icon(LucideIcons.arrowLeft,
                            size: 22, color: AppColors.textSecondary))),
                const SizedBox(width: 10),
                Stack(children: [
                  Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [Color(0xFF1F3BB3), Color(0xFF3B5CF6)]),
                          borderRadius: BorderRadius.circular(14)),
                      child: Center(
                          child: Text(_conversation.avatar,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700)))),
                  if (_hasNewMessage && !widget.isAdminView)
                    Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                                color: AppColors.error,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.white, width: 2)))),
                ]),
                const SizedBox(width: 10),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(_conversation.name,
                          style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary)),
                      Text(
                          widget.isAdminView
                              ? (_hasNewMessage
                                  ? '🔔 New message!'
                                  : 'Live Chat')
                              : (_chatEnded
                                  ? 'Chat ended'
                                  : _agentConnected
                                      ? 'Agent connected ✅'
                                      : _isWaitingForAgent
                                          ? '🎧 Waiting for agent...'
                                          : 'Online'),
                          style: TextStyle(
                              fontSize: 12,
                              color: _hasNewMessage
                                  ? AppColors.error
                                  : _agentConnected
                                      ? AppColors.success
                                      : _isWaitingForAgent
                                          ? AppColors.accentGold
                                          : AppColors.textMuted,
                              fontWeight: FontWeight.w600)),
                    ])),
                if (widget.isAdminView && !_chatEnded)
                  GestureDetector(
                      onTap: _endChat,
                      child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                              color: AppColors.errorLight,
                              borderRadius: BorderRadius.circular(12)),
                          child: const Icon(LucideIcons.logOut,
                              color: AppColors.error, size: 18))),
                if (!_agentConnected && !_chatEnded && !widget.isAdminView)
                  GestureDetector(
                      onTap: _endChat,
                      child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                              color: AppColors.errorLight,
                              borderRadius: BorderRadius.circular(12)),
                          child: const Icon(LucideIcons.phoneOff,
                              color: AppColors.error, size: 18))),
                if (_chatEnded)
                  GestureDetector(
                      onTap: () => context.go('/'),
                      child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(12)),
                          child: const Icon(LucideIcons.home,
                              color: Colors.white, size: 18))),
              ]),
            ),
            // Admin new message banner
            if (_hasNewMessage && widget.isAdminView)
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: AppColors.error.withOpacity(0.08),
                  child: const Row(children: [
                    Icon(LucideIcons.bell, color: AppColors.error, size: 14),
                    SizedBox(width: 8),
                    Expanded(
                        child: Text('New message from guest!',
                            style: TextStyle(
                                fontSize: 11,
                                color: AppColors.error,
                                fontWeight: FontWeight.w500)))
                  ])),
            // Waiting banner
            if (_isWaitingForAgent && !_chatEnded && !widget.isAdminView)
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: AppColors.accentGold.withOpacity(0.08),
                  child: const Row(children: [
                    Icon(LucideIcons.clock,
                        color: AppColors.accentGold, size: 14),
                    SizedBox(width: 8),
                    Expanded(
                        child: Text('Waiting for agent...',
                            style: TextStyle(
                                fontSize: 11,
                                color: AppColors.accentGold,
                                fontWeight: FontWeight.w500)))
                  ])),
            // Agent connected banner
            if (_agentConnected && !widget.isAdminView)
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: AppColors.success.withOpacity(0.08),
                  child: const Row(children: [
                    Icon(LucideIcons.checkCircle,
                        color: AppColors.success, size: 14),
                    SizedBox(width: 8),
                    Expanded(
                        child: Text("Agent connected - you're chatting live!",
                            style: TextStyle(
                                fontSize: 11,
                                color: AppColors.success,
                                fontWeight: FontWeight.w500)))
                  ])),
            // Messages
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                itemCount: messages.length + (_isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == messages.length && _isTyping)
                    return _buildTypingIndicator();
                  final message = messages[index];
                  final isSystemMessage = !message.isMe &&
                      (message.text.contains('has joined') ||
                          message.text.contains('Chat ended'));
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: isSystemMessage
                        ? Center(
                            child: Container(
                                margin: const EdgeInsets.only(bottom: 14),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                    color: AppColors.accentBlueLight,
                                    borderRadius: BorderRadius.circular(12)),
                                child: Text(message.text,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600),
                                    textAlign: TextAlign.center)))
                        : Row(
                            mainAxisAlignment: message.isMe
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (!message.isMe)
                                Container(
                                    width: 32,
                                    height: 32,
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                        gradient: const LinearGradient(colors: [
                                          Color(0xFF1F3BB3),
                                          Color(0xFF3B5CF6)
                                        ]),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Center(
                                        child: Text(_conversation.avatar,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700)))),
                              Flexible(
                                  child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                    color: message.isMe
                                        ? AppColors.primary
                                        : AppColors.bgWhite,
                                    borderRadius: BorderRadius.only(
                                        topLeft: const Radius.circular(18),
                                        topRight: const Radius.circular(18),
                                        bottomLeft: message.isMe
                                            ? const Radius.circular(18)
                                            : const Radius.circular(6),
                                        bottomRight: message.isMe
                                            ? const Radius.circular(6)
                                            : const Radius.circular(18)),
                                    boxShadow: [
                                      BoxShadow(
                                          color: (message.isMe
                                                  ? AppColors.primary
                                                  : Colors.black)
                                              .withOpacity(
                                                  message.isMe ? 0.2 : 0.04),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2))
                                    ]),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(message.text,
                                          style: TextStyle(
                                              color: message.isMe
                                                  ? Colors.white
                                                  : AppColors.textPrimary,
                                              fontSize: 15,
                                              height: 1.4)),
                                      const SizedBox(height: 4),
                                      Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(message.time,
                                                style: TextStyle(
                                                    color: message.isMe
                                                        ? Colors.white60
                                                        : AppColors.textMuted,
                                                    fontSize: 10)),
                                            if (message.isMe) ...[
                                              const SizedBox(width: 4),
                                              Icon(LucideIcons.check,
                                                  size: 12,
                                                  color: message.isRead
                                                      ? Colors.white
                                                      : Colors.white60)
                                            ]
                                          ]),
                                    ]),
                              )),
                            ],
                          ),
                  ).animate().fadeIn(duration: 300.ms).moveY(begin: 10);
                },
              ),
            ),
            // Quick Replies
            if (showQuickReplies)
              Container(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: (lastMessage.quickReplies?.map((reply) {
                            final isBack = reply.contains('Back');
                            return GestureDetector(
                                onTap: () => _handleQuickReply(reply),
                                child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 10),
                                    decoration: BoxDecoration(
                                        color: isBack
                                            ? AppColors.bgWhite
                                            : AppColors.primary,
                                        borderRadius: BorderRadius.circular(20),
                                        border: isBack
                                            ? Border.all(
                                                color: AppColors.tabInactive)
                                            : null,
                                        boxShadow: [
                                          BoxShadow(
                                              color: (isBack
                                                      ? Colors.black
                                                      : AppColors.primary)
                                                  .withOpacity(0.08),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2))
                                        ]),
                                    child: Text(reply,
                                        style: TextStyle(
                                            color: isBack
                                                ? AppColors.textSecondary
                                                : Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600))));
                          }).toList() ??
                          []))),
            // Input bar
            if (!_chatEnded)
              Container(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
                  decoration:
                      BoxDecoration(color: AppColors.bgWhite, boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, -2))
                  ]),
                  child: Row(children: [
                    Expanded(
                        child: Container(
                            decoration: BoxDecoration(
                                color: AppColors.bgPrimary,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: Colors.black.withOpacity(0.06))),
                            child: TextField(
                                controller: _messageController,
                                enabled: !_isWaitingForAgent ||
                                    widget.isAdminView ||
                                    _agentConnected,
                                style: const TextStyle(
                                    fontSize: 15, color: AppColors.textPrimary),
                                decoration: InputDecoration(
                                    hintText: widget.isAdminView
                                        ? 'Type reply...'
                                        : (_agentConnected
                                            ? 'Chat with agent...'
                                            : (_isWaitingForAgent
                                                ? 'Waiting for agent...'
                                                : 'Type a message...')),
                                    hintStyle: const TextStyle(
                                        color: AppColors.textPlaceholder),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 14)),
                                onSubmitted: (_) => _sendMessage()))),
                    const SizedBox(width: 8),
                    GestureDetector(
                        onTap: () => _sendMessage(),
                        child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [
                                  Color(0xFF1F3BB3),
                                  Color(0xFF3B5CF6)
                                ]),
                                borderRadius: BorderRadius.circular(14)),
                            child: const Icon(LucideIcons.send,
                                color: Colors.white, size: 20))),
                  ])),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFF1F3BB3), Color(0xFF3B5CF6)]),
                  borderRadius: BorderRadius.circular(10)),
              child: Center(
                  child: Text(_conversation.avatar,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700)))),
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                  color: AppColors.bgWhite,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(18),
                      topRight: Radius.circular(18),
                      bottomRight: Radius.circular(18),
                      bottomLeft: Radius.circular(6)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2))
                  ]),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                _TypingDot(delay: 0),
                const SizedBox(width: 5),
                _TypingDot(delay: 200),
                const SizedBox(width: 5),
                _TypingDot(delay: 400)
              ])),
        ]));
  }
}

class _AttachmentOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _AttachmentOption(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: AppColors.bgPrimary,
                borderRadius: BorderRadius.circular(16)),
            child: Row(children: [
              Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: color, size: 22)),
              const SizedBox(width: 14),
              Expanded(
                  child: Text(label,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary))),
              const Icon(LucideIcons.chevronRight,
                  color: AppColors.textMuted, size: 18)
            ])));
  }
}

class _TypingDot extends StatefulWidget {
  final int delay;
  const _TypingDot({required this.delay});
  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
                color: AppColors.textMuted
                    .withOpacity(0.3 + (_controller.value * 0.7)),
                shape: BoxShape.circle)));
  }
}
