import 'dart:convert';
import 'dart:io';

/// Reads a json file
Future<Map> readJsonFile(String filePath) async {
  var input = await File(filePath).readAsString();
  var map = jsonDecode(input);
  return map;
}