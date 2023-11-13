import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:device_info/device_info.dart';
import 'package:audioscribe/services/camera_service.dart';
import 'package:audioscribe/services/ocr_service.dart';
import 'package:audioscribe/utils/file_ops/book_to_speech.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioscribe/pages/uploadBook_page.dart';

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
  bool _isEmulator = false;

  Future<void> _checkIfEmulator() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    setState(() {
      _isEmulator = !androidInfo.isPhysicalDevice;
    });
  }

  @override
  void initState() {
    super.initState();
    _checkIfEmulator().then((_) {
      _initializeCamera();
    });
  }

  Future<void> _initializeCamera() async {
    if (_isEmulator) {
      // If it's an emulator, we don't initialize the camera
      setState(() {
        _isCameraInitialized = true;
      });
    } else {
      // Proceed with normal camera initialization
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
  }

  Future<void> _captureImage() async {
    if (_isEmulator) {
      final byteData = await rootBundle
          .load('lib/images/image_with_text.png'); // Load the asset
      final tempDir =
          await getTemporaryDirectory(); // Get the temporary directory
      final exampleImg =
          File('${tempDir.path}/image_with_text.png'); // Create a new file path
      await exampleImg.writeAsBytes(byteData.buffer.asUint8List(
          byteData.offsetInBytes,
          byteData.lengthInBytes)); // Write the bytes to the file

      setState(() {
        _capturedImage =
            XFile(exampleImg.path); // Create an XFile with the new file path
        _isImageCaptured = true;
      });
    } else {
      // Capture the image from the camera
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

        _navigateToUploadBookPage(context, _extractedText);
        // Call createAudioBook function with the extracted text
        // createAudioBook(_extractedText, "scan_test");
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

  Widget _cameraOrStaticImage() {
    // When running on an emulator, display a static image
    if (_isEmulator) {
      return Image.asset('lib/images/image_with_text.png');
    }
    // When running on a real device, display the camera preview
    return CameraPreview(_cameraService.controller!);
  }

  void _navigateToUploadBookPage(BuildContext context, String text) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => UploadBookPage(text: text),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Text'),
      ),
      body: _isCameraInitialized
          ? !_isImageCaptured
              ? _cameraOrStaticImage()
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
            child: Text("Text was able to be extracted from your scan!"),
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
