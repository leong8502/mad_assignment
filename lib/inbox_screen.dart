import 'package:flutter/material.dart';

class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _buildMessageTile(
          name: 'Manager',
          message: 'Okay, TQ',
          time: 'Today 9:46 AM',
          unreadCount: 1,
        ),
        _buildMessageTile(
          name: 'Miss Lim',
          message: 'Yes, Appreciate for your help.',
          time: 'Today 7:43 AM',
          unreadCount: 2,
        ),
        _buildMessageTile(
          name: 'Miss Hong',
          message: 'Alright, we will check for it.',
          time: 'Yesterday 8:00 PM',
          unreadCount: 0,
        ),
      ],
    );
  }

  Widget _buildMessageTile({
    required String name,
    required String message,
    required String time,
    required int unreadCount,
  }) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(name[0]),
      ),
      title: Text(name),
      subtitle: Text(message),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(time),
          if (unreadCount > 0)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                unreadCount.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}