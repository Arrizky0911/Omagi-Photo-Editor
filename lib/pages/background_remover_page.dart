import 'package:flutter/material.dart';
import 'dart:io';
import 'package:opencv_core/opencv.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

class BackgroundRemoverPage extends StatefulWidget {
  final String imagePath;

  const BackgroundRemoverPage({Key? key, required this.imagePath})
      : super(key: key);

  @override
  State<BackgroundRemoverPage> createState() => _BackgroundRemoverPageState();
}

class _BackgroundRemoverPageState extends State<BackgroundRemoverPage> {
  late File _image;
  double _brightness = 0.5;

  @override
  void initState() {
    super.initState();
    _image = File(widget.imagePath);
  }

  Future<void> _saveImage() async {
    final result = await ImageGallerySaver.saveFile(_image.path);
    if (result['isSuccess']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image saved successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withOpacity(0.8),
            ),
            child: const Icon(Icons.close, color: Colors.white, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green.withOpacity(0.8),
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 20),
            ),
            onPressed: _saveImage,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Image.file(
                _image,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFE5A4A4), // Coral/pink color
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.wb_sunny_outlined,
                  color: Colors.white,
                  size: 24,
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Colors.white,
                      inactiveTrackColor: Colors.white.withOpacity(0.3),
                      thumbColor: Colors.white,
                      overlayColor: Colors.white.withOpacity(0.1),
                      trackHeight: 2.0,
                    ),
                    child: Slider(
                      value: _brightness,
                      onChanged: (value) {
                        setState(() {
                          _brightness = value;
                          // Implement OpenCV brightness adjustment here
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16), // Safe area bottom padding
        ],
      ),
    );
  }
}
