import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(80.0), // Circular border
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(80.0), // Consistent when enabled
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(80.0), // Consistent when focused
                  borderSide: const BorderSide(color: Colors.indigoAccent), // Match theme
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Today',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6, // Constrain ListView height
              child: ListView(
                children: const [
                  ListTile(
                    leading: Icon(Icons.check_circle, color: Colors.red),
                    title: Text('Project 1'),
                    subtitle: Text('Status: Completed | Due Date: Creator'),
                  ),
                  ListTile(
                    leading: Icon(Icons.check_circle, color: Colors.blue),
                    title: Text('Project 2'),
                    subtitle: Text('Status: In Progress | Due Date: Creator'),
                  ),
                  ListTile(
                    leading: Icon(Icons.check_circle, color: Colors.green),
                    title: Text('Project 3'),
                    subtitle: Text('Status: Completed | Due Date: Creator'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}