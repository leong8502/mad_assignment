import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mad_assignment/job/work_list_screen.dart';

class DigitalSignoffPage extends StatefulWidget {
  final List<File> proofImages; // previous proof images
  final String remark; // previous remark
  final int projectId;
  final Duration elapsedTime;
  final DateTime? startTime;


  const DigitalSignoffPage({
    super.key,
    required this.proofImages,
    required this.remark,
    required this.projectId,
    required this.elapsedTime,
    this.startTime,
  });

  @override
  State<DigitalSignoffPage> createState() => _DigitalSignoffPageState();
}

class _DigitalSignoffPageState extends State<DigitalSignoffPage> {
  File? signatureImage;
  bool _loadingProject = true;
  Map<String, dynamic>? _projectData;
  Map<String, dynamic>? _customerData;
  String? _projectDocId; // Firestore document ID

  @override
  void initState() {
    super.initState();
    _fetchProjectAndCustomer();
  }

  // ---------------- Firestore fetch ----------------
  Future<void> _fetchProjectAndCustomer() async {
    final firestore = FirebaseFirestore.instance;
    try {
      final projectQuery = await firestore
          .collection('projects')
          .where('id', isEqualTo: widget.projectId)
          .limit(1)
          .get();

      if (projectQuery.docs.isNotEmpty) {
        final projectDoc = projectQuery.docs.first;
        final projectData = projectDoc.data();
        final projectDocId = projectDoc.id; // store Firestore document ID

        Map<String, dynamic>? customerData;
        final customerId = projectData['customer_id'];
        if (customerId != null) {
          final customerQuery = await firestore
              .collection('customers')
              .where('customer_id', isEqualTo: customerId)
              .limit(1)
              .get();
          if (customerQuery.docs.isNotEmpty) {
            customerData = customerQuery.docs.first.data();
          }
        }

        setState(() {
          _projectData = projectData;
          _customerData = customerData;
          _projectDocId = projectDocId;
          _loadingProject = false;
        });
      } else {
        setState(() => _loadingProject = false);
      }
    } catch (e) {
      print("Error fetching project/customer: $e");
      setState(() => _loadingProject = false);
    }
  }

  // ---------------- Pick Signature ----------------
  Future<void> _pickSignature() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        signatureImage = File(pickedFile.path);
      });
    }
  }

  // ---------------- Section Widget ----------------
  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const Divider(),
          child,
        ],
      ),
    );
  }

  // ---------------- Duration Formatter ----------------
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2,'0')}:${minutes.toString().padLeft(2,'0')}:${seconds.toString().padLeft(2,'0')}';
  }

  // ---------------- Build ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Digital Sign-Off"),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: _loadingProject
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer Info
            if (_customerData != null)
              _buildSection(
                title: "Customer Information",
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Name: ${_customerData!['name'] ?? '--'}"),
                    Text("Phone: ${_customerData!['contact'] ?? '--'}"),
                    Text("Vehicle: ${_customerData!['vehicle_info'] ?? '--'}"),
                    Text("VIN: ${_customerData!['vin'] ?? '--'}"),
                  ],
                ),
              ),

            // Service Details
            if (_projectData != null)
              _buildSection(
                title: "Service Details",
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Job ID: ${_projectData!['id'] ?? '--'}"),
                    Text("Title: ${_projectData!['title'] ?? '--'}"),
                    // ---------------- Service Time ----------------
                    const SizedBox(height: 10),
                    Text(
                      "Start Date: ${widget.startTime != null ? "${widget.startTime!.day}/${widget.startTime!.month}/${widget.startTime!.year} ${widget.startTime!.hour}:${widget.startTime!.minute.toString().padLeft(2,'0')}" : '--'}",                    ),
                    Text(
                      "Elapsed Time: ${_formatDuration(widget.elapsedTime)}",
                    ),

                    if (widget.remark.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      const Text("Remark:", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(widget.remark),
                    ],
                  ],
                ),
              ),

            // Proof Images (display only)
            if (widget.proofImages.isNotEmpty)
              _buildSection(
                title: "Proof Images",
                child: SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.proofImages.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.all(8),
                        child: Image.file(
                          widget.proofImages[index],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                ),
              ),

            // Signature (uploadable)
            _buildSection(
              title: "Digital Signature",
              child: Column(
                children: [
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8)),
                    alignment: Alignment.center,
                    child: signatureImage != null
                        ? Image.file(signatureImage!, width: 200, height: 150)
                        : const Text("No signature uploaded"),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _pickSignature,
                    child: const Text("Upload Signature"),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Sign-Off Button
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: signatureImage != null ? Colors.green : Colors.grey,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: (signatureImage == null || _projectDocId == null)
                    ? null
                    : () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text("Confirm"),
                      content: const Text("Confirm job completion and sign-off?"),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.of(dialogContext).pop(false),
                            child: const Text("Cancel")),
                        TextButton(
                            onPressed: () => Navigator.of(dialogContext).pop(true),
                            child: const Text("Confirm")),
                      ],
                    ),
                  );

                  if (confirm == true && context.mounted) {
                    try {
                      // Update project status in Firestore
                      await FirebaseFirestore.instance
                          .collection('projects')
                          .doc(_projectDocId)
                          .update({'status': 'Completed'});

                      // Navigate back to MasterPage
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    } catch (e) {
                      print('Error updating project status: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to sign off the project.')),
                      );
                    }
                  }
                },
                child: const Text("Sign Off"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
