import 'package:flutter/material.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About This App'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomRight,
            end: Alignment.topLeft,
            colors: [Colors.lightBlueAccent, Colors.white],
          ),
        ),
        child: SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  kToolbarHeight,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.black),
                              SizedBox(width: 8),
                              Text(
                                'Greenstem Mechanicsync',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'A simple and user-friendly app designed to make your daily tasks easier and more convenient.',
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 32),
                          const Row(
                            children: [
                              Icon(Icons.build, color: Colors.black),
                              SizedBox(width: 8),
                              Text(
                                'Version',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '1.0.0',
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 32),
                          const Row(
                            children: [
                              Icon(Icons.group, color: Colors.black),
                              SizedBox(width: 8),
                              Text(
                                'Developers',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Leong Chun Xiang\nAlex Leow Shi Hao\nChew Jian Le\nGun Yu Xing',
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 32),
                          const Row(
                            children: [
                              Icon(Icons.email, color: Colors.black),
                              SizedBox(width: 8),
                              Text(
                                'Contact',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'GMsupport@email.com',
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 32),
                          const Row(
                            children: [
                              Icon(Icons.security, color: Colors.black),
                              SizedBox(width: 8),
                              Text(
                                'Privacy & Security',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'We value your privacy. All your data is kept secure and used only to improve your experience.',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}