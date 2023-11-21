import 'dart:io';
import 'package:audioscribe/utils/file_ops/read_json.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

// 1. open and read text file -> read_json.dart has a read text file now
// 2. use flutterTts.synthesizeToFile to create an audio file from input text
// Need to properly credit this dude: https://stackoverflow.com/a/69879595
FlutterTts flutterTts = FlutterTts();

Future createAudioBook(String text, String name) async {
  // Setup flutter tts
  await flutterTts.setLanguage("en-US");
  await flutterTts.setSpeechRate(0.55);
  await flutterTts.setVolume(1.0);
  await flutterTts.setPitch(1.0);
  await flutterTts.setVoice(
    {"name": "en-us-x-tpf-local", "locale": "en-US"},
  );

  // Request Perms - don't need yet
  // if (Platform.isAndroid) {
  //   var status = await Permission.storage.status;
  //   if (!status.isGranted) {
  //     await Permission.storage.request();
  //   }
  // }

  // Get the external storage directory
  Directory? externalDirectory = await getExternalStorageDirectory();
  String? externalPath = externalDirectory?.path;

  // Create a directory called "AudioScribeAudioBooks" inside the external directory
  String audioBookDirectoryPath = "$externalPath/AudioScribeAudioBooks";
  Directory audioBookDirectory = Directory(audioBookDirectoryPath);

  if (!await audioBookDirectory.exists()) {
    await audioBookDirectory.create(
        recursive: true); // This will create the directory if it doesn't exist
  }

  // Create filename with full path
  String fileExtension = Platform.isAndroid ? ".wav" : ".caf";
  String fileNameWithPath = "$audioBookDirectoryPath/$name$fileExtension";
  String fileNameWithUnderscores = fileNameWithPath.replaceAll(' ', '_');
  // Save tts to file
  int result = await flutterTts.synthesizeToFile(text, fileNameWithUnderscores);
  if (result == 1) {
    print("File created: $fileNameWithUnderscores");
    return fileNameWithUnderscores;
  } else {
    print("Error: File not created.");
    return null;
  }
}
