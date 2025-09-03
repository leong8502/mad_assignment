import 'dart:async';
import 'package:flutter/material.dart';

class WorkListDetailsScreen extends StatefulWidget {
  const WorkListDetailsScreen({super.key});

  @override
  State<WorkListDetailsScreen> createState() => _WorkListDetailsScreenState();
}

class _WorkListDetailsScreenState extends State<WorkListDetailsScreen> {
  final String title = "Car Brake Repair";
  final String id = "5143";

  Timer? _timer;
  Duration _elapsed = Duration.zero;
  bool _isRunning = false;
  DateTime? _startTime;
  DateTime? _endTime;

  void _startTimer() {
    if (_isRunning) return;

    setState(() {
      _isRunning = true;
      _startTime ??= DateTime.now(); // record only first start
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
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
              const SizedBox(height: 20),
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
              Text(
                "Start Time: ${_startTime != null ? _formatDateTime(_startTime!) : '--'}",
              ),
              Text(
                "End Time: ${_endTime != null ? _formatDateTime(_endTime!) : '--'}",
              ),
              Text("Elapsed: ${_formatDuration(_elapsed)}"),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Complete",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
