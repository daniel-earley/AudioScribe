import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:audioscribe/utils/file_ops/camera_service.dart'; // Assuming you have camera_service.dart
import 'package:audioscribe/utils/file_ops/ocr_service.dart';
import 'package:audioscribe/utils/file_ops/book_to_speech.dart'; // Assuming you have ocr_service.dart

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final CameraService _cameraService = CameraService();
  final OCRService _ocrService = OCRService();
  late List<CameraDescription> _cameras;
  String _extractedText = '';
  bool _isCameraInitialized = false;
  XFile? _capturedImage;
  bool _isImageCaptured = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    if (_cameras.isNotEmpty) {
      await _cameraService.initializeCamera(_cameras.first);
      setState(() {
        _isCameraInitialized = true;
      });
    } else {
      print('No camera is available');
    }
  }

  Future<void> _captureImage() async {
    try {
      final image = await _cameraService.captureImage();
      setState(() {
        _capturedImage = image as XFile?;
        _isImageCaptured = true;
      });
    } catch (e) {
      print(e); // Handle the error appropriately
    }
  }

  void _retakeImage() {
    setState(() {
      _isImageCaptured = false;
      _capturedImage = null;
    });
  }

  Future<void> _submitImage() async {
    if (_capturedImage != null) {
      try {
        final text =
            await _ocrService.extractTextFromImage(_capturedImage!.path);
        setState(() {
          _extractedText = text;
        });
        // Call createAudioBook function with the extracted text
        createAudioBook(text, "scan_test");
      } catch (e) {
        print(e); // Handle the error appropriately
      }
    }
  }

  @override
  void dispose() {
    _cameraService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera OCR'),
      ),
      body: _isCameraInitialized
          ? !_isImageCaptured
              ? CameraPreview(_cameraService.controller!)
              : _reviewImage()
          : Center(child: CircularProgressIndicator()),
      floatingActionButton: _isCameraInitialized && !_isImageCaptured
          ? FloatingActionButton(
              child: Icon(Icons.camera),
              onPressed: _captureImage,
            )
          : null,
    );
  }

  Widget _reviewImage() {
    return Column(
      children: [
        Expanded(
          child: Image.file(File(_capturedImage!.path)),
        ),
        if (_extractedText.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(_extractedText),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
              onPressed: _retakeImage,
              child: Text('Retake'),
            ),
            TextButton(
              onPressed: _submitImage,
              child: Text('Submit'),
            ),
          ],
        ),
      ],
    );
  }
}
