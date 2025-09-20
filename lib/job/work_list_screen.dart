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
  final int projectId; // Added projectId
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
    required this.projectId, // Added
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
            .where('status', whereIn: ['Accepted', 'In Progress']) // Updated to include 'In Progress'
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
                  final jobId = projectData['id']?.toString() ?? 'Unknown';
                  final customerId = projectData['customer_id'];
                  final priority = projectData['priority'] ?? 'Medium';
                  final status = projectData['status'] ?? 'Accepted';
                  final description = projectData['description'] ?? 'No description';
                  final dueDate = projectData['dueDate'] is Timestamp
                      ? '${(projectData['dueDate'] as Timestamp).toDate().day}/'
                      '${(projectData['dueDate'] as Timestamp).toDate().month}/'
                      '${(projectData['dueDate'] as Timestamp).toDate().year}'
                      : 'No due date';
                  final creator = projectData['creator'] ?? 'Unknown';

                  return FutureBuilder<QuerySnapshot>(
                    future: customerId != null
                        ? FirebaseFirestore.instance
                        .collection('customers')
                        .where('customer_id', isEqualTo: customerId)
                        .get()
                        : Future.value(null),
                    builder: (context, customerSnapshot) {
                      if (customerSnapshot.connectionState == ConnectionState.waiting) {
                        return const ListTile(title: Text('Loading...'));
                      }
                      Map<String, dynamic>? customerData;
                      if (customerSnapshot.hasData && customerSnapshot.data!.docs.isNotEmpty) {
                        customerData = customerSnapshot.data!.docs.first.data() as Map<String, dynamic>?;
                      }
                      final customerName = customerData?['name']?.toString().toLowerCase() ?? 'Unknown';
                      final vehicle = customerData?['vehicle_info'] ?? 'Unknown';

                      final workItem = WorkItem(
                        title: title,
                        description: description,
                        status: status,
                        priority: priority,
                        dueDate: dueDate,
                        creator: creator,
                        unreadCount: 0,
                        projectId: projectId, // Added
                      );

                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.only(bottom: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WorkListDetailsScreen(item: workItem),
                              ),
                            );
                          },
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(15),
                            leading: CircleAvatar(
                              backgroundColor: _getStatusColor(status),
                              child: Text(
                                jobId.substring(0, 1),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(
                              '${title} (ID: $jobId)',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Customer: $customerName'),
                                Text('Vehicle: $vehicle'),
                                Text(
                                  'Priority: $priority | Status: $status',
                                  style: TextStyle(color: _getStatusColor(status)),
                                ),
                              ],
                            ),
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

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Completed':
        return Colors.green;
      case 'In Progress':
        return Colors.orange;
      case 'Pending':
        return Colors.grey;
      case 'Accepted':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}