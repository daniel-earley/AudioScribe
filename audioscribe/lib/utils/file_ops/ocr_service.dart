import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';

class OCRService {
  Future<String> extractTextFromImage(String imagePath) async {
    final text = await FlutterTesseractOcr.extractText(imagePath);
    return text;
  }
}
