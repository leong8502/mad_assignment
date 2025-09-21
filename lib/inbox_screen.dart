import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'chat_screen.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  final TextEditingController _workIdController = TextEditingController();

  @override
  void dispose() {
    _workIdController.dispose();
    super.dispose();
  }

  void _startNewChat(BuildContext context) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null || _workIdController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid workId or log in')),
      );
      return;
    }

    final otherWorkId = _workIdController.text.trim();
    final firestore = FirebaseFirestore.instance;

    try {
      final userQuery = await firestore
          .collection('users')
          .where('workId', isEqualTo: otherWorkId)
          .limit(1)
          .get();
      if (userQuery.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('WorkId not found')),
        );
        return;
      }
      final otherUid = userQuery.docs.first.id;

      final sortedMembers = [currentUser.uid, otherUid]..sort();
      final chatsQuery = await firestore
          .collection('chats')
          .where('members', isEqualTo: sortedMembers)
          .get();
      String chatId;
      if (chatsQuery.docs.isNotEmpty) {
        chatId = chatsQuery.docs.first.id;
        print('Existing chat found with ID: $chatId');
      } else {
        final newChat = await firestore.collection('chats').add({
          'members': sortedMembers,
          'lastMessage': '',
          'lastTimestamp': FieldValue.serverTimestamp(),
          'unreadCounts': {
            currentUser.uid: 0,
            otherUid: 0,
          }, // Initialize unreadCounts map
        });
        chatId = newChat.id;
        print('New chat created with ID: $chatId');
      }

      final userDoc = await firestore.collection('users').doc(otherUid).get();
      final otherName = userDoc.data()?['username'] ?? 'Unknown';

      _workIdController.clear();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            otherUid: otherUid,
            otherName: otherName,
            chatId: chatId,
          ),
        ),
      );
    } catch (e) {
      print('Error starting chat: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error starting chat: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      print('No authenticated user found at ${DateTime.now()}');
      return const Center(child: Text('Not logged in'));
    }
    final currentUid = currentUser.uid; // Define currentUid locally

    print('Authenticated user: UID: $currentUid, Email: ${currentUser.email} at ${DateTime.now()}');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inbox'),
        backgroundColor: Colors.green,
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Start New Chat'),
              content: TextField(
                controller: _workIdController,
                decoration: const InputDecoration(hintText: 'Enter Work ID'),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => _startNewChat(context),
                  child: const Text('Start Chat'),
                ),
              ],
            ),
          );
        },
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('members', arrayContains: currentUid)
            .orderBy('lastTimestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            print('Waiting for stream data at ${DateTime.now()}');
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            print('Stream error at ${DateTime.now()}: ${snapshot.error}');
            return Center(child: Text('Error loading chats: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            print('No chats found for UID: $currentUid at ${DateTime.now()}');
            return const Center(child: Text('No chats available'));
          }
          final chats = snapshot.data!.docs;
          final sortedChats = chats.toList()
            ..sort((a, b) {
              final aData = a.data() as Map<String, dynamic>? ?? {};
              final bData = b.data() as Map<String, dynamic>? ?? {};
              final aUnreadCounts = aData['unreadCounts'] as Map<String, dynamic>? ?? {};
              final bUnreadCounts = bData['unreadCounts'] as Map<String, dynamic>? ?? {};
              final aUnread = aUnreadCounts[currentUid] as int? ?? 0;
              final bUnread = bUnreadCounts[currentUid] as int? ?? 0;
              return bUnread.compareTo(aUnread); // Descending unread count for current user
            });
          print('Chats retrieved at ${DateTime.now()}: ${chats.length}, sorted by unread');
          return ListView.builder(
            itemCount: sortedChats.length,
            itemBuilder: (context, index) {
              final chat = sortedChats[index];
              final data = chat.data() as Map<String, dynamic>? ?? {};
              final members = data['members'] as List<dynamic>? ?? [];
              final otherUid = members.firstWhere(
                    (m) => m != currentUid,
                orElse: () => null,
              );
              if (otherUid == null) {
                print('Invalid chat structure for chatId: ${chat.id}, members: $members at ${DateTime.now()}');
                return const ListTile(title: Text('Invalid chat'));
              }
              final lastMessage = data['lastMessage'] ?? '';
              final time = (data['lastTimestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
              final unreadCounts = data['unreadCounts'] as Map<String, dynamic>? ?? {};
              final unreadCount = unreadCounts[currentUid] as int? ?? 0;
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(otherUid).get(),
                builder: (context, userSnap) {
                  if (userSnap.connectionState == ConnectionState.waiting) {
                    return const ListTile(title: Text('Loading...'));
                  }
                  if (!userSnap.hasData || !userSnap.data!.exists) {
                    print('User not found for UID: $otherUid in chat: ${chat.id} at ${DateTime.now()}');
                    return const ListTile(title: Text('User not found'));
                  }
                  final otherName = userSnap.data!['username'] ?? 'Unknown';
                  final formattedTime = DateFormat('HH:mm, dd/MM/yyyy').format(time);
                  print('Rendering chat: $otherName, lastMessage: $lastMessage, unread: $unreadCount at ${DateTime.now()}');

                  return ListTile(
                    leading: CircleAvatar(child: Text(otherName[0])),
                    title: Text(otherName),
                    subtitle: Text(lastMessage.isNotEmpty ? lastMessage : 'No messages yet'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(formattedTime),
                        if (unreadCount > 0)
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Stack(
                              children: [
                                Icon(
                                  Icons.circle,
                                  size: 10,
                                  color: Colors.red,
                                ),
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 16,
                                      minHeight: 16,
                                    ),
                                    child: Text(
                                      unreadCount.toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    onTap: () async {
                      if (unreadCount > 0) {
                        await FirebaseFirestore.instance
                            .collection('chats')
                            .doc(chat.id)
                            .update({
                          'unreadCounts.$currentUid': 0,
                        });
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            otherUid: otherUid,
                            otherName: otherName,
                            chatId: chat.id,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}