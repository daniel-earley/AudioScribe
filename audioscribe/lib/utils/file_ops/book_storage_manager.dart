import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:typed_data';
import 'package:http/http.dart' as http;

Future<String> saveFile(String filename, String content) async {
	final directory = await getApplicationDocumentsDirectory();
	final file = File('${directory.path}/$filename');
	print(file);
	return file.path;
}

/// Download image from web URL and returns file stored on device
Future<String?> downloadAndSaveImage(String imageUrl, String imageName) async {
	try {
		final response = await http.get(Uri.parse(imageUrl));
		if (response.statusCode == 200) {
			final Uint8List imageData = response.bodyBytes;
			final directory = await getApplicationDocumentsDirectory();
			final imagePath = p.join(directory.path, imageName);
			final imageFile = File(imagePath);
			await imageFile.writeAsBytes(imageData);
			return imagePath;
		}
	} catch (e) {
		print("Error downloading image: $e");
	}
	return null;
}

String getImageName(String imagePath) {
	int startIndex = imagePath.indexOf('identifier=');
	String identifier = "";
	if (startIndex != -1) {
		startIndex += 'identifier='.length;
		identifier = imagePath.substring(startIndex);
	}
	return identifier;
}