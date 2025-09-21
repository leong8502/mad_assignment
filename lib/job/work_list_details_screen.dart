// work_list_details_screen.dart
import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'upload_page.dart';
import 'work_list_screen.dart';
import 'digital_signoff.dart';

class WorkListDetailsScreen extends StatefulWidget {
  final WorkItem item;

  const WorkListDetailsScreen({super.key, required this.item});

  @override
  State<WorkListDetailsScreen> createState() => _WorkListDetailsScreenState();
}

class _WorkListDetailsScreenState extends State<WorkListDetailsScreen> {
  Timer? _timer;

  List<File> uploadedImages = [];
  late TextEditingController _remarkController;

  // Firestore data
  Map<String, dynamic>? _projectData;
  Map<String, dynamic>? _customerData;
  bool _loadingProject = true;

  @override
  void initState() {
    super.initState();
    uploadedImages = List<File>.from(widget.item.images);
    _remarkController = TextEditingController(text: widget.item.remark);

    _fetchProjectAndCustomer();

    // Resume timer if already running
    if (widget.item.isRunning && !widget.item.isFinished) {
      _resumeTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _remarkController.dispose();
    super.dispose();
  }

  // Fetch project + customer only
  Future<void> _fetchProjectAndCustomer() async {
    final firestore = FirebaseFirestore.instance;

    try {
      final projectQuery = await firestore
          .collection('projects')
          .where('id', isEqualTo: widget.item.projectId)
          .get();

      if (projectQuery.docs.isNotEmpty) {
        final projectDoc = projectQuery.docs.first;
        final projectData = projectDoc.data();

        Map<String, dynamic>? customerData;

        if (projectData['customer_id'] != null) {
          final customerQuery = await firestore
              .collection('customers')
              .where('customer_id', isEqualTo: projectData['customer_id'])
              .get();

          if (customerQuery.docs.isNotEmpty) {
            customerData = customerQuery.docs.first.data();
          }
        }

        setState(() {
          _projectData = projectData;
          _customerData = customerData;
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

  // Save into WorkItem
  void _saveToItem() {
    widget.item.images = uploadedImages;
    widget.item.remark = _remarkController.text.trim();
  }

  void _saveBackAndPop() {
    _saveToItem();
    Navigator.pop(context);
  }

  // --- TIMER METHODS ---
  void _startTimer() async {
    if (widget.item.isFinished) return; // cannot start after finished
    if (widget.item.isRunning) return; // already running

    // Update Firestore status only once
    if (widget.item.status == 'Accepted' && widget.item.startTime == null) {
      final firestore = FirebaseFirestore.instance;
      final query = await firestore
          .collection('projects')
          .where('id', isEqualTo: widget.item.projectId)
          .get();
      if (query.docs.isNotEmpty) {
        final docId = query.docs.first.id;
        await firestore
            .collection('projects')
            .doc(docId)
            .update({'status': 'In Progress'});
      }
    }

    setState(() {
      widget.item.isRunning = true;
      widget.item.startTime ??= DateTime.now();
    });

    _resumeTimer();
  }

  void _resumeTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!widget.item.isFinished && widget.item.isRunning) {
        setState(() {
          final now = DateTime.now();
          widget.item.elapsedTime = now.difference(widget.item.startTime!); // keep as Duration
        });
      }
    });
  }

  void _pauseTimer() {
    if (!widget.item.isRunning || widget.item.isFinished) return;
    setState(() {
      widget.item.isRunning = false;
    });
    _timer?.cancel();
  }

  void _stopTimer() async {
    if (widget.item.startTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You must start the timer before stopping."),
        ),
      );
      return;
    }

    if (widget.item.isFinished) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Stop Timer"),
        content: const Text("Stop the timer if you confirm finish the work."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Stop"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        widget.item.isRunning = false;
        widget.item.isFinished = true;
        widget.item.endTime = DateTime.now();
        widget.item.elapsedTime =
            widget.item.endTime!.difference(widget.item.startTime!); // Duration
      });
      _timer?.cancel();
    }
  }

  String _formatDuration(Duration duration) {
    final h = duration.inHours;
    final m = duration.inMinutes.remainder(60);
    final s = duration.inSeconds.remainder(60);
    return "$h hours $m minutes $s seconds";
  }

  String _formatDateTime(DateTime dt) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hour = dt.hour > 12 ? dt.hour - 12 : dt.hour;
    final ampm = dt.hour >= 12 ? "pm" : "am";
    return "$hour:${twoDigits(dt.minute)} $ampm, ${dt.day} ${_monthName(dt.month)} ${dt.year}";
  }

  String _monthName(int month) {
    const months = [
      "January","February","March","April","May","June",
      "July","August","September","October","November","December"
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.item.title;
    final id = widget.item.projectId;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: _saveBackAndPop,
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.purple,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    Text("ID: $id",
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Project + customer info
              _loadingProject
                  ? const CircularProgressIndicator()
                  : Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_projectData != null) ...[
                      const Text("Description:",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(_projectData!['description'] ?? 'N/A'),
                      const SizedBox(height: 12),
                      const Text("Details:",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(_projectData!['details'] ?? 'N/A'),
                      const SizedBox(height: 12),
                    ],
                    if (_customerData != null) ...[
                      const Text("Registration:",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(_customerData!['registration'] ?? 'N/A'),
                      const SizedBox(height: 12),
                      const Text("Vehicle Info:",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(_customerData!['vehicle_info'] ?? 'N/A'),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Proof display & edit
              if (_hasProof()) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 3)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Remark:",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextField(
                        controller: _remarkController,
                        decoration: const InputDecoration(
                          hintText: "Enter your remark...",
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),
                      if (uploadedImages.isNotEmpty)
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children:
                            uploadedImages.asMap().entries.map((entry) {
                              final index = entry.key;
                              final file = entry.value;
                              return Stack(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.all(8),
                                    child: Image.file(file,
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover),
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          uploadedImages.removeAt(index);
                                        });
                                      },
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: Colors.black54,
                                          shape: BoxShape.circle,
                                        ),
                                        padding: const EdgeInsets.all(4),
                                        child: const Icon(Icons.close,
                                            color: Colors.white, size: 18),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Upload Proof button
              ElevatedButton(
                onPressed: () async {
                  if (!widget.item.isFinished) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            "You must finish the job before uploading proof."),
                      ),
                    );
                    return;
                  }

                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const UploadPage()),
                  );

                  if (result != null) {
                    setState(() {
                      uploadedImages.addAll(List<File>.from(result["images"]));
                      _remarkController.text =
                          result["remark"] ?? _remarkController.text;
                    });
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: const Text("Upload Proof"),
              ),

              const SizedBox(height: 10),

              // Complete button → save + signoff
              ElevatedButton(
                onPressed: () {
                  if (uploadedImages.isEmpty &&
                      _remarkController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              "Please upload proof or add a remark before completing.")),
                    );
                    return;
                  }

                  _saveToItem();

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DigitalSignoffPage(
                        proofImages: uploadedImages,
                        remark: _remarkController.text.trim(),
                        projectId: widget.item.projectId,
                        elapsedTime: widget.item.elapsedTime,
                        startTime: widget.item.startTime, // Duration
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                child: const Text("Complete",
                    style: TextStyle(color: Colors.white)),
              ),

              const SizedBox(height: 20),

              // Timer controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildControlButton(Icons.play_arrow, "START",
                      widget.item.isFinished ? null : _startTimer),
                  const SizedBox(width: 20),
                  _buildControlButton(Icons.pause, "PAUSE",
                      (widget.item.isFinished || !widget.item.isRunning)
                          ? null
                          : _pauseTimer),
                  const SizedBox(width: 20),
                  _buildControlButton(Icons.stop, "STOP",
                      (widget.item.isFinished || widget.item.startTime == null)
                          ? null
                          : _stopTimer),
                ],
              ),

              const SizedBox(height: 20),
              Text(
                  "Start Time: ${widget.item.startTime != null ? _formatDateTime(widget.item.startTime!) : '--'}"),
              Text(
                  "End Time: ${widget.item.endTime != null ? _formatDateTime(widget.item.endTime!) : '--'}"),
              Text("Elapsed: ${_formatDuration(widget.item.elapsedTime)}"), // formatted
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  bool _hasProof() {
    return uploadedImages.isNotEmpty ||
        _remarkController.text.trim().isNotEmpty;
  }

  Widget _buildControlButton(
      IconData icon, String label, VoidCallback? onPressed) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor:
            onPressed == null ? Colors.grey[400] : Colors.grey[300],
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(16),
          ),
          child: Icon(icon, color: Colors.black),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
