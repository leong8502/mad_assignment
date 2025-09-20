import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final List<File> _images = [];
  final TextEditingController _remarkController = TextEditingController();
  final int maxPhotos = 5;

  final ImagePicker _picker = ImagePicker();

  // pick image from gallery
  Future<void> _pickImage() async {
    if (_images.length >= maxPhotos) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("You can upload max $maxPhotos photos")),
      );
      return;
    }

    final XFile? pickedFile =
    await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _images.add(File(pickedFile.path));
      });
    }
  }

  void _submit() {
    String remark = _remarkController.text;

    // create result map
    final result = {
      "images": _images,
      "remark": remark,
    };

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Submitted successfully")),
    );

    Navigator.pop(context, result); // ✅ return data to previous page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text("Upload Photos"),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Remarks :",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _remarkController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: "e.g. No issue found",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Upload box
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: double.infinity,
                        height: 120,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _images.isEmpty
                            ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.image,
                                size: 40, color: Colors.grey),
                            SizedBox(height: 5),
                            Text("Tap to upload"),
                          ],
                        )
                            : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _images.length,
                          itemBuilder: (context, index) {
                            return Stack(
                              children: [
                                Container(
                                  margin: const EdgeInsets.all(8),
                                  child: Image.file(
                                    _images[index],
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _images.removeAt(index);
                                      });
                                    },
                                    child: const CircleAvatar(
                                      radius: 12,
                                      backgroundColor: Colors.black54,
                                      child: Icon(Icons.close,
                                          size: 16,
                                          color: Colors.white),
                                    ),
                                  ),
                                )
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text("${_images.length} / $maxPhotos"),
                    ),
                    const SizedBox(height: 12),

                    Center(
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text("Upload"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
