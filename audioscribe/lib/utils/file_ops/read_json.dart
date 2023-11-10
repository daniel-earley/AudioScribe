import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

/// Reads a json file
Future<Map> readJsonFile(String filePath) async {
  var input = await File(filePath).readAsString();
  var map = jsonDecode(input);
  return map;
}

Future<String> getApiKey(String keyName) async {
  final jsonString = await rootBundle.loadString('lib/configs/api_keys.json');
  final Map<String, dynamic> apiKeys = json.decode(jsonString);

  if (!apiKeys.containsKey(keyName)) {
    throw Exception('Key not found: $keyName');
  }

  if (apiKeys[keyName] is String) {
    return apiKeys[keyName]; 
  } else {
    return jsonEncode(apiKeys[keyName]);
  }
}