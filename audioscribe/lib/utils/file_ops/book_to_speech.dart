import 'dart:convert';
import 'dart:io';
import 'package:audioscribe/utils/file_ops/file_to_txt_converter.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path_provider/path_provider.dart';

import '../../data_classes/chapter.dart';

// 1. open and read text file -> read_json.dart has a read text file now
// 2. use flutterTts.synthesizeToFile to create an audio file from input text

FlutterTts flutterTts = FlutterTts();

// Iftikhar, A (Nov. 8, 2021) Answer to Is there any way to save flutter_tts file to firebase storage?[Source Code]. https://stackoverflow.com/a/69879595
Future createAudioBook(String text, String name) async {
  // Setup flutter tts
  await flutterTts.setLanguage("en-US");
  await flutterTts.setSpeechRate(0.55);
  await flutterTts.setVolume(1.0);
  await flutterTts.setPitch(1.0);
  await flutterTts.setVoice(
    {"name": "en-us-x-tpf-local", "locale": "en-US"},
  );

  // Get the external storage directory
  Directory? externalDirectory = await getExternalStorageDirectory();
  String? externalPath = externalDirectory?.path;

  // Create a directory called "AudioScribeAudioBooks/<book title>" with no spaces
  String audioBookDirectoryPath =
      "$externalPath/AudioScribeAudioBooks/$name".replaceAll(' ', '_');
  Directory audioBookDirectory = Directory(audioBookDirectoryPath);

  if (!await audioBookDirectory.exists()) {
    await audioBookDirectory.create(
        recursive: true); // This will create the directory if it doesn't exist
  }

  // Create filename with full path
  String fileExtension = Platform.isAndroid ? ".wav" : ".caf";

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Separate chapters
  Map<int, Chapter> chapters = await parseChapters(text);
  List<Map<String, dynamic>> chapterMetadata = [];

  // Synthesize each string to it's own file
  chapters.forEach((number, chapter) async {
    String chapterNumber = "Chapter $number";
    String chapterFileName =
        "$audioBookDirectoryPath/${chapterNumber}_${chapter.title}$fileExtension"
            .replaceAll(' ', '_');
    int result =
        await flutterTts.synthesizeToFile(chapter.contents, chapterFileName);

    if (result == 1) {
      print("$chapterNumber file created: $chapterFileName");

      chapterMetadata.add({
        "chapterNumber": chapterNumber,
        "chapterTitle": chapter.title,
        "audioFilePath": chapterFileName
      });
    } else {
      print("Error: $chapterNumber file not created.");
    }
  });

  // Create the JSON object
  Map<String, dynamic> audioBookJson = {
    "title": name,
    "chapters": chapterMetadata
  };

  // Convert the JSON object to a string
  String jsonString = jsonEncode(audioBookJson);

  // Save the JSON string to a file in the same directory
  String jsonFileName = "$audioBookDirectoryPath/${name}_metadata.json";
  File(jsonFileName).writeAsString(jsonString);

  print("Metadata file created: $jsonFileName");

  // Save tts to file
  chapters.clear();
  // Return the path to the audiobook files
  return audioBookDirectoryPath;
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
}
