import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_theme.dart';

class ConciergeChatScreen extends StatefulWidget {
  final String intent;
  const ConciergeChatScreen({super.key, required this.intent});

  @override
  State<ConciergeChatScreen> createState() => _ConciergeChatScreenState();
}

class _ConciergeChatScreenState extends State<ConciergeChatScreen> {
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
    switch (widget.intent) {
      case 'stay':
        return "Let's find you the perfect place to rest your head. I'll ask a few quick questions to narrow down the best options for you. 🏨";
      case 'business':
        return "Business trip — I'll make sure everything runs like clockwork. Let me understand your work needs first. 💼";
      case 'special':
        return "A special occasion deserves something extraordinary! Tell me what you're celebrating and let's make magic happen. ✨";
      case 'overwhelmed':
        return "I hear you. Travel stress is real. Take a deep breath — I'm going to take care of everything for you. Just answer a few questions and I'll handle the rest. 🤝";
      default:
        return "Let's find you the perfect stay. I'll ask a few quick questions.";
    }
  }

  String get _buddyName {
    switch (widget.intent) {
      case 'stay':
        return 'StayBuddy';
      case 'business':
        return 'BizBuddy';
      case 'special':
        return 'MagicBuddy';
      case 'overwhelmed':
        return 'HelpBuddy';
      default:
        return 'StayBuddy';
    }
  }

  String get _buddyInitial {
    switch (widget.intent) {
      case 'stay':
        return 'S';
      case 'business':
        return 'B';
      case 'special':
        return 'M';
      case 'overwhelmed':
        return 'H';
      default:
        return 'S';
    }
  }

  IconData get _buddyIcon {
    switch (widget.intent) {
      case 'stay':
        return LucideIcons.building2;
      case 'business':
        return LucideIcons.briefcase;
      case 'special':
        return LucideIcons.gift;
      case 'overwhelmed':
        return LucideIcons.heart;
      default:
        return LucideIcons.sparkles;
    }
  }

  @override
  void initState() {
    super.initState();
    _questions = _getQuestionsForIntent(widget.intent);
    _addAppMessage(_greeting);
    Future.delayed(800.ms, () {
      if (mounted) {
        _addAppMessage(_questions[0]['question']);
        _setTyping(false);
      }
    });
  }

  List<Map<String, dynamic>> _getQuestionsForIntent(String intent) {
    switch (intent) {
      case 'stay':
        return [
          {
            'question': 'Where would you like to stay?',
            'hint': 'City, neighborhood, or landmark...',
            'icon': LucideIcons.mapPin,
            'key': 'destination'
          },
          {
            'question': 'What dates are you looking at?',
            'hint': 'e.g., Dec 15 - Dec 20...',
            'icon': LucideIcons.calendar,
            'key': 'dates'
          },
          {
            'question': "What's your budget per night?",
            'hint': 'e.g., Under \$150...',
            'icon': LucideIcons.dollarSign,
            'key': 'budget'
          },
          {
            'question': 'Any must-have amenities?',
            'hint': 'Pool, gym, quiet floor, free breakfast...',
            'icon': LucideIcons.sparkles,
            'key': 'amenities'
          },
          {
            'question': 'Any special preferences or notes for me?',
            'hint': 'High floor, garden view, near elevator...',
            'icon': LucideIcons.heart,
            'key': 'notes',
            'isLast': true
          },
        ];
      case 'business':
        return [
          {
            'question': 'Which city is your business trip to?',
            'hint': 'City name...',
            'icon': LucideIcons.mapPin,
            'key': 'destination'
          },
          {
            'question': 'What are your travel dates?',
            'hint': 'Check-in to check-out...',
            'icon': LucideIcons.calendar,
            'key': 'dates'
          },
          {
            'question': 'Do you need workspace in your room?',
            'hint': 'Yes, a proper desk / No, just the basics...',
            'icon': LucideIcons.monitor,
            'key': 'workspace'
          },
          {
            'question': 'Early check-in or late checkout needed?',
            'hint': 'Tell me your flight times...',
            'icon': LucideIcons.clock,
            'key': 'checkTimes'
          },
          {
            'question': 'Any other business requirements?',
            'hint': 'Meeting room, airport transfer, printing...',
            'icon': LucideIcons.briefcase,
            'key': 'notes',
            'isLast': true
          },
        ];
      case 'special':
        return [
          {
            'question': "What's the occasion? 🎉",
            'hint': 'Anniversary, birthday, proposal, honeymoon...',
            'icon': LucideIcons.gift,
            'key': 'occasion'
          },
          {
            'question': 'Where would you like to celebrate?',
            'hint': 'City or specific area...',
            'icon': LucideIcons.mapPin,
            'key': 'destination'
          },
          {
            'question': 'What dates are you planning for?',
            'hint': 'e.g., Feb 14 - Feb 16...',
            'icon': LucideIcons.calendar,
            'key': 'dates'
          },
          {
            'question': "What's your budget for this special stay?",
            'hint': 'e.g., \$200-\$400 per night...',
            'icon': LucideIcons.dollarSign,
            'key': 'budget'
          },
          {
            'question': 'Any surprises or special arrangements needed?',
            'hint':
                'Flowers, champagne, dinner reservation, room decoration...',
            'icon': LucideIcons.heart,
            'key': 'notes',
            'isLast': true
          },
        ];
      case 'overwhelmed':
        return [
          {
            'question': 'What happened? Tell me everything.',
            'hint': 'Bad experience, cancelled booking, safety concern...',
            'icon': LucideIcons.messageCircle,
            'key': 'issue'
          },
          {
            'question': 'Where are you now or where do you need to be?',
            'hint': 'Current location or destination...',
            'icon': LucideIcons.mapPin,
            'key': 'destination'
          },
          {
            'question': 'What do you need most right now?',
            'hint': 'Immediate relocation, refund help, safe place...',
            'icon': LucideIcons.heart,
            'key': 'need'
          },
          {
            'question': "What's your immediate budget for a solution?",
            'hint': 'e.g., Up to \$200...',
            'icon': LucideIcons.dollarSign,
            'key': 'budget'
          },
          {
            'question': 'Phone number or best way to reach you quickly?',
            'hint': 'Your phone number or WhatsApp...',
            'icon': LucideIcons.phone,
            'key': 'contact',
            'isLast': true
          },
        ];
      default:
        return _getQuestionsForIntent('stay');
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

  void _setTyping(bool typing) {
    setState(() => _isTyping = typing);
  }

  void _scrollDown() {
    Future.delayed(100.ms, () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: 300.ms,
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _handleSend() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    if (_editingIndex != null && _editingIndex! >= 0 && _editingIndex! < _questions.length) {
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

    if (_step < 0 || _step >= _questions.length) {
      _step = 0;
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
            "Here's a summary of what you've told me. Please review and confirm, or tap any field to edit it. 👇");
        setState(() => _showReviewCard = true);
      }
      _setTyping(false);
    });
  }

  void _startEditing(int index) {
    if (index < 0 || index >= _questions.length) return;

    setState(() {
      _editingIndex = index;
      _showReviewCard = false;
    });
    final question = _questions[index];
    _addAppMessage(
        "Let's update your ${question['key']}. ${question['question']}");
    _inputController.text = _answers[question['key']] ?? '';
    _inputFocus.requestFocus();
    _scrollDown();
  }

  void _confirmAndSearch() {
    setState(() => _showReviewCard = false);
    _addAppMessage(_getClosingMessage());
    Future.delayed(1.5.seconds, () {
      if (mounted) {
        context.push('/results', extra: _answers);
      }
    });
  }

  String _getClosingMessage() {
    switch (widget.intent) {
      case 'stay':
        return "Perfect! I've got everything I need. Let me show you the best options in ${_answers['destination']} that match your preferences. One moment... 🔍✨";
      case 'business':
        return "Got it! Finding business-ready hotels in ${_answers['destination']} with everything you need for a productive trip. Searching now... 💼";
      case 'special':
        return "Wonderful! Let me find the most romantic and memorable stays for your ${_answers['occasion']}. I'll make sure it's unforgettable. Searching now... 💝";
      case 'overwhelmed':
        return "I've got all the details. Stay calm — I'm personally working on this right now. If it's urgent, I'll call you at ${_answers['contact']} within 15 minutes. Help is on the way. 🛡️";
      default:
        return "Perfect! Let me show you the best options. One moment... ✨";
    }
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
                      index == _messages.length + (_isTyping ? 1 : 0)) {
                    return _buildReviewCard();
                  }
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
              offset: const Offset(0, 6)),
        ],
        border:
            Border.all(color: AppColors.primary.withOpacity(0.15), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFF1F3BB3), Color(0xFF3B5CF6)]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(LucideIcons.clipboardCheck,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Your Trip Summary',
                        style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                    Text('Tap any field to edit it',
                        style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.accentGreenLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.shieldCheck,
                        color: AppColors.success, size: 13),
                    const SizedBox(width: 4),
                    Text(_buddyName,
                        style: const TextStyle(
                            color: AppColors.success,
                            fontSize: 11,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ..._questions.asMap().entries.map((entry) {
            final index = entry.key;
            final question = entry.value;
            final answer = _answers[question['key']] ?? 'Not provided';
            final icon = question['icon'] as IconData;
            final label = _getFieldLabel(question['key']);

            return GestureDetector(
              onTap: () => _startEditing(index),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.bgPrimary,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.black.withOpacity(0.04)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, color: AppColors.primary, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(label,
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textMuted,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text(answer,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary)),
                        ],
                      ),
                    ),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(LucideIcons.pencil,
                          color: AppColors.primary, size: 14),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 300.ms, delay: (50 * index).ms);
          }),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).moveY(begin: 15);
  }

  String _getFieldLabel(String key) {
    switch (key) {
      case 'destination':
        return 'DESTINATION';
      case 'dates':
        return 'DATES';
      case 'budget':
        return 'BUDGET';
      case 'amenities':
        return 'AMENITIES';
      case 'notes':
        return 'SPECIAL NOTES';
      case 'workspace':
        return 'WORKSPACE NEEDED';
      case 'checkTimes':
        return 'CHECK-IN / CHECKOUT';
      case 'occasion':
        return 'OCCASION';
      case 'issue':
        return 'ISSUE';
      case 'need':
        return 'WHAT YOU NEED';
      case 'contact':
        return 'CONTACT';
      default:
        return key.toUpperCase();
    }
  }

  Widget _buildReviewButtons() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, -2))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => _showReviewCard = false);
                _addAppMessage('No problem! What would you like to change?');
                _addAppMessage(_questions[0]['question']);
                _step = 0;
                _inputFocus.requestFocus();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: AppColors.bgPrimary,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.black.withOpacity(0.06)),
                ),
                child: const Center(
                  child: Text('Edit All',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: _confirmAndSearch,
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
                  ],
                ),
                child: const Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Looks Good — Search',
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                      SizedBox(width: 6),
                      Icon(LucideIcons.search, color: Colors.white, size: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    String title;
    String subtitle;
    switch (widget.intent) {
      case 'stay':
        title = 'Find a Place to Stay';
        subtitle = 'Hotel Concierge';
        break;
      case 'business':
        title = 'Business Travel';
        subtitle = 'Corporate Concierge';
        break;
      case 'special':
        title = 'Special Occasion';
        subtitle = 'Celebration Concierge';
        break;
      case 'overwhelmed':
        title = 'Emergency Help';
        subtitle = 'Priority Support';
        break;
      default:
        title = 'Concierge';
        subtitle = 'Online now';
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2))
        ],
      ),
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
                  size: 22, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF1F3BB3), Color(0xFF3B5CF6)]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_buddyIcon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                Row(
                  children: [
                    const PulseDot(size: 7),
                    const SizedBox(width: 5),
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.success,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
                color: AppColors.accentGreenLight,
                borderRadius: BorderRadius.circular(10)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(LucideIcons.shieldCheck,
                    color: AppColors.success, size: 14),
                const SizedBox(width: 4),
                Text(_buddyName,
                    style: const TextStyle(
                        color: AppColors.success,
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
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
    if (_showReviewCard) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, -2))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.bgPrimary,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black.withOpacity(0.06)),
              ),
              child: TextField(
                controller: _inputController,
                focusNode: _inputFocus,
                style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: _editingIndex != null
                      ? 'Enter new ${_questions[_editingIndex!]['key']}...'
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
                ],
              ),
              child: Icon(
                  _editingIndex != null ? LucideIcons.check : LucideIcons.send,
                  color: Colors.white,
                  size: 22),
            ),
          ),
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
          if (!message.isUser) ...[
            Container(
              width: 36,
              height: 36,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF1F3BB3), Color(0xFF3B5CF6)]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                  child: Text(_buddyInitial,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700))),
            ),
          ],
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
                      : const Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: (message.isUser ? AppColors.primary : Colors.black)
                        .withOpacity(message.isUser ? 0.2 : 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser ? Colors.white : AppColors.textPrimary,
                  fontSize: 17,
                  fontWeight:
                      message.isUser ? FontWeight.w600 : FontWeight.w500,
                  height: 1.5,
                ),
              ),
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
                  color: AppColors.primary, size: 20),
            ),
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
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
                child: Text(_buddyInitial,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700))),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.bgWhite,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
                bottomLeft: Radius.circular(6),
              ),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3))
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _TypingDot(delay: 0),
                const SizedBox(width: 5),
                _TypingDot(delay: 200),
                const SizedBox(width: 5),
                _TypingDot(delay: 400),
              ],
            ),
          ),
        ],
      ).animate().fadeIn(duration: 200.ms),
    );
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
      builder: (context, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.textMuted
                .withOpacity(0.3 + (_controller.value * 0.7)),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}
