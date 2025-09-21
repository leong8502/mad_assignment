import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final String otherUid;
  final String otherName;
  final String chatId;

  const ChatScreen({
    super.key,
    required this.otherUid,
    required this.otherName,
    required this.chatId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final currentUid = FirebaseAuth.instance.currentUser!.uid;
  final ScrollController _scrollController = ScrollController();

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;
    final message = _controller.text.trim();
    _controller.clear();
    final firestore = FirebaseFirestore.instance;
    try {
      final messageRef = await firestore
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .add({
        'senderId': currentUid,
        'text': message,
        'timestamp': FieldValue.serverTimestamp(),
      });
      await firestore.collection('chats').doc(widget.chatId).update({
        'lastMessage': message,
        'lastTimestamp': FieldValue.serverTimestamp(),
      });
      print('Message sent: $message, ID: ${messageRef.id}');

      // Scroll to the bottom after sending a message
      await Future.delayed(const Duration(milliseconds: 100)); // Brief delay for UI update
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } catch (e) {
      print('Error sending message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // Scroll to the bottom when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.otherName),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(widget.chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: false) // Oldest to newest
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  print('Stream error: ${snapshot.error}');
                  return const Center(child: Text('Error loading messages'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  print('No messages found for chatId: ${widget.chatId}');
                  return const Center(child: Text('No messages yet'));
                }
                final messages = snapshot.data!.docs;
                print('Messages retrieved: ${messages.length}');
                return ListView.builder(
                  controller: _scrollController, // Add scroll controller
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index].data() as Map<String, dynamic>? ?? {};
                    final isMe = msg['senderId'] == currentUid;
                    final text = msg['text'] ?? 'No text';
                    final timestamp = msg['timestamp'] as Timestamp?;
                    final timeStr = timestamp != null
                        ? DateFormat('HH:mm').format(timestamp.toDate())
                        : 'N/A';
                    print('Rendering message: $text at $timeStr');

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.green[100] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment:
                          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            Text(text),
                            const SizedBox(height: 4),
                            Text(
                              timeStr,
                              style: const TextStyle(fontSize: 10, color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.green),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}