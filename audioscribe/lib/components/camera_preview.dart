import 'dart:io';
import 'package:audioscribe/app_constants.dart';
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
	// zoom control
	double _baseZoom = 1.0;
	double _currentZoomLevel = 1.0;
	double _maxZoomLevel = 100.0;
	FlashMode _flashMode = FlashMode.off;
	bool canDisplayGrid = false;

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
			_cameras = await availableCameras();
			if (_cameras.isNotEmpty) {
				await _cameraService.initializeCamera(_cameras.first);
				// set max zoom level
				_maxZoomLevel = await _cameraService.controller!.getMaxZoomLevel();
				// set flash mode
				_cameraService.controller!.setFlashMode(_flashMode);
				setState(() {
					_isCameraInitialized = true;
					_currentZoomLevel = 1.0;
				});
			} else {
				print('No camera is available');
			}
		}
	}

	void _zoomCamera(double zoomFactor) async {
		if (zoomFactor <= _maxZoomLevel && zoomFactor >= 1.0) {
			await _cameraService.controller!.setZoomLevel(zoomFactor);
			setState(() {
				_currentZoomLevel = zoomFactor;
			});
		}
	}

	void _toggleFlash() {
		setState(() {
			if (_flashMode == FlashMode.off) {
				_flashMode = FlashMode.auto;
			} else if (_flashMode == FlashMode.auto) {
				_flashMode = FlashMode.always;
			} else {
				_flashMode = FlashMode.off;
			}

			// Set the new flash mode
			_cameraService.controller!.setFlashMode(_flashMode);
		});
		print('flash mode: ${_flashMode}');
	}

	void _toggleGrid() {
		setState(() {
		  	canDisplayGrid = !canDisplayGrid;
		});
	}


	Future<void> _captureImage() async {
		if (_isEmulator) {
			final byteData = await rootBundle
				.load('lib/images/image_with_text.png'); // Load the asset
			final tempDir =
			await getTemporaryDirectory(); // Get the temporary directory
			final exampleImg = File('${tempDir.path}/image_with_text.png');
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
				if (_cameraService.controller != null && _cameraService.controller!.value.isInitialized) {

					final image = await _cameraService.captureImage();
					// After capturing the image, reset the flash mode

					setState(() {
						// Current issue: type 'String' is not a subtype of type 'XFile?' in type cast
						// _capturedImage = image as XFile?;
						_capturedImage = XFile(image);
						_isImageCaptured = true;
					});

					await _cameraService.controller!.setFlashMode(FlashMode.off);
					setState(() {
					  	_flashMode = FlashMode.off;
					});

				}
			} catch (e) {
				print(e);
			}
		}
	}

	void _retakeImage() async {
		await _cameraService.controller!.setFlashMode(FlashMode.off);

		setState(() {
			_isImageCaptured = false;
			_capturedImage = null;
			_flashMode = FlashMode.off;
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

				if (mounted) _navigateToUploadBookPage(context, _extractedText);
			} catch (e) {
				print(e);
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
		// return CameraPreview(_cameraService.controller!);
		return GestureDetector(
			onScaleStart: (ScaleStartDetails details) {
				_baseZoom = _currentZoomLevel; // Store the starting zoom level
			},
			onScaleUpdate: (ScaleUpdateDetails details) {
				// Calculate the new zoom level
				double newZoom = _baseZoom * details.scale;

				// Clamp the zoom level between 1.0 and max zoom
				newZoom = newZoom.clamp(1.0, _maxZoomLevel);

				_zoomCamera(newZoom); // Apply the new zoom level
			},
			child: Stack(
				children: [
					CameraPreview(_cameraService.controller!),
					if(canDisplayGrid) GridOverlay(height: MediaQuery.of(context).size.height * 0.75)
				],
			),
		);
	}

	void _navigateToUploadBookPage(BuildContext context, String text) {
		Navigator.of(context).push(MaterialPageRoute(
			builder: (context) => UploadBookPage(text: text),
		));
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: AppColors.secondaryAppColor,
			appBar: AppBar(
				title: const Text('Scan Text'),
				backgroundColor: AppColors.primaryAppColor,
			),
			body: _isCameraInitialized
				? !_isImageCaptured
					? _cameraOrStaticImage()
					: _reviewImage()
				: const Center(child: CircularProgressIndicator(),
			),
			floatingActionButton: _isCameraInitialized && !_isImageCaptured
			? Stack(
				alignment: Alignment.bottomCenter,
				children: [
					Align(
						alignment: Alignment.bottomLeft,
						child: Padding(
							padding: const EdgeInsets.only(left: 50.0, bottom: 10.0),
							child: Align(
								alignment: Alignment.bottomLeft,
								child: FloatingActionButton(
									onPressed: _toggleGrid,
									backgroundColor: Colors.grey,
									child: Icon(canDisplayGrid ? Icons.grid_3x3 : Icons.hide_source),
								),
							),
						),
					),
					SizedBox(
						height: 75,
						width: 75,
						child: FloatingActionButton(
							onPressed: _captureImage,
							backgroundColor: Colors.grey,

							child: const Icon(Icons.circle, size: 65.0),
						),
					)
				],
			)
			: null,
			floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
		);
	}

	Widget _reviewImage() {
		return Column(
			children: [
				Expanded(
					child: Image.file(File(_capturedImage!.path)),
				),
				if (_extractedText.isNotEmpty)
					const Padding(
						padding: EdgeInsets.all(8.0),
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


class GridOverlay extends StatelessWidget {
	final int gridCount; // Number of grid lines
	final double height;

	const GridOverlay({
		super.key,
		this.gridCount = 3,
		this.height = 0,
	}); // Default to 3x3 grid

	@override
	Widget build(BuildContext context) {
		return LayoutBuilder(
			builder: (context, constraints) {
				return CustomPaint(
					painter: GridPainter(gridCount: gridCount),
					size: Size(constraints.maxWidth, height),
				);
			},
		);
	}
}


class GridPainter extends CustomPainter {
	final int gridCount;

	GridPainter({required this.gridCount});

	@override
	void paint(Canvas canvas, Size size) {
		var paint = Paint()
			..color = Colors.white.withOpacity(0.5) // Grid line color, slightly transparent
			..style = PaintingStyle.stroke
			..strokeWidth = 2; // Grid line width

		double horizontalStep = size.height / gridCount;
		double verticalStep = size.width / gridCount;

		for (int i = 1; i < gridCount; ++i) {
			// Vertical lines
			canvas.drawLine(
				Offset(verticalStep * i, 0),
				Offset(verticalStep * i, size.height),
				paint,
			);
			// Horizontal lines
			canvas.drawLine(
				Offset(0, horizontalStep * i),
				Offset(size.width, horizontalStep * i),
				paint,
			);
		}
	}

	@override
	bool shouldRepaint(CustomPainter oldDelegate) => false;
}
