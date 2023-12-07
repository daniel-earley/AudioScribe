import 'dart:convert';
import 'dart:io';
import 'package:audioscribe/utils/file_ops/make_directory.dart';
import 'package:flutter_tts/flutter_tts.dart';

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

  String audioBookDirectoryPath =
      await createNewDirectory("AudioScribeAudioBooks", name);

  // Create filename with full path
  String fileExtension = Platform.isAndroid ? ".wav" : ".caf";

  // Check for chapters
  if (checkChapters(text)) {
    // Chapters are found
    createChapters(text, name, audioBookDirectoryPath, fileExtension);
  } else {
    // No chapters are found
    String fileNameWithPath =
        "$audioBookDirectoryPath/$name$fileExtension".replaceAll(' ', '_');

    // Save tts to file
    int result = await flutterTts.synthesizeToFile(text, fileNameWithPath);
    if (result == 1) {
      // Save metadata
      Map<String, dynamic> audioBookJson = {
        "title": name,
        "audioFilePath": fileNameWithPath
      };

      // Convert the JSON object to a string
      String jsonString = jsonEncode(audioBookJson);

      // Save the JSON string to a file in the same directory
      String jsonFileName = "$audioBookDirectoryPath/metadata.json";
      File(jsonFileName).writeAsString(jsonString);

      // return fileNameWithPath;
    } else {
      return null;
    }
  }

  return audioBookDirectoryPath;
}

createChapters(
    String text, String title, String path, String fileExtension) async {
  // Separate chapters
  Map<int, Chapter> chapters = await parseChapters(text);
  List<Map<String, dynamic>> chapterMetadata = [];
  List<Future> waitingTasks = []; // A list of type future can be waited for

  // Synthesize each string to it's own file
  chapters.forEach((number, chapter) async {
    String chapterNumber = "Chapter $number";
    String chapterFileName =
        "$path/${chapterNumber}_${chapter.title.trim()}$fileExtension"
            .replaceAll(' ', '_');

    // Need this to finish before metadata is created
    var task = flutterTts
        .synthesizeToFile(chapter.contents, chapterFileName)
        .then((result) {
      if (result == 1) {
        chapterMetadata.add({
          "chapterNumber": chapterNumber,
          "chapterTitle": chapter.title,
          "audioFilePath": chapterFileName
        });
      }
    });
    waitingTasks.add(task);
  });

  // Need the files and metadata to finish being created before creating the json file
  await Future.wait(waitingTasks);

  // Create the JSON object
  Map<String, dynamic> audioBookJson = {
    "title": title,
    "chapters": chapterMetadata
  };

  // Convert the JSON object to a string
  String jsonString = jsonEncode(audioBookJson);

  // Save the JSON string to a file in the same directory
  String jsonFileName = "$path/metadata.json";
  File(jsonFileName).writeAsString(jsonString);

  // Save tts to file
  chapters.clear();
}
