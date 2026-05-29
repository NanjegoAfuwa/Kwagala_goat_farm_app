import 'package:flutter/material.dart';

class FarmChatScreen extends StatefulWidget {
  const FarmChatScreen({Key? key}) : super(key: key);

  @override
  State<FarmChatScreen> createState() => _FarmChatScreenState();
}

class _FarmChatScreenState extends State<FarmChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  
  // Changed from a hardcoded const list to a dynamic modifiable local state tracking system array
  final List<Map<String, dynamic>> _messages = [
    {"sender": "Edward S.", "text": "Paddock B water troughs are looking low. Needs cleaning.", "time": "9:15 AM", "isMe": false},
    {"sender": "You", "text": "I will check #GT001 health record card metrics shortly.", "time": "9:20 AM", "isMe": true}
  ];

  // Displays an intuitive configuration options menu from the bottom layout frame context
  void _showMessageOptions(BuildContext context, int index) {
    final msg = _messages[index];
    bool isMe = msg["isMe"];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              ),
              
              // 1. ACTION: Convert to Task (Available for all structural logs)
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                  child: Icon(Icons.assignment_turned_in_rounded, color: Colors.green.shade700, size: 20),
                ),
                title: const Text("Convert to Farm Task", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Chore converted! Pinned text directly onto the task board pipeline.")),
                  );
                },
              ),
              
              // Only display Edit and Delete options if the message belongs to the current user ("You")
              if (isMe) ...[
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                
                // 2. ACTION: Edit Message
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                    child: Icon(Icons.edit_rounded, color: Colors.blue.shade700, size: 20),
                  ),
                  title: const Text("Edit Message", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  onTap: () {
                    Navigator.pop(context);
                    _showEditDialog(index, msg["text"]);
                  },
                ),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                
                // 3. ACTION: Delete Message
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                    child: Icon(Icons.delete_outline_rounded, color: Colors.red.shade700, size: 20),
                  ),
                  title: const Text("Delete Message", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _messages.removeAt(index);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Message deleted safely.")),
                    );
                  },
                ),
              ],
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  // Pops up a clean dialog overlay box to change the local string text state parameters
  void _showEditDialog(int index, String currentText) {
    final TextEditingController editController = TextEditingController(text: currentText);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Message", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          content: TextField(
            controller: editController,
            autofocus: true,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: TextStyle(color: Colors.grey.shade600)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700),
              onPressed: () {
                if (editController.text.trim().isEmpty) return;
                setState(() {
                  _messages[index]["text"] = editController.text.trim();
                });
                Navigator.pop(context);
              },
              child: const Text("Save Changes", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(title: const Text("Farm Workspace Chat"), backgroundColor: Colors.green.shade700, foregroundColor: Colors.white, elevation: 0),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                bool isMe = msg["isMe"];
                return GestureDetector(
                  // Trigger the options menu on long press instead of just a raw static snackbar
                  onLongPress: () => _showMessageOptions(context, index),
                  child: Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isMe ? Colors.green.shade700 : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: isMe ? null : Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!isMe) Text(msg["sender"], style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade800, fontSize: 12)),
                          const SizedBox(height: 4),
                          _buildFormattedMessageText(msg["text"], isMe),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(child: TextField(controller: _messageController, decoration: const InputDecoration(hintText: "Type message.....", border: InputBorder.none))),
                IconButton(icon: const Icon(Icons.send), onPressed: () {
                  if (_messageController.text.isEmpty) return;
                  setState(() => _messages.add({"sender": "You", "text": _messageController.text, "time": "Now", "isMe": true}));
                  _messageController.clear();
                })
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFormattedMessageText(String text, bool isMe) {
    if (text.contains("#")) {
      return RichText(
        text: TextSpan(
          style: TextStyle(color: isMe ? Colors.white : Colors.black, fontSize: 14),
          children: [
            const TextSpan(text: "I will check "),
            TextSpan(text: "#GT001", style: TextStyle(color: isMe ? Colors.orange.shade300 : Colors.blue, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
            const TextSpan(text: " health record card metrics shortly."),
          ],
        ),
      );
    }
    return Text(text, style: TextStyle(color: isMe ? Colors.white : Colors.black));
  }
}