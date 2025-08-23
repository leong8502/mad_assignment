import 'package:flutter/material.dart';

class WorklistScreen extends StatelessWidget {
  const WorklistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _buildWorkItem(
          title: 'Project 1',
          description: 'Description',
          status: 'Completed',
          priority: 'High',
          dueDate: '04 Dec 2025',
          creator: 'Alex',
          unreadCount: 1,
        ),
        _buildWorkItem(
          title: 'Project 2',
          description: 'Description',
          status: 'Accepted',
          priority: 'Low',
          dueDate: '08 Dec 2025',
          creator: 'Yu Xing',
          unreadCount: 0,
        ),
        const Divider(),
        const Text(
          'Sep 4, 2024',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        _buildWorkItem(
          title: 'Project 4',
          description: 'Description',
          status: 'In Progress',
          priority: 'High',
          dueDate: '04 Dec 2025',
          creator: 'Keshandra',
          unreadCount: 1,
        ),
      ],
    );
  }

  Widget _buildWorkItem({
    required String title,
    required String description,
    required String status,
    required String priority,
    required String dueDate,
    required String creator,
    required int unreadCount,
  }) {
    return ListTile(
      leading: Icon(Icons.folder),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
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
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(description),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Status: $status'),
              Text('Due Date: $dueDate'),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Priority: $priority'),
              CircleAvatar(
                radius: 10,
                backgroundColor: Colors.purple,
                child: Text(creator[0], style: const TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}