import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'job_details_screen.dart';

/// ============================
/// Job Schedule Screen
/// ============================
class JobScheduleScreen extends StatefulWidget {
  const JobScheduleScreen({super.key});

  @override
  State<JobScheduleScreen> createState() => _JobScheduleScreenState();
}

class _JobScheduleScreenState extends State<JobScheduleScreen> {
  DateTime? _currentDate = DateTime.now();
  bool _showAllJobs = false;

  Map<String, List<Map<String, String>>> jobsByDate = {};

  StreamSubscription<QuerySnapshot>? _sub;

  final List<String> weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  void _loadJobs() {
    _sub?.cancel();
    _sub = FirebaseFirestore.instance.collection('projects').snapshots().listen((snapshot) {
      Map<String, List<Map<String, String>>> newJobs = {};
      for (var doc in snapshot.docs) {
        var data = doc.data();
        if (data['date'] is Timestamp) {
          Timestamp dateTs = data['date'] as Timestamp;
          DateTime date = dateTs.toDate();
          // Use only date components for the key (ignore time)
          String key = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          newJobs.putIfAbsent(key, () => []);
          newJobs[key]!.add({
            'title': data['title'] as String? ?? 'Untitled',
            'id': 'ID: ${data['id']}',
          });
        }
      }
      setState(() {
        jobsByDate = newJobs;
      });
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final DateTime referenceDate = _currentDate ?? DateTime.now();
    final int daysToMonday = referenceDate.weekday - 1;
    final DateTime monday = referenceDate.subtract(Duration(days: daysToMonday));
    final List<DateTime> weekDates =
    List.generate(7, (index) => monday.add(Duration(days: index)));

    final String selectedKey = _currentDate != null
        ? '${_currentDate!.year}-${_currentDate!.month.toString().padLeft(2, '0')}-${_currentDate!.day.toString().padLeft(2, '0')}'
        : '';
    final List<Map<String, String>> jobs = _showAllJobs
        ? jobsByDate.values.expand((jobs) => jobs).toList()
        : jobsByDate[selectedKey] ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 40, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                /// Title
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _showAllJobs
                          ? 'All Jobs'
                          : _currentDate != null
                          ? '${_monthName(_currentDate!.month)}, ${_currentDate!.day}'
                          : 'Select a Date',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (!_showAllJobs && _currentDate != null)
                      Text(
                        '${_currentDate!.year}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),

                /// Buttons
                Row(
                  children: [
                    // Toggle Show All
                    Container(
                      decoration: BoxDecoration(
                        color: _showAllJobs ? Colors.black : Colors.white,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            _showAllJobs = !_showAllJobs;
                            if (_showAllJobs) _currentDate = null;
                          });
                        },
                        child: Text(
                          _showAllJobs ? 'Show by Date' : 'Show All',
                          style: TextStyle(
                            color: _showAllJobs ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Calendar Button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.calendar_today, size: 20),
                        onPressed: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: _currentDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() {
                              _currentDate = picked;
                              _showAllJobs = false;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          /// Week selector
          if (!_showAllJobs)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(7, (index) {
                  final date = weekDates[index];
                  final isSelected = _currentDate != null &&
                      date.day == _currentDate!.day &&
                      date.month == _currentDate!.month &&
                      date.year == _currentDate!.year;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _currentDate = date;
                        _showAllJobs = false;
                      });
                    },
                    child: Column(
                      children: [
                        Text(
                          weekdays[index],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.black : Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.black : Colors.transparent,
                            shape: BoxShape.circle,
                            boxShadow: isSelected
                                ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              )
                            ]
                                : [],
                          ),
                          child: Text(
                            date.day.toString(),
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: isSelected ? 16 : 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),

          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            height: 1.2,
            color: Colors.grey.shade300,
          ),

          /// Job List
          Expanded(
            child: jobs.isEmpty
                ? const Center(
              child: Text(
                "No jobs scheduled.",
                style: TextStyle(color: Colors.grey),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: jobs.length,
              itemBuilder: (context, index) {
                final job = jobs[index];
                return _buildJobCard(job['title']!, job['id']!);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobCard(String title, String id) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => JobDetailsScreen(title: title, id: id),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        shadowColor: Colors.black,
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 6),
                    Text(id,
                        style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 13,
                            fontStyle: FontStyle.italic)),
                  ],
                ),
              ),
            ),
            Container(
              width: 60,
              height: 70,
              decoration: const BoxDecoration(
                color: Colors.purple,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: const Icon(Icons.play_arrow,
                  color: Colors.white, size: 28),
            ),
          ],
        ),
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}