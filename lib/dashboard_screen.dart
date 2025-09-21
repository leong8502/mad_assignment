import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mad_assignment/job/job_details_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final currentDate = DateTime.now();

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.trim().toLowerCase();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_searchQuery.isNotEmpty) {
          setState(() {
            _searchQuery = '';
            _searchController.clear();
          });
          return false;
        }
        return true;
      },
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search jobs or IDs...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _searchQuery.isEmpty
                    ? 'Today - ${_formatDate(currentDate)}'
                    : 'Search Results - ${_formatDate(currentDate)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              StreamBuilder<QuerySnapshot>(
                stream: _searchQuery.isEmpty
                    ? FirebaseFirestore.instance
                    .collection('projects')
                    .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime(currentDate.year, currentDate.month, currentDate.day)))
                    .where('date', isLessThan: Timestamp.fromDate(DateTime(currentDate.year, currentDate.month, currentDate.day + 1)))
                    .snapshots()
                    : FirebaseFirestore.instance
                    .collection('projects')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No jobs found.'));
                  }
                  final docs = snapshot.data!.docs;
                  List<QueryDocumentSnapshot> filteredDocs = docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>? ?? {};
                    final title = data['title']?.toString().toLowerCase() ?? '';
                    final jobId = data['id']?.toString().toLowerCase() ?? '';
                    final customerId = data['customer_id'];
                    final priority = data['priority'] ?? 'Medium';
                    final status = data['status'] ?? 'Pending';
                    return title.contains(_searchQuery) || jobId.contains(_searchQuery);
                  }).toList();
                  return Column(
                    children: filteredDocs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>? ?? {};
                      final title = data['title'] ?? 'Untitled';
                      final jobId = data['id'] ?? 'Unknown';
                      final customerId = data['customer_id'];
                      final priority = data['priority'] ?? 'Medium';
                      final status = data['status'] ?? 'Pending';
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
                                    builder: (_) => JobDetailsScreen(
                                      title: title,
                                      id: 'ID: $jobId',
                                    ),
                                  ),
                                );
                              },
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(15),
                                leading: CircleAvatar(
                                  backgroundColor: _getStatusColor(status),
                                  child: Text(
                                    jobId.toString().substring(0, 1),
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
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
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