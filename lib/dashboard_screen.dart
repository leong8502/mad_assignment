import 'package:flutter/material.dart';
import 'master_page.dart';

class DashboardScreen extends StatelessWidget { // Changed to StatelessWidget since state is now in MasterPage
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MasterPage(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TextField(decoration: InputDecoration(hintText: 'Search...', prefixIcon: Icon(Icons.search))),
            const SizedBox(height: 10),
            const Text('Today', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Expanded(
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