import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// ============================
/// Job Details Screen
/// ============================
class JobDetailsScreen extends StatefulWidget {
  final String title;
  final String id;

  const JobDetailsScreen({super.key, required this.title, required this.id});

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  Map<String, dynamic>? jobData;
  Map<String, dynamic>? customerData;
  String? docId;

  @override
  void initState() {
    super.initState();
    _fetchJob();
  }

  Future<void> _fetchJob() async {
    int jobId = int.parse(widget.id.substring(4)); // Extract ID from 'ID: 5143'
    try {
      var query = await FirebaseFirestore.instance
          .collection('projects')
          .where('id', isEqualTo: jobId)
          .get();
      if (query.docs.isNotEmpty) {
        setState(() {
          docId = query.docs.first.id;
          jobData = query.docs.first.data() as Map<String, dynamic>?;
          _fetchCustomerDetails(jobData?['customer_id']);
        });
      }
    } catch (e) {
      print('Error fetching job: $e');
    }
  }

  Future<void> _fetchCustomerDetails(String? customerId) async {
    if (customerId != null) {
      try {
        var customerQuery = await FirebaseFirestore.instance
            .collection('customers')
            .where('customer_id', isEqualTo: customerId)
            .get();
        if (customerQuery.docs.isNotEmpty) {
          setState(() {
            customerData = customerQuery.docs.first.data() as Map<String, dynamic>?;
          });
        }
      } catch (e) {
        print('Error fetching customer: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (jobData == null || customerData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    String formattedDueDate = jobData!['dueDate'] is Timestamp
        ? '${(jobData!['dueDate'] as Timestamp).toDate().month.toString().padLeft(2, '0')} '
        '${(jobData!['dueDate'] as Timestamp).toDate().day.toString().padLeft(2, '0')} '
        '${(jobData!['dueDate'] as Timestamp).toDate().year}'
        : 'No due date';

    String requestedServices = jobData!['requested_services'] ?? 'No services specified';
    String estimatedTime = jobData!['estimated_completion_time'] ?? 'Not specified';
    String customerName = customerData?['name'] ?? 'Unknown';
    String contact = customerData?['contact'] ?? 'Not provided';
    String vehicleInfo = customerData?['vehicle_info'] ?? 'Not provided';
    String registration = customerData?['registration'] ?? 'Not provided';
    String vin = customerData?['vin'] ?? 'Not provided';
    String serviceHistory = jobData!['service_history'] ?? 'No history available';

    return Scaffold(
      appBar: AppBar(
        title: Text(jobData!['title'] ?? widget.title),
        backgroundColor: Colors.purple,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFF3F4F6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.purple.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "${jobData!['title'] ?? widget.title}\nID: ${jobData!['id'] ?? widget.id.substring(4)}",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),

              const Text("Customer Details",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.person, size: 40, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Name: $customerName", style: const TextStyle(fontSize: 16)),
                        Text("Contact: $contact", style: const TextStyle(fontSize: 16)),
                        Text("Vehicle info: $vehicleInfo", style: const TextStyle(fontSize: 16)),
                        Text("Registration: $registration", style: const TextStyle(fontSize: 16)),
                        Text("VIN: $vin", style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              const Text("Job Description",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Text(jobData!['description'] ?? "No description available."),

              const SizedBox(height: 16),
              const Text("Requested Services",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Text(requestedServices),

              const SizedBox(height: 16),
              const Text("Due Date",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(formattedDueDate),

              const SizedBox(height: 16),
              const Text("Estimated Completion Time",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(estimatedTime),

              const SizedBox(height: 16),
              const Text("Assigned Parts",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(jobData!['details'] ?? "No details available."),

              const SizedBox(height: 16),
              const Text("Service History",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(serviceHistory),

              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    _showConfirmationDialog(context);
                  },
                  child: const Text("Accept",
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Acceptance"),
        content: const Text("Are you sure you want to accept this task?"),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.grey,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.white),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              if (docId != null) {
                await FirebaseFirestore.instance
                    .collection('projects')
                    .doc(docId)
                    .update({'status': 'Accepted'});
              }
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Job accepted successfully!")),
              );
              Navigator.pop(context);
            },
            child: const Text(
              "Accept",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}