import 'dart:io';
import 'package:audioscribe/utils/file_ops/read_json.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

// 1. open and read text file -> read_json.dart has a read text file now
// 2. use flutterTts.synthesizeToFile to create an audio file from input text
// Need to properly credit this dude: https://stackoverflow.com/a/69879595
FlutterTts flutterTts = FlutterTts();

Future createAudioBook(String text, String filePath, String name) async {
  // Setup flutter tts
  await flutterTts.setLanguage("en-US");
  await flutterTts.setSpeechRate(1.0);
  await flutterTts.setVolume(1.0);
  await flutterTts.setPitch(1.0);
  await flutterTts.setVoice(
    {"name": "en-us-x-tpf-local", "locale": "en-US"},
  );

  // Request Perms
  if (Platform.isAndroid) {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
  }

  // Determine the directory to save the file
  Directory directory = await getApplicationDocumentsDirectory();
  String dirPath = directory.path;
  if (filePath.isNotEmpty) {
    dirPath = filePath;
  }

  // Create filename
  var fileExt = Platform.isAndroid ? ".wav": ".caf";
  String fileName = "$dirPath/$name$fileExt";

  // Save tts to file
  await flutterTts.synthesizeToFile(text, fileName).then((value) async {
    if (value == 1) {
      print("File created: $fileName");
      return fileName;
    } else {
      print("Error: File not created.");
      throw "Error: File not created.";
    }
  });


}
