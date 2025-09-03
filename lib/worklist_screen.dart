// Modified work_list_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
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

class WorklistScreen extends StatelessWidget {
  const WorklistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('projects').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No work items found.'));
          }

          List<WorkItem> workItems = [];
          for (var doc in snapshot.data!.docs) {
            var data = doc.data() as Map<String, dynamic>;
            String formattedDueDate = '';
            if (data['dueDate'] is Timestamp) {
              DateTime due = (data['dueDate'] as Timestamp).toDate();
              formattedDueDate = '${due.day.toString().padLeft(2, '0')} ${due.month.toString().padLeft(2, '0')} ${due.year}';
            }
            workItems.add(
              WorkItem(
                title: data['title'] ?? 'Untitled',
                description: data['description'] ?? 'No description',
                status: data['status'] ?? 'Unknown',
                priority: data['priority'] ?? 'Medium',
                dueDate: formattedDueDate,
                creator: data['creator'] ?? 'Unknown',
                unreadCount: 0, // You can add logic or a field in Firestore for unreadCount if needed
              ),
            );
          }

          // Optional: Sort by dueDate descending
          workItems.sort((a, b) {
            DateTime dateA = DateTime.parse(a.dueDate.split(' ').reversed.join('-'));
            DateTime dateB = DateTime.parse(b.dueDate.split(' ').reversed.join('-'));
            return dateB.compareTo(dateA);
          });

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: workItems.length,
            itemBuilder: (context, index) {
              final item = workItems[index];
              return _buildWorkItemCard(context, item);
            },
          );
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