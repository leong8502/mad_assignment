import 'package:flutter/material.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Calendar Header
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'September, 18',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () {
                  // Placeholder for calendar dialog
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('September 2025'),
                      content: SizedBox(
                        width: double.maxFinite,
                        child: GridView.count(
                          crossAxisCount: 7,
                          shrinkWrap: true,
                          children: List.generate(30, (index) {
                            final day = index + 1;
                            return Center(
                              child: Text(
                                day.toString(),
                                style: TextStyle(
                                  fontWeight: day == 18 ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        // Weekday Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            Text('Tue'),
            Text('Wed'),
            Text('Thu'),
            Text('Fri'),
            Text('Sat'),
          ],
        ),
        // Date Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            Text('16'),
            Text('17'),
            Text('18', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('19'),
            Text('20'),
          ],
        ),
        // Scheduled Items
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(8.0),
            children: [
              _buildScheduleItem(
                title: 'Car Brake Repair',
                id: 'ID: 5143',
              ),
              const SizedBox(height: 8),
              _buildScheduleItem(
                title: 'Motorcycle Engine Tune-Up',
                id: 'ID: 1734',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleItem({
    required String title,
    required String id,
  }) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(id),
            ],
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              // Placeholder for action
            },
            child: const Icon(Icons.play_arrow, color: Colors.white),
          ),
        ],
      ),
    );
  }
}