import 'package:camera/camera.dart';

class CameraService {
  CameraController? controller;

  Future<void> initializeCamera(CameraDescription cameraDescription) async {
    controller = CameraController(cameraDescription, ResolutionPreset.medium);
    await controller!.initialize();
  }

  Future<String> captureImage() async {
    if (!controller!.value.isInitialized) {
      throw Exception('Controller is not initialized');
    }
    final image = await controller!.takePicture();
    return image.path;
  }

  void dispose() {
    controller?.dispose();
  }
}
