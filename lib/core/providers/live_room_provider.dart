import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LiveRoom {
  final String id;
  final String name;
  final String hostId;
  final String hostName;
  final String vibe;
  final String privacy;
  final bool aiDjEnabled;
  final bool isLive;
  final int listenerCount;
  final String? currentTrack;
  final DateTime createdAt;

  const LiveRoom({
    required this.id,
    required this.name,
    required this.hostId,
    required this.hostName,
    required this.vibe,
    required this.privacy,
    required this.aiDjEnabled,
    required this.isLive,
    required this.listenerCount,
    this.currentTrack,
    required this.createdAt,
  });

  factory LiveRoom.fromJson(Map<String, dynamic> json) => LiveRoom(
        id: json['id'],
        name: json['name'] ?? '',
        hostId: json['host_id'] ?? '',
        hostName: json['host_name'] ?? 'Unknown',
        vibe: json['vibe'] ?? 'chill',
        privacy: json['privacy'] ?? 'public',
        aiDjEnabled: json['ai_dj_enabled'] ?? true,
        isLive: json['is_live'] ?? true,
        listenerCount: json['listener_count'] ?? 0,
        currentTrack: json['current_track'],
        createdAt: DateTime.parse(json['created_at']),
      );

  String get vibeEmoji {
    switch (vibe) {
      case 'energetic':
        return '⚡';
      case 'hype':
        return '🔥';
      case 'focused':
        return '💭';
      case 'happy':
        return '💗';
      case 'jazz':
        return '🎷';
      default:
        return '🌙';
    }
  }
}

class RoomMessage {
  final String id;
  final String roomId;
  final String userId;
  final String username;
  final String message;
  final DateTime createdAt;

  const RoomMessage({
    required this.id,
    required this.roomId,
    required this.userId,
    required this.username,
    required this.message,
    required this.createdAt,
  });

  factory RoomMessage.fromJson(Map<String, dynamic> json) => RoomMessage(
        id: json['id'],
        roomId: json['room_id'],
        userId: json['user_id'],
        username: json['username'] ?? 'Anonymous',
        message: json['message'] ?? '',
        createdAt: DateTime.parse(json['created_at']),
      );

  bool get isMe => userId == Supabase.instance.client.auth.currentUser?.id;
}

class LiveRoomProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  // ── Rooms list ────────────────────────────────────────────
  List<LiveRoom> _rooms = [];
  bool _isLoadingRooms = false;
  String? _roomsError;

  List<LiveRoom> get rooms => _rooms;
  bool get isLoadingRooms => _isLoadingRooms;
  String? get roomsError => _roomsError;

  // ── Current room ──────────────────────────────────────────
  LiveRoom? _currentRoom;
  List<RoomMessage> _messages = [];
  bool _isLoadingRoom = false;
  RealtimeChannel? _roomChannel;
  RealtimeChannel? _msgChannel;

  LiveRoom? get currentRoom => _currentRoom;
  List<RoomMessage> get messages => _messages;
  bool get isLoadingRoom => _isLoadingRoom;

  // ── Fetch all rooms ───────────────────────────────────────
  Future<void> fetchRooms() async {
    _isLoadingRooms = true;
    _roomsError = null;
    notifyListeners();

    try {
      final data = await _supabase
          .from('live_rooms')
          .select()
          .eq('privacy', 'public')
          .order('listener_count', ascending: false);

      _rooms = (data as List).map((r) => LiveRoom.fromJson(r)).toList();
    } catch (e) {
      _roomsError = 'خطا در دریافت rooms';
      debugPrint('LiveRoomProvider fetchRooms error: $e');
    } finally {
      _isLoadingRooms = false;
      notifyListeners();
    }
  }

  // ── Create room ───────────────────────────────────────────
  Future<LiveRoom?> createRoom({
    required String name,
    required String vibe,
    required String privacy,
    required bool aiDjEnabled,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      final data = await _supabase
          .from('live_rooms')
          .insert({
            'name': name,
            'host_id': user.id,
            'host_name': user.email?.split('@')[0] ?? 'Host',
            'vibe': vibe,
            'privacy': privacy,
            'ai_dj_enabled': aiDjEnabled,
            'is_live': true,
            'listener_count': 0,
          })
          .select()
          .single();

      return LiveRoom.fromJson(data);
    } catch (e) {
      debugPrint('LiveRoomProvider createRoom error: $e');
      return null;
    }
  }

  // ── Join room ─────────────────────────────────────────────
  Future<void> joinRoom(String roomId) async {
    _isLoadingRoom = true;
    _messages = [];
    notifyListeners();

    try {
      // Get room info
      final roomData =
          await _supabase.from('live_rooms').select().eq('id', roomId).single();
      _currentRoom = LiveRoom.fromJson(roomData);

      // Get existing messages
      final msgData = await _supabase
          .from('room_messages')
          .select()
          .eq('room_id', roomId)
          .order('created_at')
          .limit(50);
      _messages =
          (msgData as List).map((m) => RoomMessage.fromJson(m)).toList();

      // Increment listener count
      await _supabase.rpc('increment_listener', params: {'room_id': roomId});

      // Subscribe to new messages
      _msgChannel = _supabase
          .channel('room_messages_$roomId')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'room_messages',
            filter: PostgresChangeFilter(
                type: PostgresChangeFilterType.eq,
                column: 'room_id',
                value: roomId),
            callback: (payload) {
              final msg = RoomMessage.fromJson(payload.newRecord);
              _messages.add(msg);
              notifyListeners();
            },
          )
          .subscribe();
    } catch (e) {
      debugPrint('LiveRoomProvider joinRoom error: $e');
    } finally {
      _isLoadingRoom = false;
      notifyListeners();
    }
  }

  // ── Leave room ────────────────────────────────────────────
  Future<void> leaveRoom() async {
    if (_currentRoom == null) return;
    try {
      await _supabase
          .rpc('decrement_listener', params: {'room_id': _currentRoom!.id});
      await _msgChannel?.unsubscribe();
      await _roomChannel?.unsubscribe();
      _currentRoom = null;
      _messages = [];
      notifyListeners();
    } catch (e) {
      debugPrint('LiveRoomProvider leaveRoom error: $e');
    }
  }

  // ── Send message ──────────────────────────────────────────
  Future<void> sendMessage(String text) async {
    if (_currentRoom == null || text.trim().isEmpty) return;
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      await _supabase.from('room_messages').insert({
        'room_id': _currentRoom!.id,
        'user_id': user.id,
        'username': user.email?.split('@')[0] ?? 'You',
        'message': text.trim(),
      });
    } catch (e) {
      debugPrint('LiveRoomProvider sendMessage error: $e');
    }
  }

  // ── Delete room (host only) ───────────────────────────────
  Future<void> deleteRoom(String roomId) async {
    try {
      await _supabase.from('live_rooms').delete().eq('id', roomId);
    } catch (e) {
      debugPrint('LiveRoomProvider deleteRoom error: $e');
    }
  }

  @override
  void dispose() {
    _msgChannel?.unsubscribe();
    _roomChannel?.unsubscribe();
    super.dispose();
  }
}
