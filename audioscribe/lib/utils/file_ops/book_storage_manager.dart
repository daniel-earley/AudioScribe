import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:typed_data';
import 'package:http/http.dart' as http;

import 'file_to_txt_converter.dart';

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

Future<String> uploadBook() async {
	// Use FilePicker to let the user select a text file
	FilePickerResult? result = await FilePicker.platform.pickFiles(
		type: FileType.custom,
		allowedExtensions: ['txt', 'pdf'],
	);

	if (result != null) {
		// Get the selected file
		PlatformFile file = result.files.first;
		String fileContent = '';
		if (p.extension(file.path!) == ".txt") {
			fileContent = await File(file.path!).readAsString();
		} else {
			// PDF book found
			// Create a directory called "AudioScribeTextBooks" inside the external directory
			Directory? externalDirectory = await getExternalStorageDirectory();
			String? externalPath = externalDirectory?.path;
			String BookDirectoryPath = "$externalPath/AudioScribeTextBooks";
			Directory BookDirectory = Directory(BookDirectoryPath);

			if (!await BookDirectory.exists()) {
				await BookDirectory.create(
					recursive:
					true); // This will create the directory if it doesn't exist
			}
			String fileName = p.basenameWithoutExtension(file.name);
			await convertFileToTxt(file.path!, '$BookDirectoryPath');
			fileContent = await File('$BookDirectoryPath/$fileName.txt').readAsString();
		}

		return fileContent;
	} else {
		// User canceled the picker
		print("No file selected");
		return '';
	}
}