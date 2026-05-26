import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';

class LiveRoomInsideScreen extends StatefulWidget {
  const LiveRoomInsideScreen({super.key});

  @override
  State<LiveRoomInsideScreen> createState() => _LiveRoomInsideScreenState();
}

class _LiveRoomInsideScreenState extends State<LiveRoomInsideScreen>
    with TickerProviderStateMixin {
  bool _chatOpen = true;
  bool _isLiked = false;
  final _chatCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  late AnimationController _catController;
  late AnimationController _floatController;
  late AnimationController _waveController;
  late AnimationController _pulseController;

  late Animation<double> _catFloat;
  late Animation<double> _pulse;

  final List<Map<String, dynamic>> _messages = [
    {
      'user': 'sara_m',
      'text': 'This track is 🔥🔥',
      'time': '11:41',
      'isMe': false,
      'emoji': '🎵'
    },
    {
      'user': 'dj_k',
      'text': 'Let it happen always hits!',
      'time': '11:41',
      'isMe': false,
      'emoji': '🎸'
    },
    {
      'user': 'You',
      'text': 'Love this room 🌙',
      'time': '11:42',
      'isMe': true,
      'emoji': null
    },
    {
      'user': 'music_fan',
      'text': 'Best AI DJ ever 🤖',
      'time': '11:42',
      'isMe': false,
      'emoji': '⚡'
    },
    {
      'user': 'luna_v',
      'text': '🔥🔥🔥',
      'time': '11:42',
      'isMe': false,
      'emoji': null
    },
    {
      'user': 'beats_99',
      'text': 'Anyone know this track?',
      'time': '11:43',
      'isMe': false,
      'emoji': '🎵'
    },
    {
      'user': 'You',
      'text': 'Tame Impala — Let It Happen',
      'time': '11:43',
      'isMe': true,
      'emoji': null
    },
  ];

  final List<Map<String, String>> _listeners = [
    {'emoji': '👑', 'color': '7C3AED', 'name': 'Host'},
    {'emoji': '🎵', 'color': '06B6D4', 'name': 'You'},
    {'emoji': '🎸', 'color': '9D5CF6', 'name': 'sara'},
    {'emoji': '⚡', 'color': '0891B2', 'name': 'dj_k'},
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _catController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);
    _catFloat = Tween<double>(begin: 0, end: -8).animate(
      CurvedAnimation(parent: _catController, curve: Curves.easeInOut),
    );

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _chatCtrl.dispose();
    _scrollCtrl.dispose();
    _catController.dispose();
    _floatController.dispose();
    _waveController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_chatCtrl.text.trim().isEmpty) return;
    setState(() {
      _messages.add({
        'user': 'You',
        'text': _chatCtrl.text.trim(),
        'time': '11:44',
        'isMe': true,
        'emoji': null,
      });
      _chatCtrl.clear();
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendReaction(String emoji) {
    setState(() {
      _messages.add({
        'user': 'You',
        'text': emoji,
        'time': '11:44',
        'isMe': true,
        'emoji': null,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF06050F),
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // bg gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF0A0620), Color(0xFF06050F)],
                ),
              ),
            ),
          ),

          // orb top
          Positioned(
            top: -100,
            left: -80,
            child: AnimatedBuilder(
              animation: _pulse,
              builder: (_, __) => Transform.scale(
                scale: _pulse.value,
                child: Container(
                  width: 380,
                  height: 380,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      AppColors.purple.withOpacity(0.2),
                      AppColors.purple.withOpacity(0),
                    ]),
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // ── top bar
                _buildTopBar(),

                // ── AI DJ card
                _buildAiDjCard(),

                // ── wave visualizer
                _buildWave(),

                // ── listeners row
                _buildListeners(),

                const SizedBox(height: 8),

                // ── reactions
                _buildReactions(),

                const SizedBox(height: 8),

                // ── chat area (expandable)
                if (_chatOpen)
                  Expanded(child: _buildChat())
                else
                  _buildChatToggle(),

                // ── chat input
                if (_chatOpen) _buildChatInput(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Top Bar ───────────────────────────────────────────────
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Row(
        children: [
          // live badge
          _LiveBadge(),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Late Night Chill 🌙',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'by DJ Cosmos · 241 listeners',
                  style: TextStyle(fontSize: 10, color: AppColors.textSecond),
                ),
              ],
            ),
          ),

          // like
          GestureDetector(
            onTap: () => setState(() => _isLiked = !_isLiked),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isLiked
                    ? AppColors.purple.withOpacity(0.2)
                    : AppColors.surface,
                border: Border.all(
                  color: _isLiked ? AppColors.purple2 : AppColors.border,
                ),
              ),
              child: Icon(
                _isLiked
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: _isLiked ? AppColors.purple3 : AppColors.textThird,
                size: 16,
              ),
            ),
          ),

          const SizedBox(width: 8),

          // leave button
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.errorBg,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.error.withOpacity(0.3)),
              ),
              child: const Text(
                'Leave',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── AI DJ Card ────────────────────────────────────────────
  Widget _buildAiDjCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.purple.withOpacity(0.2),
              AppColors.cyan.withOpacity(0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border2),
        ),
        child: Row(
          children: [
            // cat_1 AI DJ
            AnimatedBuilder(
              animation: _catController,
              builder: (_, __) => Transform.translate(
                offset: Offset(0, _catFloat.value),
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.purple.withOpacity(0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    AppConstants.cat1,
                    width: 64,
                    height: 64,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🤖 AI DJ',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: AppColors.cyan2,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Let It Happen',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Text(
                    'Tame Impala',
                    style: TextStyle(fontSize: 11, color: AppColors.textSecond),
                  ),
                  const SizedBox(height: 6),
                  // progress bar
                  LayoutBuilder(builder: (_, constraints) {
                    return Stack(children: [
                      Container(
                        height: 3,
                        width: constraints.maxWidth,
                        decoration: BoxDecoration(
                          color: AppColors.surface2,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      Container(
                        height: 3,
                        width: constraints.maxWidth * 0.45,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ]);
                  }),
                  const SizedBox(height: 3),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('3:32',
                          style: TextStyle(
                              fontSize: 8, color: AppColors.textThird)),
                      Text('7:47',
                          style: TextStyle(
                              fontSize: 8, color: AppColors.textThird)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Wave ──────────────────────────────────────────────────
  Widget _buildWave() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: SizedBox(
        height: 32,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(24, (i) {
            return AnimatedBuilder(
              animation: _waveController,
              builder: (_, __) {
                final delay = i * 0.04;
                final t = (_waveController.value - delay).clamp(0.0, 1.0);
                final height = 4 + 28 * (0.3 + 0.7 * (1 - (2 * t - 1).abs()));
                return Container(
                  width: 3,
                  height: height,
                  margin: const EdgeInsets.symmetric(horizontal: 1.5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        AppColors.purple.withOpacity(0.9),
                        AppColors.cyan.withOpacity(0.7),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }

  // ── Listeners ─────────────────────────────────────────────
  Widget _buildListeners() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            height: 36,
            child: Stack(
              children: List.generate(_listeners.length, (i) {
                final l = _listeners[i];
                return Positioned(
                  left: i * 22.0,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(int.parse('FF${l['color']!}', radix: 16)),
                      border:
                          Border.all(color: const Color(0xFF06050F), width: 2),
                    ),
                    child: Center(
                      child: Text(l['emoji']!,
                          style: const TextStyle(fontSize: 16)),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColors.border),
            ),
            child: const Text(
              '+237 listening',
              style: TextStyle(fontSize: 10, color: AppColors.textSecond),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.share_outlined, color: Colors.white, size: 12),
                  SizedBox(width: 4),
                  Text(
                    'Invite',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Reactions ─────────────────────────────────────────────
  Widget _buildReactions() {
    final reactions = ['🔥', '❤️', '⚡', '🎵', '🌙', '💗'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ...reactions.map((e) => GestureDetector(
                onTap: () => _sendReaction(e),
                child: Container(
                  width: 42,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Center(
                      child: Text(e, style: const TextStyle(fontSize: 18))),
                ),
              )),
          // toggle chat
          GestureDetector(
            onTap: () => setState(() => _chatOpen = !_chatOpen),
            child: Container(
              width: 42,
              height: 38,
              decoration: BoxDecoration(
                gradient: _chatOpen ? AppColors.primaryGradient : null,
                color: _chatOpen ? null : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _chatOpen ? AppColors.purple2 : AppColors.border,
                ),
              ),
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                color: _chatOpen ? Colors.white : AppColors.textThird,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Chat Toggle (when closed) ─────────────────────────────
  Widget _buildChatToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GestureDetector(
        onTap: () => setState(() => _chatOpen = true),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: const Center(
            child: Text(
              'Tap to open chat 💬',
              style: TextStyle(fontSize: 12, color: AppColors.textSecond),
            ),
          ),
        ),
      ),
    );
  }

  // ── Chat Messages ─────────────────────────────────────────
  Widget _buildChat() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: ListView.builder(
        controller: _scrollCtrl,
        padding: const EdgeInsets.all(10),
        itemCount: _messages.length,
        itemBuilder: (context, i) {
          final msg = _messages[i];
          final isMe = msg['isMe'] as bool;
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              mainAxisAlignment:
                  isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (!isMe) ...[
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.primaryGradient,
                    ),
                    child: Center(
                      child: Text(
                        msg['emoji'] as String? ?? '🎵',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                Flexible(
                  child: Column(
                    crossAxisAlignment: isMe
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      if (!isMe)
                        Text(
                          msg['user'] as String,
                          style: const TextStyle(
                            fontSize: 9,
                            color: AppColors.purple3,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: isMe ? AppColors.primaryGradient : null,
                          color: isMe ? null : AppColors.surface2,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(12),
                            topRight: const Radius.circular(12),
                            bottomLeft: Radius.circular(isMe ? 12 : 2),
                            bottomRight: Radius.circular(isMe ? 2 : 12),
                          ),
                        ),
                        child: Text(
                          msg['text'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: isMe ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Chat Input ────────────────────────────────────────────
  Widget _buildChatInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: _chatCtrl,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
                decoration: const InputDecoration(
                  hintText: 'Say something...',
                  hintStyle: TextStyle(
                    fontSize: 12,
                    color: AppColors.textThird,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.purple.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Live Badge ────────────────────────────────────────────────
class _LiveBadge extends StatefulWidget {
  @override
  State<_LiveBadge> createState() => _LiveBadgeState();
}

class _LiveBadgeState extends State<_LiveBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.errorBg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _anim,
            builder: (_, __) => Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.error.withOpacity(_anim.value),
              ),
            ),
          ),
          const SizedBox(width: 4),
          const Text(
            'LIVE',
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              color: AppColors.error,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
