import 'package:flutter/material.dart';

class MasterPage extends StatefulWidget {
  final Widget body;

  const MasterPage({super.key, required this.body});

  @override
  State<MasterPage> createState() => _MasterPageState();
}

class _MasterPageState extends State<MasterPage> {
  int _selectedIndex = 0; // Track the selected index for navigation

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Explicitly set Scaffold background to white
      appBar: AppBar(
        title: Image.asset('assets/logo.png', height: 30), // Replace with your logo asset
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.purple),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Notifications'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.volume_off),
                        title: const Text('Mute notifications'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.settings),
                        title: const Text('Settings'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.notifications),
                        title: const Text('Notification settings'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.help),
                        title: const Text('Help & resources'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.grey),
              child: Text('Menu'),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Edit Profile'),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Edit Profile'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircleAvatar(child: Text('SL')),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(150, 40),
                          ),
                          onPressed: () {},
                          child: const Text('Upload avatar'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(150, 40),
                          ),
                          onPressed: () {},
                          child: const Text('Edit color'),
                        ),
                        const TextField(decoration: InputDecoration(labelText: 'Full name')),
                        const TextField(decoration: InputDecoration(labelText: 'Email')),
                        const TextField(decoration: InputDecoration(labelText: 'Job title')),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(100, 40),
                              ),
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Done'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () => Navigator.pushReplacementNamed(context, '/login'),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: widget.body, // Main content takes available space
          ),
          Container(
            height: 1, // Thickness of the divider line
            color: Colors.grey[300], // Light grey color for the divider
          ),
        ],
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Colors.white, // Match Scaffold background
            elevation: 0, // Remove shadow for a clean look
            selectedItemColor: Colors.indigoAccent, // Selected item color
            unselectedItemColor: Colors.grey, // Unselected item color
            selectedLabelStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            unselectedLabelStyle: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 12,
            ),
            selectedIconTheme: IconThemeData(
              size: 28,
              color: Colors.indigoAccent,
            ),
            unselectedIconTheme: IconThemeData(
              size: 24,
              color: Colors.grey,
            ),
            showSelectedLabels: true,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed, // Ensure all items are shown
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex, // Track selected item
          onTap: (index) {
            setState(() {
              _selectedIndex = index; // Update selected index
            });
            // Add navigation logic here based on index
            switch (index) {
              case 0:
                Navigator.pushNamed(context, '/dashboard');
                break;
              case 1:
              // Navigate to Schedule
                break;
              case 2:
              // Navigate to Inbox
                break;
              case 3:
              // Navigate to Work List
                break;
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'Schedule',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.email),
              label: 'Inbox',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.check_circle_rounded),
              label: 'Work List',
            ),
          ],
        ),
      ),
    );
  }
}