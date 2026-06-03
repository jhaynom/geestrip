import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_theme.dart';

class ServiceChatScreen extends StatefulWidget {
  final String serviceType;
  final String serviceName;
  const ServiceChatScreen(
      {super.key, required this.serviceType, required this.serviceName});

  @override
  State<ServiceChatScreen> createState() => _ServiceChatScreenState();
}

class _ServiceChatScreenState extends State<ServiceChatScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _inputFocus = FocusNode();
  final Map<String, String> _answers = {};

  int _step = 0;
  bool _isTyping = false;
  bool _showReviewCard = false;
  int? _editingIndex;
  List<Map<String, dynamic>> _questions = [];

  String get _greeting {
    switch (widget.serviceType) {
      case 'shuttle':
        return "Let's arrange your perfect ride. I'll ask a few quick questions to get you the best shuttle service. 🚗";
      case 'tours':
        return "Ready to explore? Tell me what you love, and I'll craft the perfect city tour for you! 🗺️";
      case 'companion':
        return "I'll help you find the perfect travel companion. First, let me understand what you're looking for. Please note: all companions are verified and professional. 🤝";
      case 'dining':
        return "Let's book you an unforgettable dining experience. What cuisine are you in the mood for? 🍽️";
      case 'flights':
        return "I'll find you the best flight deals. Let's start with your travel details. ✈️";
      default:
        return "Let me help you with that. A few quick questions first.";
    }
  }

  String get _buddyName {
    switch (widget.serviceType) {
      case 'shuttle':
        return 'RideBuddy';
      case 'tours':
        return 'TourBuddy';
      case 'companion':
        return 'CompanionBuddy';
      case 'dining':
        return 'DineBuddy';
      case 'flights':
        return 'FlyBuddy';
      default:
        return 'TravelBuddy';
    }
  }

  String get _buddyInitial {
    switch (widget.serviceType) {
      case 'shuttle':
        return 'R';
      case 'tours':
        return 'T';
      case 'companion':
        return 'C';
      case 'dining':
        return 'D';
      case 'flights':
        return 'F';
      default:
        return 'T';
    }
  }

  IconData get _buddyIcon {
    switch (widget.serviceType) {
      case 'shuttle':
        return LucideIcons.car;
      case 'tours':
        return LucideIcons.map;
      case 'companion':
        return LucideIcons.users;
      case 'dining':
        return LucideIcons.utensilsCrossed;
      case 'flights':
        return LucideIcons.plane;
      default:
        return LucideIcons.sparkles;
    }
  }

  @override
  void initState() {
    super.initState();
    _questions = _getQuestionsForService(widget.serviceType);
    _addAppMessage(_greeting);
    Future.delayed(800.ms, () {
      if (mounted) {
        _addAppMessage(_questions[0]['question']);
        _setTyping(false);
      }
    });
  }

  List<Map<String, dynamic>> _getQuestionsForService(String type) {
    switch (type) {
      case 'shuttle':
        return [
          {
            'question': 'Where should we pick you up?',
            'hint': 'Airport, hotel, specific address...',
            'icon': LucideIcons.mapPin,
            'key': 'pickup'
          },
          {
            'question': "Where are you headed?",
            'hint': 'Hotel, business district, landmark...',
            'icon': LucideIcons.mapPin,
            'key': 'dropoff'
          },
          {
            'question': 'When do you need the ride?',
            'hint': 'Date and time...',
            'icon': LucideIcons.clock,
            'key': 'datetime'
          },
          {
            'question': 'How many passengers?',
            'hint': '1-2, 3-4, 5+...',
            'icon': LucideIcons.users,
            'key': 'passengers'
          },
          {
            'question': 'Any special requirements?',
            'hint': 'Child seat, extra luggage, wheelchair access...',
            'icon': LucideIcons.sparkles,
            'key': 'notes',
            'isLast': true
          },
        ];
      case 'tours':
        return [
          {
            'question': 'Which city would you like to explore?',
            'hint': 'City name...',
            'icon': LucideIcons.mapPin,
            'key': 'city'
          },
          {
            'question': 'What interests you most?',
            'hint': 'History, food, nature, shopping, nightlife...',
            'icon': LucideIcons.heart,
            'key': 'interests'
          },
          {
            'question': 'How many people in your group?',
            'hint': 'Solo, couple, group size...',
            'icon': LucideIcons.users,
            'key': 'groupSize'
          },
          {
            'question': 'Preferred tour duration?',
            'hint': 'Half day (4hrs), Full day (8hrs)...',
            'icon': LucideIcons.clock,
            'key': 'duration'
          },
          {
            'question': 'Any specific places you want to see?',
            'hint': 'Museums, markets, landmarks...',
            'icon': LucideIcons.camera,
            'key': 'notes',
            'isLast': true
          },
        ];
      case 'companion':
        return [
          {
            'question': 'What type of companion are you looking for?',
            'hint': 'Event companion, travel buddy, dinner date...',
            'icon': LucideIcons.users,
            'key': 'type'
          },
          {
            'question': 'What occasion or event?',
            'hint': 'Business dinner, wedding, sightseeing...',
            'icon': LucideIcons.calendar,
            'key': 'occasion'
          },
          {
            'question': 'When do you need the companion?',
            'hint': 'Date and time...',
            'icon': LucideIcons.clock,
            'key': 'datetime'
          },
          {
            'question': 'Any preferences?',
            'hint': 'Languages spoken, age range, interests...',
            'icon': LucideIcons.sparkles,
            'key': 'preferences'
          },
          {
            'question': 'How long will you need the companion?',
            'hint': 'Few hours, full day, multiple days...',
            'icon': LucideIcons.hourglass,
            'key': 'duration',
            'isLast': true
          },
        ];
      case 'dining':
        return [
          {
            'question': 'Which city are you dining in?',
            'hint': 'City name...',
            'icon': LucideIcons.mapPin,
            'key': 'city'
          },
          {
            'question': 'What cuisine are you craving?',
            'hint': 'Italian, Japanese, local, fusion...',
            'icon': LucideIcons.utensilsCrossed,
            'key': 'cuisine'
          },
          {
            'question': 'When would you like to dine?',
            'hint': 'Date and time...',
            'icon': LucideIcons.clock,
            'key': 'datetime'
          },
          {
            'question': 'How many guests?',
            'hint': '2, 4, 6+...',
            'icon': LucideIcons.users,
            'key': 'guests'
          },
          {
            'question': 'Any dietary requirements?',
            'hint': 'Vegetarian, allergies, halal, special requests...',
            'icon': LucideIcons.sparkles,
            'key': 'notes',
            'isLast': true
          },
        ];
      case 'flights':
        return [
          {
            'question': 'Where are you flying from?',
            'hint': 'Departure city...',
            'icon': LucideIcons.planeTakeoff,
            'key': 'from'
          },
          {
            'question': 'Where are you flying to?',
            'hint': 'Destination city...',
            'icon': LucideIcons.planeLanding,
            'key': 'to'
          },
          {
            'question': 'When do you want to depart?',
            'hint': 'Date...',
            'icon': LucideIcons.calendar,
            'key': 'departDate'
          },
          {
            'question': 'Return date? (if round trip)',
            'hint': 'Date or "one way"...',
            'icon': LucideIcons.calendar,
            'key': 'returnDate'
          },
          {
            'question': 'How many passengers?',
            'hint': '1, 2, family...',
            'icon': LucideIcons.users,
            'key': 'passengers',
            'isLast': true
          },
        ];
      default:
        return [
          {
            'question': 'What do you need?',
            'hint': 'Tell me...',
            'icon': LucideIcons.helpCircle,
            'key': 'need'
          },
          {
            'question': 'Any details?',
            'hint': 'More info...',
            'icon': LucideIcons.sparkles,
            'key': 'details',
            'isLast': true
          },
        ];
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  void _addAppMessage(String text) {
    setState(() => _messages.add(ChatMessage(text: text, isUser: false)));
    _scrollDown();
  }

  void _addUserMessage(String text) {
    setState(() => _messages.add(ChatMessage(text: text, isUser: true)));
    _scrollDown();
  }

  void _setTyping(bool typing) => setState(() => _isTyping = typing);

  void _scrollDown() {
    Future.delayed(100.ms, () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: 300.ms, curve: Curves.easeOutCubic);
      }
    });
  }

  void _handleSend() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    if (_editingIndex != null) {
      final key = _questions[_editingIndex!]['key'];
      _answers[key] = text;
      _addUserMessage(text);
      _inputController.clear();
      _editingIndex = null;
      _setTyping(true);
      Future.delayed(600.ms, () {
        if (!mounted) return;
        _addAppMessage('Updated! Here\'s your revised summary:');
        _setTyping(false);
        setState(() => _showReviewCard = true);
        _scrollDown();
      });
      return;
    }

    _addUserMessage(text);
    _answers[_questions[_step]['key']] = text;
    _inputController.clear();
    _setTyping(true);

    Future.delayed(700.ms, () {
      if (!mounted) return;
      if (_step < _questions.length - 1) {
        _step++;
        _addAppMessage(_questions[_step]['question']);
      } else {
        _addAppMessage(
            "Here's a summary of your request. Please review and confirm, or tap any field to edit. 👇");
        setState(() => _showReviewCard = true);
      }
      _setTyping(false);
    });
  }

  void _startEditing(int index) {
    setState(() {
      _editingIndex = index;
      _showReviewCard = false;
    });
    final q = _questions[index];
    _addAppMessage("Let's update your ${q['key']}. ${q['question']}");
    _inputController.text = _answers[q['key']] ?? '';
    _inputFocus.requestFocus();
    _scrollDown();
  }

  void _confirmAndProceed() {
    setState(() => _showReviewCard = false);

    _addAppMessage(
        "Great! Before I show you available options, we require a small deposit to secure your request. This ensures serious inquiries and helps us provide the best service. 🔒");

    Future.delayed(1.2.seconds, () {
      if (mounted) {
        context.push('/service-paywall', extra: {
          'type': widget.serviceType,
          'name': widget.serviceName,
          'fee': widget.serviceType == 'companion' ? 8 : 0,
          'answers': _answers,
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildProgressBar(),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                itemCount: _messages.length +
                    (_isTyping ? 1 : 0) +
                    (_showReviewCard ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length && _isTyping)
                    return _buildTypingIndicator();
                  if (_showReviewCard &&
                      index == _messages.length + (_isTyping ? 1 : 0))
                    return _buildReviewCard();
                  return _buildMessage(_messages[index]);
                },
              ),
            ),
            if (!_showReviewCard) _buildInputBar(),
            if (_showReviewCard) _buildReviewButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(color: AppColors.bgWhite, boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2))
      ]),
      child: Row(
        children: [
          GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                      color: AppColors.bgPrimary,
                      borderRadius: BorderRadius.circular(12)),
                  child: const Icon(LucideIcons.arrowLeft,
                      size: 22, color: AppColors.textSecondary))),
          const SizedBox(width: 12),
          Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFF1F3BB3), Color(0xFF3B5CF6)]),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(_buddyIcon, color: Colors.white, size: 20)),
          const SizedBox(width: 10),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(widget.serviceName,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                Row(children: [
                  const PulseDot(size: 7),
                  const SizedBox(width: 5),
                  const Text('Online now',
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColors.success,
                          fontWeight: FontWeight.w600))
                ])
              ])),
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                  color: AppColors.accentGreenLight,
                  borderRadius: BorderRadius.circular(10)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(LucideIcons.shieldCheck,
                    color: AppColors.success, size: 14),
                const SizedBox(width: 4),
                Text(_buddyName,
                    style: const TextStyle(
                        color: AppColors.success,
                        fontSize: 12,
                        fontWeight: FontWeight.w700))
              ])),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      height: 3,
      color: AppColors.tabInactive,
      child: AnimatedContainer(
        duration: 400.ms,
        curve: Curves.easeOutCubic,
        width: MediaQuery.of(context).size.width *
            ((_step + (_isTyping ? 0.5 : 0)) / _questions.length),
        decoration: const BoxDecoration(
            gradient:
                LinearGradient(colors: [Color(0xFF1F3BB3), Color(0xFF3B5CF6)])),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(color: AppColors.bgWhite, boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, -2))
      ]),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  color: AppColors.bgPrimary,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black.withOpacity(0.06))),
              child: TextField(
                controller: _inputController,
                focusNode: _inputFocus,
                style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: _editingIndex != null
                      ? 'Enter new value...'
                      : _questions[_step]['hint'],
                  hintStyle: const TextStyle(
                      fontSize: 17,
                      color: AppColors.textPlaceholder,
                      fontWeight: FontWeight.w500),
                  prefixIcon: Icon(
                      _editingIndex != null
                          ? LucideIcons.pencil
                          : _questions[_step]['icon'],
                      color: AppColors.primary,
                      size: 22),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                ),
                onSubmitted: (_) => _handleSend(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
              onTap: _handleSend,
              child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [Color(0xFF1F3BB3), Color(0xFF3B5CF6)]),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4))
                      ]),
                  child: Icon(
                      _editingIndex != null
                          ? LucideIcons.check
                          : LucideIcons.send,
                      color: Colors.white,
                      size: 22))),
        ],
      ),
    );
  }

  Widget _buildMessage(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isUser)
            Container(
                width: 36,
                height: 36,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFF1F3BB3), Color(0xFF3B5CF6)]),
                    borderRadius: BorderRadius.circular(10)),
                child: Center(
                    child: Text(_buddyInitial,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700)))),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: message.isUser ? AppColors.primary : AppColors.bgWhite,
                borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: message.isUser
                        ? const Radius.circular(20)
                        : const Radius.circular(6),
                    bottomRight: message.isUser
                        ? const Radius.circular(6)
                        : const Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                      color: (message.isUser ? AppColors.primary : Colors.black)
                          .withOpacity(message.isUser ? 0.2 : 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3))
                ],
              ),
              child: Text(message.text,
                  style: TextStyle(
                      color:
                          message.isUser ? Colors.white : AppColors.textPrimary,
                      fontSize: 17,
                      fontWeight:
                          message.isUser ? FontWeight.w600 : FontWeight.w500,
                      height: 1.5)),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 10),
            Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(10)),
                child: const Icon(LucideIcons.user,
                    color: AppColors.primary, size: 20))
          ],
        ],
      ).animate().fadeIn(duration: 300.ms).moveY(begin: 12),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
              width: 36,
              height: 36,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFF1F3BB3), Color(0xFF3B5CF6)]),
                  borderRadius: BorderRadius.circular(10)),
              child: Center(
                  child: Text(_buddyInitial,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700)))),
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                  color: AppColors.bgWhite,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                      bottomLeft: Radius.circular(6)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 3))
                  ]),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                _TypingDot(delay: 0),
                const SizedBox(width: 5),
                _TypingDot(delay: 200),
                const SizedBox(width: 5),
                _TypingDot(delay: 400)
              ])),
        ],
      ),
    );
  }

  Widget _buildReviewCard() {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: AppColors.bgWhite,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
                color: AppColors.primary.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 6))
          ],
          border: Border.all(
              color: AppColors.primary.withOpacity(0.15), width: 1.5)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFF1F3BB3), Color(0xFF3B5CF6)]),
                    borderRadius: BorderRadius.circular(12)),
                child: const Icon(LucideIcons.clipboardCheck,
                    color: Colors.white, size: 20)),
            const SizedBox(width: 12),
            const Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text('Your Request Summary',
                      style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  Text('Tap any field to edit it',
                      style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w500))
                ])),
            Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                    color: AppColors.accentGreenLight,
                    borderRadius: BorderRadius.circular(10)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(LucideIcons.shieldCheck,
                      color: AppColors.success, size: 13),
                  const SizedBox(width: 4),
                  Text(_buddyName,
                      style: const TextStyle(
                          color: AppColors.success,
                          fontSize: 11,
                          fontWeight: FontWeight.w700))
                ]))
          ]),
          const SizedBox(height: 18),
          ..._questions.asMap().entries.map((entry) {
            final index = entry.key;
            final q = entry.value;
            final answer = _answers[q['key']] ?? 'Not provided';
            return GestureDetector(
              onTap: () => _startEditing(index),
              child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                      color: AppColors.bgPrimary,
                      borderRadius: BorderRadius.circular(14),
                      border:
                          Border.all(color: Colors.black.withOpacity(0.04))),
                  child: Row(children: [
                    Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                            color: AppColors.primarySurface,
                            borderRadius: BorderRadius.circular(10)),
                        child: Icon(q['icon'] as IconData,
                            color: AppColors.primary, size: 18)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(_getFieldLabel(q['key']),
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textMuted,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text(answer,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary))
                        ])),
                    Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8)),
                        child: const Icon(LucideIcons.pencil,
                            color: AppColors.primary, size: 14))
                  ])),
            ).animate().fadeIn(duration: 300.ms, delay: (50 * index).ms);
          }),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).moveY(begin: 15);
  }

  Widget _buildReviewButtons() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(color: AppColors.bgWhite, boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, -2))
      ]),
      child: Row(
        children: [
          Expanded(
              child: GestureDetector(
                  onTap: () {
                    setState(() => _showReviewCard = false);
                    _addAppMessage(
                        'No problem! What would you like to change?');
                    _addAppMessage(_questions[0]['question']);
                    _step = 0;
                    _inputFocus.requestFocus();
                  },
                  child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                          color: AppColors.bgPrimary,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: Colors.black.withOpacity(0.06))),
                      child: const Center(
                          child: Text('Edit All',
                              style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary)))))),
          const SizedBox(width: 12),
          Expanded(
              flex: 2,
              child: GestureDetector(
                  onTap: _confirmAndProceed,
                  child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [Color(0xFF1F3BB3), Color(0xFF3B5CF6)]),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 14,
                                offset: const Offset(0, 6))
                          ]),
                      child: const Center(
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                            Text('Confirm & Continue',
                                style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white)),
                            SizedBox(width: 6),
                            Icon(LucideIcons.chevronRight,
                                color: Colors.white, size: 20)
                          ]))))),
        ],
      ),
    );
  }

  String _getFieldLabel(String key) {
    switch (key) {
      case 'pickup':
        return 'PICKUP LOCATION';
      case 'dropoff':
        return 'DROPOFF LOCATION';
      case 'datetime':
        return 'DATE & TIME';
      case 'passengers':
        return 'PASSENGERS';
      case 'city':
        return 'CITY';
      case 'interests':
        return 'INTERESTS';
      case 'groupSize':
        return 'GROUP SIZE';
      case 'duration':
        return 'DURATION';
      case 'type':
        return 'COMPANION TYPE';
      case 'occasion':
        return 'OCCASION';
      case 'preferences':
        return 'PREFERENCES';
      case 'cuisine':
        return 'CUISINE';
      case 'guests':
        return 'NUMBER OF GUESTS';
      case 'from':
        return 'DEPARTURE CITY';
      case 'to':
        return 'DESTINATION CITY';
      case 'departDate':
        return 'DEPARTURE DATE';
      case 'returnDate':
        return 'RETURN DATE';
      case 'notes':
        return 'SPECIAL NOTES';
      default:
        return key.toUpperCase();
    }
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
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
