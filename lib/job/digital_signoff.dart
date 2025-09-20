import 'dart:io';
import 'package:flutter/material.dart';

class DigitalSignoffPage extends StatefulWidget {
  final List<File> images;
  final String remark;

  const DigitalSignoffPage({
    super.key,
    required this.images,
    required this.remark,
  });

  @override
  State<DigitalSignoffPage> createState() => _DigitalSignoffPageState();
}

class _DigitalSignoffPageState extends State<DigitalSignoffPage> {
  bool isCompleted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Digital Sign-Off"),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------------- Customer Info ----------------
            _buildSection(
              title: "Customer Information",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Name: (to be filled)"),
                  Text("Phone: (to be filled)"),
                  Text("Email: (to be filled)"),
                ],
              ),
            ),

            // ---------------- Service Details ----------------
            _buildSection(
              title: "Service Details",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Job ID: (to be filled)"),
                  const Text("Completed at: (to be filled)"),
                  if (widget.remark.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    const Text("Remark:", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(widget.remark),
                  ],
                ],
              ),
            ),

            // ---------------- Proof Images ----------------
            if (widget.images.isNotEmpty)
              _buildSection(
                title: "Proof Images",
                child: SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.images.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.all(8),
                        child: Image.file(
                          widget.images[index],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                ),
              ),

            // ---------------- Digital Signature ----------------
            _buildSection(
              title: "Digital Signature",
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: const Text("Signature Pad Placeholder"),
              ),
            ),

            const SizedBox(height: 30),

            // ---------------- Complete Button ----------------
            Center(
              child: Column(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCompleted ? Colors.green : Colors.grey,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      if (!isCompleted) {
                        setState(() => isCompleted = true);
                      } else {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text("Confirm"),
                            content: const Text("Confirm job completion and sign-off?"),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text("Cancel")),
                              TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text("Confirm")),
                            ],
                          ),
                        );

                        if (confirm == true && context.mounted) {
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        }
                      }
                    },
                    child: Text(isCompleted ? "Complete" : "Proceed to Complete"),
                  ),

                  if (!isCompleted)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        "Proceed to digital sign-off page",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Reusable Section Widget
  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const Divider(),
          child,
        ],
      ),
    );
  }
}
