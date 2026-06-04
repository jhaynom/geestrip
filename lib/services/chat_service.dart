import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'admin_service.dart';

class ChatMessage {
  final String text;
  final bool isMe;
  final String time;
  final bool isRead;
  final List<String>? quickReplies;
  final Map<String, dynamic>? navigationAction;
  final String? attachmentType;
  final String? attachmentUrl;

  ChatMessage({
    required this.text,
    required this.isMe,
    required this.time,
    this.isRead = false,
    this.quickReplies,
    this.navigationAction,
    this.attachmentType,
    this.attachmentUrl,
  });
}

class ChatConversation {
  String name;
  final String avatar;
  String lastMessage;
  String time;
  int unread;
  final IconData icon;
  List<ChatMessage> messages;
  final bool isOnline;

  ChatConversation({
    required this.name,
    required this.avatar,
    required this.lastMessage,
    required this.time,
    required this.unread,
    required this.icon,
    required this.messages,
    this.isOnline = false,
  });
}

class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  final _supabase = Supabase.instance.client;
  final List<ChatConversation> _conversations = [];
  bool _waitingForAgent = false;
  bool _agentConnected = false;
  bool _agentJoinedAnnounced = false;
  Timer? _agentWaitTimer;

  VoidCallback? onMessagesUpdated;

  List<ChatConversation> get conversations => _conversations;
  int get totalUnread => _conversations.fold(0, (sum, c) => sum + c.unread);
  bool get isWaitingForAgent => _waitingForAgent;
  bool get isAgentConnected => _agentConnected;

  void endWaiting() {
    _waitingForAgent = false;
    _agentConnected = false;
    _agentJoinedAnnounced = false;
    _agentWaitTimer?.cancel();
  }

  Future<void> checkAgentJoined() async {
    if (!_waitingForAgent || _conversations.isEmpty) return;
    if (_agentJoinedAnnounced) return; // Prevent duplicate announcements
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    try {
      // BUG FIX #1: Only check requests from last 2 minutes with agent_id assigned
      final twoMinutesAgo = DateTime.now().subtract(const Duration(minutes: 2));
      final response = await _supabase
          .from('live_chat_requests')
          .select('status, agent_name, agent_id')
          .eq('user_id', user.id)
          .eq('status', 'active')
          .gte('created_at',
              twoMinutesAgo.toIso8601String()) // Only last 2 minutes
          .order('created_at', ascending: false)
          .limit(5); // Get multiple to filter by agent_id in code
      final list = response as List;
      if (list.isNotEmpty) {
        final req = list.first;
        if (req['agent_id'] != null) {
          print('[ChatService] Real agent found: ${req['agent_name']}');
          _agentJoinedAnnounced = true; // Mark as announced
          agentJoined(0, req['agent_name'] as String? ?? 'Agent');
          onMessagesUpdated?.call();
          return;
        }
      }
    } catch (e) {
      print('[ChatService] Error checking agent: $e');
    }
  }

  Future<void> loadNewMessages() async {
    if (!_agentConnected || _conversations.isEmpty) return;
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    try {
      // BUG FIX #2: Don't clear messages - append only new ones to prevent losing admin messages
      final response = await _supabase
          .from('messages')
          .select()
          .or('sender_id.eq.${user.id},receiver_id.eq.${user.id}')
          .order('created_at', ascending: true);
      final dbMessages = response as List;

      if (dbMessages.isNotEmpty) {
        // Get the last non-greeting message timestamp from UI
        DateTime? lastUIMessageTime;
        for (int i = _conversations[0].messages.length - 1; i >= 0; i--) {
          final msg = _conversations[0].messages[i];
          // Skip greeting message
          if (!msg.text.contains('virtual assistant')) {
            // Try to find corresponding DB message to get its timestamp
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
          for (final uiMsg in _conversations[0].messages) {
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
            _conversations[0].messages.add(ChatMessage(
                text: msgText,
                isMe: msgIsMe,
                time: _formatTime(m['created_at'] as String?),
                isRead: true));
            newMessagesAdded++;
          }
        }

        if (newMessagesAdded > 0) {
          if (_conversations[0].messages.isNotEmpty) {
            _conversations[0].lastMessage =
                _conversations[0].messages.last.text;
            _conversations[0].time = _conversations[0].messages.last.time;
          }
          onMessagesUpdated?.call();
        }
      }
    } catch (e) {
      // Ignore errors loading chat updates.
    }
  }

  Future<void> loadConversations() async {
    _conversations.clear();
    _conversations.add(ChatConversation(
      name: 'GeesTrip Concierge',
      avatar: 'G',
      lastMessage: 'Where would you like to go? 🌍',
      time: '',
      unread: 0,
      icon: LucideIcons.sparkles,
      isOnline: true,
      messages: [
        ChatMessage(
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
            ])
      ],
    ));
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    try {
      final response = await _supabase
          .from('messages')
          .select()
          .or('sender_id.eq.${user.id},receiver_id.eq.${user.id}')
          .order('created_at', ascending: true);
      final messages = response as List;
      if (messages.isNotEmpty) {
        final convoMessages = messages
            .map((m) => ChatMessage(
                text: m['text'] as String? ?? '',
                isMe: m['sender_id'] == user.id,
                time: _formatTime(m['created_at'] as String?),
                isRead: m['is_read'] as bool? ?? false))
            .toList();
        if (convoMessages.isNotEmpty) {
          _conversations[0].messages.addAll(convoMessages);
          _conversations[0].lastMessage = convoMessages.last.text;
          _conversations[0].time = convoMessages.last.time;
        }
      }
    } catch (e) {
      // Ignore errors loading conversation history.
    }
  }

  void sendMessage(int conversationIndex, String text) async {
    final now = DateTime.now();
    final time = '${now.hour}:${now.minute.toString().padLeft(2, '0')}';
    final lower = text.toLowerCase().trim();

    // HANDLE: Back to Menu / Back to Home
    if (lower.contains('back to menu') || lower.contains('back to home')) {
      _agentConnected = false;
      _waitingForAgent = false;
      _agentWaitTimer?.cancel();
      _conversations[conversationIndex].messages.clear();
      _conversations[conversationIndex].messages.add(ChatMessage(
            text:
                "Hi! I'm your GeesTrip virtual assistant. What would you like to do? 👋",
            isMe: false,
            time: time,
            quickReplies: [
              '🏨 Find Hotels',
              '✈️ Book Flight',
              '🚗 Shuttle',
              '🗺️ Tours',
              '🍽️ Dining',
              '🤝 Companion'
            ],
          ));
      _conversations[conversationIndex].lastMessage =
          "What would you like to do?";
      _conversations[conversationIndex].time = 'Just now';
      onMessagesUpdated?.call();
      return;
    }

    String? attachmentType;
    if (text.contains('[Photo') || text.contains('📷')) {
      attachmentType = 'photo';
    }
    if (text.contains('[Document') || text.contains('📄')) {
      attachmentType = 'document';
    }
    if (text.contains('[Location') || text.contains('📍')) {
      attachmentType = 'location';
    }

    _conversations[conversationIndex].messages.add(ChatMessage(
        text: text,
        isMe: true,
        time: time,
        isRead: true,
        attachmentType: attachmentType));
    _conversations[conversationIndex].lastMessage = text;
    _conversations[conversationIndex].time = 'Just now';

    final user = _supabase.auth.currentUser;
    if (user != null) {
      try {
        await _supabase
            .from('messages')
            .insert({'sender_id': user.id, 'text': text});
      } catch (e) {
        // Ignore insert failures for chat messages.
      }
    }

    if (_agentConnected) {
      onMessagesUpdated?.call();
      return;
    }

    if (attachmentType != null) {
      final replyTime =
          '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}';
      final replies = {
        'photo': "📷 Photo received!",
        'document': "📄 Document received!",
        'location': "📍 Location received!"
      };
      _conversations[conversationIndex].messages.add(ChatMessage(
          text: replies[attachmentType]!,
          isMe: false,
          time: replyTime,
          isRead: true,
          quickReplies: ['🏠 Back to Menu']));
      _conversations[conversationIndex].lastMessage = replies[attachmentType]!;
      _conversations[conversationIndex].time = 'Just now';
      _conversations[conversationIndex].unread = 1;
      onMessagesUpdated?.call();
      return;
    }

    if (lower.contains('yes') &&
        (lower.contains('connect') || lower.contains('agent'))) {
      _requestLiveAgent(conversationIndex);
      onMessagesUpdated?.call();
      return;
    }
    if (lower.contains('wait') &&
        (lower.contains('agent') || lower.contains('keep'))) {
      _requestLiveAgent(conversationIndex);
      onMessagesUpdated?.call();
      return;
    }

    if (_containsAny(lower, [
      'live agent',
      'human',
      'real person',
      'talk to someone',
      'speak to agent',
      'customer service',
      'representative',
      'need a person',
      'connect me',
      'talk to agent'
    ])) {
      _conversations[conversationIndex].messages.add(ChatMessage(
          text:
              "I understand you'd like to speak with a human agent. 🎧\n\nBefore I connect you:\n• A live agent will join this chat\n• Average wait: 3-5 min\n• Agent sees our history\n\nConnect you now?",
          isMe: false,
          time: '${now.hour}:${now.minute.toString().padLeft(2, '0')}',
          isRead: true,
          quickReplies: ['✅ Yes, Connect Me', '🏠 Back to Menu']));
      _conversations[conversationIndex].lastMessage = "Connect to live agent?";
      _conversations[conversationIndex].time = 'Just now';
      _conversations[conversationIndex].unread = 1;
      onMessagesUpdated?.call();
      return;
    }

    if (_waitingForAgent &&
        _containsAny(lower, ['call now', 'email', 'whatsapp', 'keep trying'])) {
      handleTimeoutQuickReply(conversationIndex, text);
      onMessagesUpdated?.call();
      return;
    }
    if (_containsAny(lower, ['call instead', 'phone number'])) {
      _conversations[conversationIndex].messages.add(ChatMessage(
          text:
              "📞 Reach us at:\n\n**+234 800 GEESTRIP**\n\n24/7 phone support available.",
          isMe: false,
          time: '${now.hour}:${now.minute.toString().padLeft(2, '0')}',
          isRead: true,
          quickReplies: ['🏨 Find Hotels', '✈️ Book Flight', '🏠 Back to Menu']));
      _conversations[conversationIndex].lastMessage =
          "Call us at +234 800 GEESTRIP";
      _conversations[conversationIndex].time = 'Just now';
      _conversations[conversationIndex].unread = 1;
      onMessagesUpdated?.call();
      return;
    }

    Future.delayed(const Duration(milliseconds: 1500), () {
      final response = _getSmartResponse(text);
      final replyTime =
          '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}';
      _conversations[conversationIndex].messages.add(ChatMessage(
          text: response['text'] as String,
          isMe: false,
          time: replyTime,
          isRead: true,
          quickReplies: response['quickReplies'] as List<String>?,
          navigationAction: response['action'] as Map<String, dynamic>?));
      _conversations[conversationIndex].lastMessage =
          response['text'] as String;
      _conversations[conversationIndex].time = 'Just now';
      _conversations[conversationIndex].unread = 1;
      onMessagesUpdated?.call();
    });
  }

  void _requestLiveAgent(int conversationIndex) async {
    _waitingForAgent = true;
    final replyTime =
        '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}';
    await AdminService().createLiveChatRequest();
    _conversations[conversationIndex].messages.add(ChatMessage(
        text:
            "🎧 You're in the live agent queue!\n\n• Agent joins shortly\n• Avg wait: 3-5 min\n• Agent sees our chat\n\nThanks for your patience! 🙏",
        isMe: false,
        time: replyTime,
        isRead: true,
        quickReplies: ['⏳ Keep Waiting', '🏠 Back to Menu']));
    _conversations[conversationIndex].lastMessage =
        "Connected to live agent queue...";
    _conversations[conversationIndex].time = 'Just now';
    _conversations[conversationIndex].unread = 1;
    onMessagesUpdated?.call();
    _agentWaitTimer?.cancel();
    _agentWaitTimer = Timer(const Duration(minutes: 5), () {
      if (_waitingForAgent) _showAgentTimeoutOptions(conversationIndex);
    });
  }

  void _showAgentTimeoutOptions(int conversationIndex) {
    _agentWaitTimer?.cancel();
    final timeoutReplyTime =
        '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}';
    _conversations[conversationIndex].messages.add(ChatMessage(
            text:
                "⏱️ No agent is available right now.\n\n**Try these alternatives:**\n\n📞 **Call**: +234 800 GEESTRIP (24/7)\n📧 **Email**: support@geestrip.com\n💬 **WhatsApp**: Chat with us instantly\n\nOr I can keep trying to find an agent for you.",
            isMe: false,
            time: timeoutReplyTime,
            isRead: true,
            quickReplies: [
              '📞 Call Now',
              '📧 Email Support',
              '💬 WhatsApp',
              '⏳ Keep Trying (5 min)',
              '🏠 Back to Menu'
            ]));
    _conversations[conversationIndex].lastMessage =
        "No agent available - showing alternatives";
    _conversations[conversationIndex].time = 'Just now';
    _conversations[conversationIndex].unread = 1;
    onMessagesUpdated?.call();
  }

  void handleTimeoutQuickReply(int conversationIndex, String reply) {
    if (reply.contains('Keep Trying') || reply.contains('⏳')) {
      _requestLiveAgent(conversationIndex);
      return;
    }
    final replyTime =
        '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}';
    String msg = '';
    if (reply.contains('Call Now') || reply.contains('📞')) {
      msg =
          "📞 Reach us at:\n\n**+234 800 GEESTRIP**\n\n24/7 phone support available.";
    } else if (reply.contains('Email') || reply.contains('📧')) {
      msg =
          "📧 Email us at:\n\n**support@geestrip.com**\n\nWe'll respond within 2 hours.";
    } else if (reply.contains('WhatsApp') || reply.contains('💬')) {
      msg =
          "💬 WhatsApp us:\n\n**+234 800 GEESTRIP**\n\nMessage us for instant chat support!";
    }
    if (msg.isNotEmpty) {
      _conversations[conversationIndex].messages.add(ChatMessage(
          text: msg,
          isMe: false,
          time: replyTime,
          isRead: true,
          quickReplies: ['🏠 Back to Menu']));
      _conversations[conversationIndex].lastMessage = msg;
      _conversations[conversationIndex].time = 'Just now';
      _conversations[conversationIndex].unread = 1;
      _waitingForAgent = false;
      _agentConnected = false;
      _agentWaitTimer?.cancel();
      onMessagesUpdated?.call();
    }
  }

  void agentJoined(int conversationIndex, String agentName) {
    _waitingForAgent = false;
    _agentConnected = true;
    _agentWaitTimer?.cancel();
    final replyTime =
        '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}';
    _conversations[conversationIndex].name = agentName;
    _conversations[conversationIndex].messages.add(ChatMessage(
        text:
            "👋 **$agentName has joined!**\n\nThey can see our history and are ready to help.",
        isMe: false,
        time: replyTime,
        isRead: true,
        quickReplies: ['🏠 Back to Menu']));
    _conversations[conversationIndex].lastMessage =
        "$agentName joined the chat";
    _conversations[conversationIndex].time = 'Just now';
    _conversations[conversationIndex].unread = 1;
    onMessagesUpdated?.call();
  }

  Map<String, dynamic> _getSmartResponse(String message) {
    final lower = message.toLowerCase();
    // Try to detect structured hotel/service queries from a single message
    final hotelParsed = _parseHotelQuery(message);
    if (hotelParsed.isNotEmpty &&
        _containsAny(lower, ['hotel', 'stay', 'room', 'lodge'])) {
      return {
        'text': "Got it — searching for hotels matching your request.",
        'quickReplies': ['Refine Search', '🏠 Back to Menu'],
        'action': {'route': '/results', 'extra': hotelParsed}
      };
    }
    if (_containsAny(lower, [
      'hi',
      'hello',
      'hey',
      'good morning',
      'good evening',
      'good afternoon'
    ])) {
      return {
        'text': _getGreeting(),
        'quickReplies': [
          '🏨 Find Hotels',
          '✈️ Book Flight',
          '🚗 Shuttle',
          '🗺️ Tours',
          '🍽️ Dining',
          '🤝 Companion'
        ]
      };
    }
    if (_containsAny(lower, ['hotel', 'stay', 'room', 'lodge'])) {
      return {
        'text': "Great! Let's find you the perfect place to stay. 🏨",
        'quickReplies': ['🔍 Start Hotel Search', '🏠 Back to Menu'],
        'action': {'route': '/concierge', 'extra': 'stay'}
      };
    }
    if (_containsAny(
        lower, ['flight', 'fly', 'plane', 'airline', 'ticket', 'airport'])) {
      return {
        'text': "Let's get you flying! ✈️",
        'quickReplies': ['🔍 Search Flights', '🏠 Back to Menu'],
        'action': {
          'route': '/service-chat',
          'extra': {'type': 'flights', 'name': 'Flight Booking'}
        }
      };
    }
    if (_containsAny(
        lower, ['shuttle', 'ride', 'taxi', 'transport', 'uber', 'bolt'])) {
      return {
        'text': "Need a ride? 🚗",
        'quickReplies': [
          '🛫 Airport Pickup',
          '🏙️ City Transfer',
          '🏠 Back to Menu'
        ],
        'action': {
          'route': '/service-chat',
          'extra': {'type': 'shuttle', 'name': 'Shuttle Service'}
        }
      };
    }
    if (_containsAny(
        lower, ['tour', 'explore', 'sightseeing', 'guide', 'museum'])) {
      return {
        'text': "Ready to explore? 🗺️",
        'quickReplies': [
          '🏛️ Heritage Tour',
          '🍜 Food Tour',
          '🏠 Back to Menu'
        ],
        'action': {
          'route': '/service-chat',
          'extra': {'type': 'tours', 'name': 'City Tours'}
        }
      };
    }
    if (_containsAny(lower, ['companion', 'date', 'buddy'])) {
      return {
        'text': "I can help find a companion. 🤝",
        'quickReplies': [
          '💼 Event Companion',
          '🍽️ Dinner Date',
          '🏠 Back to Menu'
        ],
        'action': {
          'route': '/service-chat',
          'extra': {'type': 'companion', 'name': 'Travel Companion'}
        }
      };
    }
    if (_containsAny(
        lower, ['dining', 'restaurant', 'food', 'cuisine', 'hungry'])) {
      return {
        'text': "Let's book a dining experience! 🍽️",
        'quickReplies': ['🍝 Italian', '🍣 Japanese', '🏠 Back to Menu'],
        'action': {
          'route': '/service-chat',
          'extra': {'type': 'dining', 'name': 'Dining Reservations'}
        }
      };
    }
    if (_containsAny(
        lower, ['help', 'emergency', 'urgent', 'stuck', 'unsafe'])) {
      return {
        'text': "I'm here for you! 🛡️",
        'quickReplies': [
          '🎧 Talk to Live Agent',
          '🛡️ Emergency Help',
          '📞 Call Us',
          '🏠 Back to Menu'
        ],
        'action': {'route': '/safe-stay'}
      };
    }
    if (_containsAny(lower, ['booking', 'cancel', 'refund', 'reservation'])) {
      return {
        'text': "Manage your bookings! 📋",
        'quickReplies': [
          '📋 View My Bookings',
          '❌ Cancel Booking',
          '🏠 Back to Menu'
        ],
        'action': {'route': '/my-bookings'}
      };
    }
    if (_containsAny(lower, ['partner', 'host', 'rent out'])) {
      return {
        'text': "Partner with GeesTrip! 🏢",
        'quickReplies': ['📝 Register Now', '🏠 Back to Menu'],
        'action': {'route': '/partner-register'}
      };
    }
    if (_containsAny(
        lower, ['profile', 'account', 'settings', 'language', 'payment'])) {
      return {
        'text': "Manage your account from Profile! 👤",
        'quickReplies': [
          '👤 My Profile',
          '💳 Payment Methods',
          '🌐 Language',
          '🏠 Back to Menu'
        ],
        'action': {'route': '/profile'}
      };
    }
    if (_containsAny(lower, ['explore', 'browse', 'see all'])) {
      return {
        'text': "Let's explore! 🔍",
        'quickReplies': [
          '🏨 Hotels',
          '🏢 Apartments',
          '🏖️ Resorts',
          '🏠 Back to Menu'
        ],
        'action': {'route': '/explore'}
      };
    }
    if (_containsAny(lower, ['price', 'cost', 'budget', 'discount'])) {
      return {
        'text': "Prices vary by location and season. 💰",
        'quickReplies': [
          '💰 Under \$100',
          '💵 \$100-\$300',
          '💎 \$300+',
          '🏠 Back to Menu'
        ]
      };
    }
    if (_containsAny(lower, ['thank', 'thanks', 'appreciate', 'great'])) {
      return {
        'text': "You're welcome! 😊",
        'quickReplies': [
          '🏨 Find Hotels',
          '✈️ Book Flight',
          '🚗 Shuttle',
          '🏠 Back to Menu'
        ]
      };
    }
    return {
      'text': "Here are the most popular things I can help with:",
      'quickReplies': [
        '🏨 Find Hotels',
        '✈️ Book Flight',
        '🚗 Shuttle',
        '🗺️ Tours',
        '🍽️ Dining',
        '🛡️ Help'
      ]
    };
  }

  bool _containsAny(String text, List<String> keywords) =>
      keywords.any((k) => text.contains(k));

  String _getGreeting() {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';
    return "$greeting! 👋\n\nI'm your GeesTrip virtual assistant. I can help with:\n\n🏨 Hotels\n✈️ Flights\n🚗 Shuttles\n🗺️ Tours\n🍽️ Dining\n🤝 Companions\n\nTap below or tell me what you need!";
  }

  // Very small heuristic parser to extract destination, budget and amenities from
  // a single user message like "I need a hotel in Abuja with a pool, under ₦50k".
  Map<String, String> _parseHotelQuery(String text) {
    final res = <String, String>{};
    final lower = text.toLowerCase();

    // Destination: look for 'in <city>' or 'at <city>' patterns
    final inMatch = RegExp(r'\b(?:in|at)\s+([A-Za-z ]{2,30})').firstMatch(text);
    if (inMatch != null) {
      res['destination'] = inMatch.group(1)!.trim();
    }

    // Budget: look for patterns like 'under 50k', 'under ₦50k', '50k', '$120'
    final budgetMatch =
        RegExp(r'under\s*\D*([0-9]{1,6})k?', caseSensitive: false)
                .firstMatch(lower) ??
            RegExp(r'\b(?:\$|₦)?\s*([0-9]{2,6})k?\b', caseSensitive: false)
                .firstMatch(lower);
    if (budgetMatch != null) {
      var raw = budgetMatch.group(1) ?? '';
      if (raw.isNotEmpty) {
        var value = int.tryParse(raw) ?? 0;
        // if pattern used 'k' assume thousands when original had k
        if (lower.contains('${raw}k')) value = value * 1000;
        res['budget'] = value.toString();
      }
    }

    // Amenities: check for common keywords
    final amenities = <String>[];
    final amenKeywords = [
      'pool',
      'wifi',
      'gym',
      'spa',
      'airport',
      'shuttle',
      'breakfast',
      'restaurant',
      'parking'
    ];
    for (final k in amenKeywords) {
      if (lower.contains(k)) amenities.add(k);
    }
    if (amenities.isNotEmpty) res['amenities'] = amenities.join(', ');

    return res;
  }

  String _formatTime(String? dateString) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString);
      final diff = DateTime.now().difference(date);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (e) {
      return '';
    }
  }
}
