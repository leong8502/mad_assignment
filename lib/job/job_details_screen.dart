import 'package:flutter/material.dart';

/// ============================
/// Job Details Screen
/// ============================
class JobDetailsScreen extends StatelessWidget {
  final String title;
  final String id;

  const JobDetailsScreen({super.key, required this.title, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.purple,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFF3F4F6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.purple.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "$title\n$id",
                  style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),

              const Text("Customer Details",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.person, size: 40, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("Name: Ahmad bin Ismail",
                            style: TextStyle(fontSize: 16)),
                        Text("Contact: 012-345 6789",
                            style: TextStyle(fontSize: 16)),
                        Text("Vehicle info: Toyota Camry, 2018, Sedan",
                            style: TextStyle(fontSize: 16)),
                        Text("Registration: WKL 4567",
                            style: TextStyle(fontSize: 16)),
                        Text("VIN: JT2BF22K1W0123456",
                            style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              const Text("Job Description",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              const Text(
                  "Customer reports squeaking brakes and reduced braking efficiency."),

              const SizedBox(height: 16),
              const Text("Requested Services",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              const Text(
                  "Inspect and replace brake pads, check brake rotors, perform brake fluid flush."),

              const SizedBox(height: 16),
              const Text("Due Date",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const Text("06 Dec 2025"),

              const SizedBox(height: 16),
              const Text("Estimated Completion Time",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const Text("3 hours"),

              const SizedBox(height: 16),
              const Text("Assigned Parts",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const Text(
                  "• Brake Pads (Front)\n• Brake Fluid\n• Brake Rotors (Front)"),

              const SizedBox(height: 16),
              const Text("Service History",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const Text("15/03/2024: Oil change and tire rotation\n"
                  "10/09/2023: Brake inspection, no issues\n"
                  "22/01/2023: Battery replacement"),

              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    _showConfirmationDialog(context);
                  },
                  child: const Text("Accept",
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Acceptance"),
        content: const Text("Are you sure you want to accept this task?"),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.grey, // Added background for visibility
              foregroundColor: Colors.white, // Affects text + icon color
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.white), // Ensures text color is white
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white, // Affects text + icon color
            ),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Job accepted successfully!")),
              );
              Navigator.pop(context);
            },
            child: const Text(
              "Accept",
              style: TextStyle(color: Colors.white), // Ensures text color is white
            ),
          ),
        ],
      ),
    );
  }
}