import 'dart:convert';
import 'dart:io';

/// Reads a json file
Future<Map> readJsonFile(String filePath) async {
  var input = await File(filePath).readAsString();
  var map = jsonDecode(input);
  return map;
}

Future<String> readTextFile(String filePath) async {
  try {
    final file = await File(filePath).readAsString();

    return file;
  } catch (e) {
    // If encountering an error, return 0
    return "File Not Found";
  }
}