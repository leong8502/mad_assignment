// work_list_details_screen.dart
import 'dart:async';
import 'dart:io'; // ADD THIS
import 'package:cloud_firestore/cloud_firestore.dart'; // Added for Firestore update
import 'package:flutter/material.dart';
import 'upload_page.dart';
import 'work_list_screen.dart';
import 'digital_signoff.dart'; // ADD THIS

class WorkListDetailsScreen extends StatefulWidget {
  final WorkItem item;

  const WorkListDetailsScreen({super.key, required this.item});

  @override
  State<WorkListDetailsScreen> createState() => _WorkListDetailsScreenState();
}

class _WorkListDetailsScreenState extends State<WorkListDetailsScreen> {
  // NOTE: using the WorkItem passed in (widget.item)
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  bool _isRunning = false;
  DateTime? _startTime;
  DateTime? _endTime;

  List<File> uploadedImages = [];
  late TextEditingController _remarkController; // ADD THIS

  @override
  void initState() {
    super.initState();
    // initialize from the WorkItem (persisted storage in memory)
    uploadedImages = List<File>.from(widget.item.images);
    _remarkController = TextEditingController(text: widget.item.remark); // ADD THIS
  }

  @override
  void dispose() {
    _timer?.cancel();
    _remarkController.dispose(); // ADD THIS
    super.dispose();
  }

  // Save into the WorkItem (but do NOT pop) - ADD THIS
  void _saveToItem() {
    widget.item.images = uploadedImages;
    widget.item.remark = _remarkController.text.trim();
  }

  // Save and pop back to list (used when user wants to leave)
  void _saveBackAndPop() {
    _saveToItem(); // ADD THIS
    Navigator.pop(context);
  }

  void _startTimer() async {
    if (_isRunning) return;

    // Automatically update status to 'In Progress' if it's 'Accepted'
    if (widget.item.status == 'Accepted') {
      final firestore = FirebaseFirestore.instance;
      final query = await firestore.collection('projects').where('id', isEqualTo: widget.item.projectId).get();
      if (query.docs.isNotEmpty) {
        final docId = query.docs.first.id;
        await firestore.collection('projects').doc(docId).update({'status': 'In Progress'});
      }
    }

    setState(() {
      _isRunning = true;
      _startTime ??= DateTime.now();
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _elapsed += const Duration(seconds: 1);
      });
    });
  }

  void _pauseTimer() {
    if (!_isRunning) return;
    setState(() {
      _isRunning = false;
      _endTime = DateTime.now();
    });
    _timer?.cancel();
  }

  void _resetTimer() {
    setState(() {
      _timer?.cancel();
      _elapsed = Duration.zero;
      _isRunning = false;
      _startTime = null;
      _endTime = null;
    });
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
    // Provide title from WorkItem
    final title = widget.item.title;
    final id = widget.item.dueDate; // or add explicit id to WorkItem if you want

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // Save edits and go back
            _saveBackAndPop(); // ADD THIS
          },
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
                    Text(
                      title,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    Text(
                      "ID: $id",
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Job details box (unchanged)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Brake Pads (Front):",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("2 units, Part No. BP-TC-2018, Available in Warehouse Bay A-12"),
                    Text("Brake Fluid:",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("1 liter, Part No. BF-DOT4, Available in Warehouse Bay B-5"),
                    Text("Brake Rotors (Front):",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("2 units, Part No. BR-TC-2018, On Order (ETA: 2 hours)"),
                  ],
                ),
              ),

              // ===== proof display & edit block (ADD THIS) =====
              if (_hasProof()) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Remark:", style: TextStyle(fontWeight: FontWeight.bold)),
                      TextField(
                        controller: _remarkController,
                        decoration: const InputDecoration(
                          hintText: "Enter your remark...",
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),

                      // Images row (horizontal scroll) - use Row inside SingleChildScrollView to avoid nested scroll issues
                      if (uploadedImages.isNotEmpty) ...[
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: uploadedImages.asMap().entries.map((entry) {
                              final index = entry.key;
                              final file = entry.value;
                              return Stack(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.all(8),
                                    child: Image.file(
                                      file,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
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
                                        child: const Icon(Icons.close, color: Colors.white, size: 18),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
              // ===== end proof display & edit block =====

              const SizedBox(height: 16),

              // Upload Proof button (ADD THIS)
              ElevatedButton(
                onPressed: () async {
                  // open UploadPage, which returns images + remark map
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const UploadPage()),
                  );

                  if (result != null) {
                    setState(() {
                      // append selected images (so user can upload multiple times)
                      uploadedImages.addAll(List<File>.from(result["images"]));
                      _remarkController.text = result["remark"] ?? _remarkController.text;
                    });
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: const Text("Upload Proof"),
              ),

              const SizedBox(height: 10),

              // Complete button → save to WorkItem and navigate to Digital Signoff (ADD THIS)
              ElevatedButton(
                onPressed: () {
                  if (uploadedImages.isEmpty && _remarkController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please upload proof or add a remark before completing.")),
                    );
                    return;
                  }

                  // Save into the WorkItem (so it's persisted in the list)
                  _saveToItem(); // ADD THIS

                  // Navigate to digital sign-off page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DigitalSignoffPage(
                        images: uploadedImages,
                        remark: _remarkController.text.trim(),
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                child: const Text("Complete", style: TextStyle(color: Colors.white)),
              ),

              const SizedBox(height: 20),

              // Timer controls (kept below)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildControlButton(Icons.play_arrow, "START", _startTimer),
                  const SizedBox(width: 20),
                  _buildControlButton(Icons.pause, "PAUSE", _pauseTimer),
                  const SizedBox(width: 20),
                  _buildControlButton(Icons.stop, "STOP", _resetTimer),
                ],
              ),

              const SizedBox(height: 20),
              Text("Start Time: ${_startTime != null ? _formatDateTime(_startTime!) : '--'}"),
              Text("End Time: ${_endTime != null ? _formatDateTime(_endTime!) : '--'}"),
              Text("Elapsed: ${_formatDuration(_elapsed)}"),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  bool _hasProof() {
    return uploadedImages.isNotEmpty || _remarkController.text.trim().isNotEmpty;
  }

  Widget _buildControlButton(IconData icon, String label, VoidCallback onPressed) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[300],
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