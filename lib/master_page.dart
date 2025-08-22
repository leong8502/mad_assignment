import 'package:flutter/material.dart';

class MasterPage extends StatefulWidget {
  final Widget body;
  final String title; // Dynamic title for the current screen

  const MasterPage({super.key, required this.body, required this.title});

  @override
  State<MasterPage> createState() => _MasterPageState();
}

class _MasterPageState extends State<MasterPage> {
  int _selectedIndex = 0; // Track the selected index for navigation

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.grey, size: 24),
          actionsIconTheme: IconThemeData(color: Colors.grey, size: 24),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(widget.title),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications, color: Colors.black),
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
                          leading: const Icon(Icons.notifications),
                          title: const Text('Notification settings'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      contentPadding: EdgeInsets.zero,
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 100, // Larger size for the dialog
                            backgroundImage: const AssetImage('assets/profile.png'),
                            backgroundColor: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 30,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: const CircleAvatar(
                  radius: 15,
                  backgroundImage: AssetImage('assets/profile.png'),
                  backgroundColor: Colors.grey,
                ),
              ),
            ),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: const AssetImage('assets/drawer.png'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.3), // Darken the image
                      BlendMode.darken,
                    ),
                  ),
                ),
                child: const Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Edit Profile'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Scaffold(
                        appBar: AppBar(
                          title: const Text('Edit Profile'),
                          leading: IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        body: SafeArea(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Profile image with plus icon
                                Center(
                                  child: Stack(
                                    alignment: Alignment.bottomRight,
                                    children: [
                                      CircleAvatar(
                                        radius: 40,
                                        backgroundImage: const AssetImage(
                                          'assets/profile.png',
                                        ),
                                        backgroundColor: Colors.grey,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          // Add your image upload logic here
                                          print('Upload new profile image');
                                        },
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            color: Colors.blue,
                                            shape: BoxShape.circle,
                                          ),
                                          padding: const EdgeInsets.all(4),
                                          child: const Icon(
                                            Icons.add,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                                // Full Name
                                const Text(
                                  'Full name',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: TextEditingController(text: 'John'),
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Email
                                const Text(
                                  'Email',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: TextEditingController(
                                    text: 'John@gmail.com',
                                  ),
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Job Type (non-editable)
                                const Text(
                                  'Job Type',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: TextEditingController(
                                    text: 'Developer',
                                  ),
                                  enabled: false, // Makes the field non-editable
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
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
                                        minimumSize: const Size(80, 40),
                                      ),
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Done'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
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
                leading: const Icon(Icons.help),
                title: const Text('Help & resources'),
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () => Navigator.pushReplacementNamed(context, '/login'),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(child: widget.body),
            Container(height: 1, color: Colors.grey[300]),
          ],
        ),
        bottomNavigationBar: Theme(
          data: Theme.of(context).copyWith(
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Colors.white,
              elevation: 0,
              selectedItemColor: Colors.indigoAccent,
              unselectedItemColor: Colors.grey,
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
              unselectedIconTheme: IconThemeData(size: 24, color: Colors.grey),
              showSelectedLabels: true,
              showUnselectedLabels: true,
              type: BottomNavigationBarType.fixed,
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
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
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today),
                label: 'Schedule',
              ),
              BottomNavigationBarItem(icon: Icon(Icons.email), label: 'Inbox'),
              BottomNavigationBarItem(
                icon: Icon(Icons.check_circle_rounded),
                label: 'Work List',
              ),
            ],
          ),
        ),
      ),
    );
  }
}