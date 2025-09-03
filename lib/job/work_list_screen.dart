import 'package:flutter/material.dart';
import 'package:mad_assignment/job/work_list_details_screen.dart';

// Data model for a work item
class WorkItem {
  final String title;
  final String description;
  final String status;
  final String priority;
  final String dueDate;
  final String creator;
  final int unreadCount;

  WorkItem({
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.dueDate,
    required this.creator,
    required this.unreadCount,
  });
}

class WorkListScreen extends StatelessWidget {
  const WorkListScreen({super.key});

  // Sample data list
  static final List<WorkItem> workItems = [
    WorkItem(
      title: 'Project 1',
      description: 'Description',
      status: 'Completed',
      priority: 'High',
      dueDate: '04 Dec 2025',
      creator: 'Alex',
      unreadCount: 1,
    ),
    WorkItem(
      title: 'Project 2',
      description: 'Description',
      status: 'Accepted',
      priority: 'Low',
      dueDate: '08 Dec 2025',
      creator: 'Yu Xing',
      unreadCount: 0,
    ),
    WorkItem(
      title: 'Car Brake Repair',
      description: 'Description',
      status: 'In Progress',
      priority: 'High',
      dueDate: '04 Dec 2025',
      creator: 'Keshandra',
      unreadCount: 1,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: workItems.length + 1, // +1 for header
        itemBuilder: (context, index) {
          if (index == 2) {
            // Insert divider and date header before the third item
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 8),
              child: Row(
                children: [
                  Expanded(child: Divider(thickness: 1)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'Sep 4, 2024',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(thickness: 1)),
                ],
              ),
            );
          }

          // Adjust index for work items after the divider
          final itemIndex = index > 2 ? index - 1 : index;
          if (itemIndex < workItems.length) {
            final item = workItems[itemIndex];
            return _buildWorkItemCard(context, item);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildWorkItemCard(BuildContext context, WorkItem item) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const WorkListDetailsScreen(),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row with unread badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if (item.unreadCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        item.unreadCount.toString(),
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                item.description,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 8),

              // Status and Due Date Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildChip(
                    label: item.status,
                    color: _getStatusColor(item.status),
                  ),
                  Text(
                    "Due: ${item.dueDate}",
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Priority and Creator Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildChip(
                    label: "Priority: ${item.priority}",
                    color: item.priority == "High" ? Colors.red : Colors.green,
                  ),
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.purple,
                    child: Text(
                      item.creator[0],
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "Completed":
        return Colors.green;
      case "In Progress":
        return Colors.orange;
      case "Accepted":
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}