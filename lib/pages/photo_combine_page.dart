import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:image_gallery_saver/image_gallery_saver.dart';

class PhotoCombinePage extends StatefulWidget {
  const PhotoCombinePage({super.key});

  @override
  State<PhotoCombinePage> createState() => _PhotoCombinePageState();
}

class _PhotoCombinePageState extends State<PhotoCombinePage> {
  File? _image1;
  File? _image2;
  String _operationType = 'Add';

  Future<void> _pickImage(int imageNumber) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        if (imageNumber == 1) {
          _image1 = File(image.path);
        } else {
          _image2 = File(image.path);
        }
      });
    }
  }

  Future<void> _processImages() async {
    if (_image1 == null || _image2 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both images')),
      );
      return;
    }
    
    // Implement OpenCV processing here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _pickImage(1),
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _image1 == null
                          ? const Icon(Icons.add_photo_alternate, size: 50)
                          : Image.file(_image1!, fit: BoxFit.cover),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _pickImage(2),
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _image2 == null
                          ? const Icon(Icons.add_photo_alternate, size: 50)
                          : Image.file(_image2!, fit: BoxFit.cover),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                DropdownButton<String>(
                  value: _operationType,
                  isExpanded: true,
                  items: ['Add', 'Subtract', 'Multiply', 'Divide']
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _operationType = newValue!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _processImages,
                  child: const Text('Process Images'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}