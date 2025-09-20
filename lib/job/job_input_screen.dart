import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// ============================
/// Job Input Screen
/// ============================
class JobInputScreen extends StatefulWidget {
  const JobInputScreen({super.key});

  @override
  State<JobInputScreen> createState() => _JobInputScreenState();
}

class _JobInputScreenState extends State<JobInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestore = FirebaseFirestore.instance;

  String creator = 'Yu Xing';
  String customerId = 'c2'; // Default value, will be updated via dropdown
  String description = '';
  String details = '';
  String dueDate = '';
  String estimatedCompletionTime = '';
  String priority = 'Low';
  String requestedServices = '';
  String serviceHistory = '';
  String status = 'Pending';
  String title = '';

  // List of predefined customers
  final List<Map<String, String>> customers = [
    {
      'customer_id': 'c2',
      'name': 'Fatimah binti Ali',
      'contact': '016-7890123',
      'registration': 'WPKL 1234',
      'vehicle_info': 'Honda Civic, 2020, Sedan',
      'vin': '1HGCM82633A123456',
    },
    {
      'customer_id': 'c3',
      'name': 'Mohammed bin Rahman',
      'contact': '019-3456789',
      'registration': 'WJB 5678',
      'vehicle_info': 'Proton Saga, 2019, Hatchback',
      'vin': 'M0XBH12KX9K123456',
    },
    {
      'customer_id': 'c4',
      'name': 'Siti binti Hassan',
      'contact': '012-9012345',
      'registration': 'WPEN 4321',
      'vehicle_info': 'Perodua Myvi, 2021, MPV',
      'vin': 'P6YBH12KX1M123456',
    },
  ];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        dueDate = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      _firestore.collection('projects').add({
        'creator': creator,
        'customer_id': customerId,
        'date': Timestamp.now(),
        'description': description,
        'details': details,
        'dueDate': Timestamp.fromDate(DateFormat('yyyy-MM-dd').parse(dueDate)),
        'estimated_completion_time': estimatedCompletionTime,
        'id': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        'priority': priority,
        'requested_services': requestedServices,
        'service_history': serviceHistory,
        'status': status,
        'title': title,
      }).then((value) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Job added successfully!')),
        );
        Navigator.pop(context);
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add job: $error')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Job'),
        backgroundColor: Colors.purple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) => value!.isEmpty ? 'Enter a title' : null,
                onSaved: (value) => title = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Description'),
                onSaved: (value) => description = value ?? '',
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Details'),
                onSaved: (value) => details = value ?? '',
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Due Date',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                controller: TextEditingController(text: dueDate),
                readOnly: true,
                onTap: () => _selectDate(context),
                validator: (value) => dueDate.isEmpty ? 'Select a due date' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Estimated Completion Time'),
                onSaved: (value) => estimatedCompletionTime = value ?? '',
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Priority'),
                value: priority,
                items: ['Low', 'Medium', 'High']
                    .map((label) => DropdownMenuItem(
                  value: label,
                  child: Text(label),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    priority = value!;
                  });
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Requested Services'),
                onSaved: (value) => requestedServices = value ?? '',
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Service History'),
                onSaved: (value) => serviceHistory = value ?? '',
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Select Customer'),
                value: customerId,
                items: customers.map((customer) => DropdownMenuItem(
                  value: customer['customer_id'],
                  child: Text('${customer['name']} (ID: ${customer['customer_id']})'),
                )).toList(),
                onChanged: (value) {
                  setState(() {
                    customerId = value!;
                  });
                },
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _submitForm,
                  child: const Text('Submit', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}