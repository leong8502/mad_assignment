import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mad_assignment/job/work_list_details_screen.dart';
import 'dart:io';

// Data model for a work item
class WorkItem {
  final String title;
  final String description;
  final String status;
  final String priority;
  final String dueDate;
  final String creator;
  final int unreadCount;
  List<File> images;
  String remark;

  WorkItem({
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.dueDate,
    required this.creator,
    required this.unreadCount,
    this.images = const [],
    this.remark = "",
  });
}

class WorkListScreen extends StatefulWidget {
  const WorkListScreen({super.key});

  @override
  State<WorkListScreen> createState() => _WorkListScreenState();
}

class _WorkListScreenState extends State<WorkListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? workId;

  @override
  void initState() {
    super.initState();
    _fetchWorkId();
  }

  Future<void> _fetchWorkId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        final fetchedWorkId = userDoc.data()?['workId'] as String?;
        print('Fetched workId: $fetchedWorkId');
        setState(() {
          workId = fetchedWorkId;
        });
      } catch (e) {
        print('Error fetching workId: $e');
      }
    } else {
      print('No authenticated user found');
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now(); // 09:55 PM +08, September 20, 2025
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: workId == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('projects')
            .where('status', isEqualTo: 'Accepted')
            .snapshots(),
        builder: (context, projectSnapshot) {
          if (projectSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!projectSnapshot.hasData || projectSnapshot.data!.docs.isEmpty) {
            print('No accepted projects found');
            return const Center(child: Text('No accepted jobs found.'));
          }

          final projectDocs = projectSnapshot.data!.docs;
          print('Found ${projectDocs.length} accepted projects: ${projectDocs.map((d) => d.data()).toList()}');
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: projectDocs.length + 1, // +1 for header
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8),
                  child: Row(
                    children: [
                      const Expanded(child: Divider(thickness: 1)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          'Accepted Jobs - ${now.day}/${now.month}/${now.year}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider(thickness: 1)),
                    ],
                  ),
                );
              }

              final projectIndex = index - 1;
              final projectDoc = projectDocs[projectIndex];
              final projectId = projectDoc['id'] as int;
              print('Processing project with id: $projectId');

              return FutureBuilder<QuerySnapshot>(
                future: _firestore
                    .collection('task')
                    .where('projectId', isEqualTo: projectId)
                    .where('workId', isEqualTo: workId)
                    .limit(1)
                    .get(),
                builder: (context, taskSnapshot) {
                  if (taskSnapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox.shrink();
                  }
                  if (!taskSnapshot.hasData || taskSnapshot.data!.docs.isEmpty) {
                    print('No task found for projectId: $projectId and workId: $workId');
                    return const SizedBox.shrink();
                  }

                  final taskDoc = taskSnapshot.data!.docs.first;
                  final taskProjectId = taskDoc['projectId'] as int;
                  if (taskProjectId != projectId) {
                    print('Mismatch: projectId ($projectId) does not match task projectId ($taskProjectId)');
                    return const SizedBox.shrink();
                  }

                  final projectData = projectDoc.data() as Map<String, dynamic>;
                  final title = projectData['title'] ?? 'Untitled';
                  final description = projectData['description'] ?? 'No description';
                  final status = projectData['status'] ?? 'Accepted';
                  final priority = projectData['priority'] ?? 'Medium';
                  final dueDate = projectData['dueDate'] is Timestamp
                      ? '${(projectData['dueDate'] as Timestamp).toDate().day}/'
                      '${(projectData['dueDate'] as Timestamp).toDate().month}/'
                      '${(projectData['dueDate'] as Timestamp).toDate().year}'
                      : 'No due date';
                  final creator = projectData['creator'] ?? 'Unknown';

                  final workItem = WorkItem(
                    title: title,
                    description: description,
                    status: status,
                    priority: priority,
                    dueDate: dueDate,
                    creator: creator,
                    unreadCount: 0,
                  );

                  return _buildWorkItemCard(context, workItem);
                },
              );
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
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WorkListDetailsScreen(item: item),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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