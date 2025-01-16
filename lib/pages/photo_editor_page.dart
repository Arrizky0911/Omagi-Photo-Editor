// ignore_for_file: avoid_print

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:opencv_core/opencv.dart' as cv;
import 'dart:io';
import 'package:image_gallery_saver/image_gallery_saver.dart';

class PhotoEditorPage extends StatefulWidget {
  final String imagePath;

  const PhotoEditorPage({Key? key, required this.imagePath}) : super(key: key);

  @override
  State<PhotoEditorPage> createState() => _PhotoEditorPageState();
}

class _PhotoEditorPageState extends State<PhotoEditorPage> {
  late File _image;
  late cv.Mat _imageMat;
  String _selectedTool = '';
  double _rotation = 0;
  double _contrast = 1.0;
  double _brightness = 0;
  String _selectedRatio = '1:1';

  @override
  void initState() {
    super.initState();
    _image = File(widget.imagePath);
    _imageMat = cv.imread(widget.imagePath);
  }

  @override
  void dispose() {
    _imageMat.dispose();
    super.dispose();
  }

  Future<void> _saveImage() async {
    try {
      final bytes = cv.imencode(".png", _imageMat).$2;
      final result = await ImageGallerySaver.saveImage(bytes);
      if (result['isSuccess']) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image saved successfully!')),
          );
        }
      }
    } catch (e) {
      print('Error saving image: $e');
    }
  }

  // Future<void> _cropImage(BuildContext context) async {
  //   try {
  //     // This is a simplified example - you'd want to get actual crop dimensions from UI
  //     final cropRect = Rect.fromLTWH(0, 0, _imageMat.cols / 2, _imageMat.rows / 2);

  //     final cropped = _imageMat.submat(
  //       cv.Range(cropRect.top.toInt(), (cropRect.top + cropRect.height).toInt()),
  //       cv.Range(cropRect.left.toInt(), (cropRect.left + cropRect.width).toInt())
  //     );

  //     setState(() {
  //       _imageMat.dispose(); // Dispose old mat
  //       _imageMat = cropped;
  //     });
  //   } catch (e) {
  //     print('Error cropping image: $e');
  //   }
  // }

  Future<void> _applyFilters() async {
    try {
      var processed = _imageMat.clone();

      // Apply contrast
      processed = await cv.convertScaleAbsAsync(processed,
          alpha: _contrast, beta: _brightness * 100);

      setState(() {
        _imageMat.dispose();
        _imageMat = processed;
      });
    } catch (e) {
      print('Error applying filters: $e');
    }
  }

  Future<void> _applyEffect(String effect) async {
    try {
      late cv.Mat processed;

      switch (effect) {
        case 'sepia':
          processed = await cv.cvtColorAsync(_imageMat, cv.COLOR_BGR2GRAY);
          processed = await cv.applyColorMapAsync(processed, cv.COLORMAP_BONE);
          break;
        case 'grayscale':
          processed = await cv.cvtColorAsync(_imageMat, cv.COLOR_BGR2GRAY);
          break;
        case 'blur':
          processed = await cv.gaussianBlurAsync(_imageMat, (15, 15), 0);
          break;
        default:
          processed = _imageMat.clone();
      }

      setState(() {
        _imageMat.dispose();
        _imageMat = processed;
      });
    } catch (e) {
      print('Error applying effect: $e');
    }
  }

  Future<void> _addText(String text, Offset position) async {
    try {
      var processed = _imageMat.clone();
      cv.putText(
        processed,
        text,
        cv.Point(position.dx.toInt(), position.dy.toInt()),
        cv.FONT_HERSHEY_SIMPLEX,
        1.0,
        cv.Scalar.all(255), // White color using Scalar
      );

      setState(() {
        _imageMat.dispose();
        _imageMat = processed;
      });
    } catch (e) {
      print('Error adding text: $e');
    }
  }

  Future<void> _rotateImage() async {
    try {
      final center = cv.Point2f(_imageMat.cols / 2, _imageMat.rows / 2);
      final rotMatrix = cv.getRotationMatrix2D(center, _rotation, 1.0);

      final rotated = await cv.warpAffineAsync(
        _imageMat,
        rotMatrix,
        (_imageMat.cols, _imageMat.rows),
      );

      setState(() {
        _imageMat.dispose();
        _imageMat = rotated;
      });
    } catch (e) {
      print('Error rotating image: $e');
    }
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
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Colors.black),
            onPressed: _saveImage,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Image.memory(
                cv.imencode(".png", _imageMat).$2,
                gaplessPlayback: true,
              ),
            ),
          ),
          if (_selectedTool == 'filters') _buildFilterControls(),
          if (_selectedTool == 'effect') _buildEffectControls(),
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildToolButton(Icons.crop, 'Crop', () => {}),
                _buildToolButton(Icons.rotate_right, 'Rotate', () {
                  setState(() => _rotation += 90);
                  _rotateImage();
                }),
                _buildToolButton(Icons.filter, 'Filters',
                    () => setState(() => _selectedTool = 'filters')),
                _buildToolButton(Icons.wb_sunny, 'Effect',
                    () => setState(() => _selectedTool = 'effect')),
                _buildToolButton(Icons.text_fields, 'Text',
                    () => _addText('Sample Text', const Offset(50, 50))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSlider('Contrast', _contrast, 0.0, 2.0, (value) {
            setState(() => _contrast = value);
            _applyFilters();
          }),
          _buildSlider('Brightness', _brightness, -1.0, 1.0, (value) {
            setState(() => _brightness = value);
            _applyFilters();
          }),
        ],
      ),
    );
  }

  Widget _buildEffectControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildEffectButton('Normal', () => _applyEffect('normal')),
            _buildEffectButton('Sepia', () => _applyEffect('sepia')),
            _buildEffectButton('Grayscale', () => _applyEffect('grayscale')),
            _buildEffectButton('Blur', () => _applyEffect('blur')),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider(String label, double value, double min, double max,
      ValueChanged<double> onChanged) {
    return Column(
      children: [
        Text(label),
        Slider(
          value: value,
          min: min,
          max: max,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildToolButton(IconData icon, String label, VoidCallback onPressed) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon),
          onPressed: onPressed,
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildEffectButton(String label, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}
