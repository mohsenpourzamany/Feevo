import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/providers/live_room_provider.dart';

class LiveRoomInsideScreen extends StatefulWidget {
  final String roomId;
  const LiveRoomInsideScreen({super.key, required this.roomId});
  @override
  State<LiveRoomInsideScreen> createState() => _LiveRoomInsideScreenState();
}

class _LiveRoomInsideScreenState extends State<LiveRoomInsideScreen> with TickerProviderStateMixin {
  bool _chatOpen   = true;
  bool _isLiked    = false;
  final _chatCtrl  = TextEditingController();
  final _scrollCtrl = ScrollController();

  late AnimationController _catController, _waveController, _pulseController;
  late Animation<double> _catFloat, _pulse;

  @override
  void initState() {
    super.initState();
    _catController  = AnimationController(vsync: this, duration: const Duration(milliseconds: 2500))..repeat(reverse: true);
    _catFloat       = Tween<double>(begin: 0, end: -8).animate(CurvedAnimation(parent: _catController, curve: Curves.easeInOut));
    _waveController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
    _pulse          = Tween<double>(begin: 0.96, end: 1.04).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LiveRoomProvider>().joinRoom(widget.roomId);
    });
  }

  @override
  void dispose() {
    _chatCtrl.dispose();
    _scrollCtrl.dispose();
    _catController.dispose();
    _waveController.dispose();
    _pulseController.dispose();
    context.read<LiveRoomProvider>().leaveRoom();
    super.dispose();
  }

  void _shareRoom(LiveRoom? room) {
    if (room == null) return;
    Share.share(
      '🎵 Join me in "${room.name}" on Feevo!\n\nListen together live 🔴\n\nfeevo://live-room?id=${room.id}\n\nDownload Feevo: https://feevo.music',
      subject: 'Join ${room.name} on Feevo',
    );
  }

  void _sendMessage() {
    if (_chatCtrl.text.trim().isEmpty) return;
    context.read<LiveRoomProvider>().sendMessage(_chatCtrl.text.trim());
    _chatCtrl.clear();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    });
  }

  void _sendReaction(String emoji) {
    context.read<LiveRoomProvider>().sendMessage(emoji);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LiveRoomProvider>(
      builder: (context, provider, _) {
        final room     = provider.currentRoom;
        final messages = provider.messages;

        return Scaffold(
          backgroundColor: const Color(0xFF06050F),
          resizeToAvoidBottomInset: true,
          body: Stack(children: [
            Positioned.fill(child: Container(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF0A0620), Color(0xFF06050F)])))),
            Positioned(top: -100, left: -80, child: AnimatedBuilder(animation: _pulse, builder: (_, __) => Transform.scale(scale: _pulse.value, child: Container(width: 380, height: 380, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [AppColors.purple.withOpacity(0.2), AppColors.purple.withOpacity(0)])))))),

            SafeArea(
              child: Column(children: [
                // top bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: Row(children: [
                    _LiveBadge(),
                    const SizedBox(width: 10),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(room?.name ?? 'Loading...', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary), overflow: TextOverflow.ellipsis),
                      Text('by ${room?.hostName ?? ''} · ${room?.listenerCount ?? 0} listeners', style: const TextStyle(fontSize: 10, color: AppColors.textSecond)),
                    ])),
                    GestureDetector(
                      onTap: () => _shareRoom(room),
                      child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(999)), child: const Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.share_outlined, color: Colors.white, size: 12),
                        SizedBox(width: 4),
                        Text('Invite', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white)),
                      ])),
                    ),
                    GestureDetector(
                      onTap: () { provider.leaveRoom(); context.pop(); },
                      child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7), decoration: BoxDecoration(color: AppColors.errorBg, borderRadius: BorderRadius.circular(999), border: Border.all(color: AppColors.error.withOpacity(0.3))), child: const Text('Leave', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.error))),
                    ),
                  ]),
                ),

                // AI DJ card
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.purple.withOpacity(0.2), AppColors.cyan.withOpacity(0.08)]), borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.border2)),
                    child: Row(children: [
                      AnimatedBuilder(animation: _catController, builder: (_, __) => Transform.translate(offset: Offset(0, _catFloat.value), child: Image.asset(AppConstants.cat1, width: 64, height: 64, fit: BoxFit.contain))),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('🤖 AI DJ', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.cyan2, letterSpacing: 2)),
                        const SizedBox(height: 2),
                        Text(room?.currentTrack ?? 'Curating your music...', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary), overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 6),
                        Container(height: 3, decoration: BoxDecoration(color: AppColors.surface2, borderRadius: BorderRadius.circular(999)), child: FractionallySizedBox(widthFactor: 0.45, alignment: Alignment.centerLeft, child: Container(decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(999))))),
                      ])),
                    ]),
                  ),
                ),

                // wave
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: SizedBox(
                    height: 32,
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: List.generate(24, (i) => AnimatedBuilder(
                      animation: _waveController,
                      builder: (_, __) {
                        final t = (_waveController.value - i * 0.04).clamp(0.0, 1.0);
                        final h = 4 + 28 * (0.3 + 0.7 * (1 - (2 * t - 1).abs()));
                        return Container(width: 3, height: h, margin: const EdgeInsets.symmetric(horizontal: 1.5), decoration: BoxDecoration(borderRadius: BorderRadius.circular(3), gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [AppColors.purple.withOpacity(0.9), AppColors.cyan.withOpacity(0.7)])));
                      },
                    ))),
                  ),
                ),

                // reactions
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                    ...['🔥', '❤️', '⚡', '🎵', '🌙', '💗'].map((e) => GestureDetector(
                      onTap: () => _sendReaction(e),
                      child: Container(width: 42, height: 38, decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)), child: Center(child: Text(e, style: const TextStyle(fontSize: 18)))),
                    )),
                    GestureDetector(
                      onTap: () => setState(() => _chatOpen = !_chatOpen),
                      child: Container(width: 42, height: 38, decoration: BoxDecoration(gradient: _chatOpen ? AppColors.primaryGradient : null, color: _chatOpen ? null : AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: _chatOpen ? AppColors.purple2 : AppColors.border)), child: Icon(Icons.chat_bubble_outline_rounded, color: _chatOpen ? Colors.white : AppColors.textThird, size: 18)),
                    ),
                  ]),
                ),

                const SizedBox(height: 8),

                // chat
                if (_chatOpen)
                  Expanded(child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
                    child: messages.isEmpty
                        ? const Center(child: Text('Be the first to say something! 👋', style: TextStyle(fontSize: 12, color: AppColors.textSecond)))
                        : ListView.builder(
                            controller: _scrollCtrl,
                            padding: const EdgeInsets.all(10),
                            itemCount: messages.length,
                            itemBuilder: (context, i) {
                              final msg  = messages[i];
                              final isMe = msg.isMe;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    if (!isMe) ...[
                                      Container(width: 24, height: 24, decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AppColors.primaryGradient), child: const Center(child: Text('🎵', style: TextStyle(fontSize: 12)))),
                                      const SizedBox(width: 6),
                                    ],
                                    Flexible(child: Column(crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start, children: [
                                      if (!isMe) Text(msg.username, style: const TextStyle(fontSize: 9, color: AppColors.purple3, fontWeight: FontWeight.w600)),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(gradient: isMe ? AppColors.primaryGradient : null, color: isMe ? null : AppColors.surface2, borderRadius: BorderRadius.only(topLeft: const Radius.circular(12), topRight: const Radius.circular(12), bottomLeft: Radius.circular(isMe ? 12 : 2), bottomRight: Radius.circular(isMe ? 2 : 12))),
                                        child: Text(msg.message, style: TextStyle(fontSize: 12, color: isMe ? Colors.white : AppColors.textPrimary)),
                                      ),
                                    ])),
                                  ],
                                ),
                              );
                            },
                          ),
                  ))
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: GestureDetector(onTap: () => setState(() => _chatOpen = true), child: Container(padding: const EdgeInsets.symmetric(vertical: 10), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)), child: const Center(child: Text('Tap to open chat 💬', style: TextStyle(fontSize: 12, color: AppColors.textSecond))))),
                  ),

                // chat input
                if (_chatOpen)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
                    child: Row(children: [
                      Expanded(child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(999), border: Border.all(color: AppColors.border)),
                        child: TextField(controller: _chatCtrl, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary), decoration: const InputDecoration(hintText: 'Say something...', hintStyle: TextStyle(fontSize: 12, color: AppColors.textThird), border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 12)), onSubmitted: (_) => _sendMessage()),
                      )),
                      const SizedBox(width: 8),
                      GestureDetector(onTap: _sendMessage, child: Container(width: 42, height: 42, decoration: BoxDecoration(shape: BoxShape.circle, gradient: AppColors.primaryGradient, boxShadow: [BoxShadow(color: AppColors.purple.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 3))]), child: const Icon(Icons.send_rounded, color: Colors.white, size: 18))),
                    ]),
                  ),
              ]),
            ),
          ]),
        );
      },
    );
  }
}

class _LiveBadge extends StatefulWidget {
  @override State<_LiveBadge> createState() => _LiveBadgeState();
}
class _LiveBadgeState extends State<_LiveBadge> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  @override void initState() { super.initState(); _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..repeat(reverse: true); _anim = Tween<double>(begin: 0.4, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut)); }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(color: AppColors.errorBg, borderRadius: BorderRadius.circular(999), border: Border.all(color: AppColors.error.withOpacity(0.3))),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      AnimatedBuilder(animation: _anim, builder: (_, __) => Container(width: 5, height: 5, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.error.withOpacity(_anim.value)))),
      const SizedBox(width: 4),
      const Text('LIVE', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: AppColors.error, letterSpacing: 1)),
    ]),
  );
}
