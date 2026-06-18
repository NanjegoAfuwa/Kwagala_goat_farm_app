import 'dart:async';
import 'package:flutter/material.dart';
import '../Widgets/shimmer.dart';
import '../theme_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Services/api_service.dart';

class FarmChatScreen extends StatefulWidget {
  const FarmChatScreen({Key? key}) : super(key: key);
  @override
  State<FarmChatScreen> createState() => _FarmChatScreenState();
}

class _FarmChatScreenState extends State<FarmChatScreen> {
  final TextEditingController _msgCtrl = TextEditingController();
  final ScrollController _scrollCtrl  = ScrollController();

  List<ChatMessageModel> _messages = [];
  bool _isLoading  = true;
  bool _isSending  = false;
  String? _error;
  String _myUsername = '';
  Timer? _pollTimer;

  static const Color _green  = Color(0xFF2E7D32);
  static const Color _orange = Color(0xFFF57C00);

  @override
  void initState() {
    super.initState();
    _loadUsername();
    _fetchMessages();
    _pollTimer = Timer.periodic(const Duration(seconds: 6),
            (_) => _fetchMessages(silent: true));
  }

  Future<void> _loadUsername() async {
    final p = await SharedPreferences.getInstance();
    if (mounted) setState(() => _myUsername = p.getString('username') ?? '');
  }

  Future<void> _fetchMessages({bool silent = false}) async {
    if (!silent && mounted) setState(() { _isLoading = true; _error = null; });
    try {
      final msgs = await ApiService.fetchChatMessages();
      if (mounted) {
        setState(() { _messages = msgs; _isLoading = false; });
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }
    } catch (e) {
      if (mounted && !silent) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  Future<void> _sendMessage() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty || _isSending) return;
    setState(() => _isSending = true);
    _msgCtrl.clear();
    final ok = await ApiService.sendChatMessage(text);
    if (!mounted) return;
    setState(() => _isSending = false);
    if (ok) {
      await _fetchMessages(silent: true);
    } else {
      _msgCtrl.text = text;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to send. Check your connection.'),
          backgroundColor: Colors.red));
    }
  }

  void _scrollToBottom() {
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  // ── LONG PRESS OPTIONS ────────────────────────────────────────────────────────
  void _showMessageOptions(ChatMessageModel msg) {
    final isMe = msg.isMe || (_myUsername.isNotEmpty && msg.senderUsername == _myUsername);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.card(context),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40, height: 4,
              decoration: BoxDecoration(color: AppTheme.divider(context),
                  borderRadius: BorderRadius.circular(2)),
            ),
            // Message preview
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10)),
                child: Text(
                  msg.text.length > 80
                      ? '${msg.text.substring(0, 80)}...'
                      : msg.text,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
                ),
              ),
            ),
            // Convert to task — always available
            _optionTile(ctx, Icons.task_alt_rounded, _green,
                'Convert to Task', 'Add this message as a farm task',
                () => _convertToTask(msg.text)),
            // Edit — only own messages
            if (isMe)
              _optionTile(ctx, Icons.edit_rounded, _orange,
                  'Edit Message', 'Change what you wrote',
                  () => _showEditDialog(msg)),
            // Delete — only own messages
            if (isMe)
              _optionTile(ctx, Icons.delete_outline_rounded, Colors.red,
                  'Delete Message', 'Remove this message',
                  () => _deleteMessage(msg)),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _optionTile(BuildContext ctx, IconData icon, Color color,
      String title, String sub, VoidCallback action) =>
      ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title, style: const TextStyle(
            fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(sub, style: const TextStyle(fontSize: 12)),
        onTap: () { Navigator.pop(ctx); action(); },
      );

  void _convertToTask(String text) {
    final short = text.length > 60 ? '${text.substring(0, 60)}...' : text;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Creating task: "$short"'),
      backgroundColor: _green,
      behavior: SnackBarBehavior.floating,
      action: SnackBarAction(
        label: 'Confirm',
        textColor: Colors.white,
        onPressed: () async {
          final ok = await ApiService.createTask(title: text);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(ok ? '✅ Task created!' : '❌ Failed to create task'),
              backgroundColor: ok ? _green : Colors.red,
            ));
          }
        },
      ),
    ));
  }

  void _showEditDialog(ChatMessageModel msg) {
    final ctrl = TextEditingController(text: msg.text);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Edit Message',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: ctrl,
          maxLines: null,
          autofocus: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: _green, width: 1.5)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: _green, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)), elevation: 0),
            onPressed: () async {
              final newText = ctrl.text.trim();
              if (newText.isEmpty || newText == msg.text) {
                Navigator.pop(ctx);
                return;
              }
              Navigator.pop(ctx);
              // Optimistic update
              setState(() {
                final idx = _messages.indexWhere((m) => m.id == msg.id);
                if (idx != -1) {
                  _messages[idx] = ChatMessageModel(
                    id: msg.id,
                    senderUsername: msg.senderUsername,
                    text: newText,
                    createdAt: msg.createdAt,
                    isMe: msg.isMe,
                  );
                }
              });
              final ok = await ApiService.editChatMessage(msg.id, newText);
              if (!mounted) return;
              if (ok) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('✅ Message updated'),
                    backgroundColor: Color(0xFF2E7D32)));
              } else {
                // Revert on failure
                setState(() {
                  final idx = _messages.indexWhere((m) => m.id == msg.id);
                  if (idx != -1) _messages[idx] = msg;
                });
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('❌ Failed to update message'),
                    backgroundColor: Colors.red));
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteMessage(ChatMessageModel msg) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Message',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('This message will be removed from the chat.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)), elevation: 0),
            onPressed: () async {
              Navigator.pop(ctx);
              // Optimistic remove
              final removedIndex = _messages.indexWhere((m) => m.id == msg.id);
              final removed = removedIndex != -1 ? _messages[removedIndex] : null;
              setState(() => _messages.removeWhere((m) => m.id == msg.id));

              final ok = await ApiService.deleteChatMessage(msg.id);
              if (!mounted) return;
              if (ok) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('🗑️ Message deleted'),
                    backgroundColor: Colors.grey));
              } else {
                // Revert on failure
                if (removed != null && removedIndex != -1) {
                  setState(() => _messages.insert(removedIndex, removed));
                }
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('❌ Failed to delete message'),
                    backgroundColor: Colors.red));
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      body: SafeArea(
        child: Column(
          children: [
            // App bar
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
            Container(
              color: const Color(0xFF2E7D32),
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
              child: Row(children: [
                Image.asset('Assets/farm.png', height: 50, width: 50,
                    errorBuilder: (_, __, ___) => const Icon(
                        Icons.forum_rounded, color: Colors.white, size: 26)),
                const SizedBox(width: 10),
                const Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Farm Chat', style: TextStyle(color: Colors.white,
                      fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('Staff workspace', style: TextStyle(
                      color: Colors.white60, fontSize: 11)),
                ])),

                IconButton(
                  icon: const Icon(Icons.refresh_rounded,
                      color: Colors.white70, size: 20),
                  onPressed: _fetchMessages,
                ),
              ]),
            ),
            Container(color: const Color(0xFFF57C00), height: 3),
              ],
            ),

            if (_error != null)
              Container(
                color: Colors.red.shade50,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text('⚠️ Could not load messages. Pull to refresh.',
                    style: TextStyle(color: Colors.red.shade700, fontSize: 12)),
              ),

            // Messages
            Expanded(
              child: _isLoading
                  ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Align(alignment: Alignment.centerLeft,  child: Shimmer(width: 200, height: 44, borderRadius: BorderRadius.circular(14))),
                          const SizedBox(height: 10),
                          Align(alignment: Alignment.centerRight, child: Shimmer(width: 170, height: 44, borderRadius: BorderRadius.circular(14))),
                          const SizedBox(height: 10),
                          Align(alignment: Alignment.centerLeft,  child: Shimmer(width: 230, height: 44, borderRadius: BorderRadius.circular(14))),
                          const SizedBox(height: 10),
                          Align(alignment: Alignment.centerRight, child: Shimmer(width: 150, height: 44, borderRadius: BorderRadius.circular(14))),
                          const SizedBox(height: 10),
                          Align(alignment: Alignment.centerLeft,  child: Shimmer(width: 210, height: 44, borderRadius: BorderRadius.circular(14))),
                        ],
                      ),
                    )
                  : _messages.isEmpty
                      ? Center(child: Column(
                          mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.chat_bubble_outline_rounded,
                              size: 56, color: Colors.grey.shade300),
                          const SizedBox(height: 12),
                          Text('No messages yet.',
                              style: TextStyle(color: Colors.grey.shade400)),
                          const SizedBox(height: 4),
                          Text('Long-press any message for options.',
                              style: TextStyle(color: Colors.grey.shade300,
                                  fontSize: 11)),
                        ]))
                      : RefreshIndicator(
                          onRefresh: _fetchMessages,
                          color: _green,
                          child: ListView.builder(
                            controller: _scrollCtrl,
                            padding: const EdgeInsets.all(16),
                            itemCount: _messages.length,
                            itemBuilder: (_, i) {
                              final msg = _messages[i];
                              final isMe = msg.isMe ||
                                  (_myUsername.isNotEmpty &&
                                      msg.senderUsername == _myUsername);
                              return GestureDetector(
                                onLongPress: () => _showMessageOptions(msg),
                                child: _bubble(msg, isMe),
                              );
                            },
                          ),
                        ),
            ),

            // Input
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.grey.shade200))),
              child: SafeArea(
                top: false,
                child: Row(children: [
                  Expanded(
                    child: TextField(
                      controller: _msgCtrl,
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(
                            color: Colors.grey.shade400, fontSize: 14),
                        filled: true,
                        fillColor: const Color(0xFFF8F9FA),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide:
                                BorderSide(color: Colors.grey.shade200)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide:
                                BorderSide(color: Colors.grey.shade200)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(
                                color: _green, width: 1.5)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Material(
                    color: _isSending ? Colors.grey.shade400 : _green,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: _isSending ? null : _sendMessage,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: _isSending
                            ? const SizedBox(width: 20, height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : const Icon(Icons.send_rounded,
                                color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bubble(ChatMessageModel msg, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.74),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? _green : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
          border: isMe ? null : Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04),
              blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isMe)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(msg.senderUsername,
                    style: TextStyle(fontWeight: FontWeight.bold,
                        color: _orange, fontSize: 12)),
              ),
            Text(msg.text,
                style: TextStyle(
                    color: isMe ? Colors.white : const Color(0xFF0F172A),
                    fontSize: 14, height: 1.4)),
            const SizedBox(height: 3),
            Text(_fmtTime(msg.createdAt),
                style: TextStyle(fontSize: 10,
                    color: isMe ? Colors.white54 : Colors.grey.shade400)),
          ],
        ),
      ),
    );
  }

  String _fmtTime(DateTime dt) {
    final now = DateTime.now();
    final isToday = dt.year == now.year && dt.month == now.month && dt.day == now.day;
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return isToday ? '$h:$m' : '${dt.day}/${dt.month} $h:$m';
  }
}
