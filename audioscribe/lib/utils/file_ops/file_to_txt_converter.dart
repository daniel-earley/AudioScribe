import 'package:aspose_words_cloud/aspose_words_cloud.dart';
import 'package:audioscribe/utils/file_ops/read_json.dart';
import 'dart:async';
import 'dart:io';

Future<void> convertFileToTxt(String inputFilePath, String outputDirectory) async {
  final json = await readJsonFile('lib/configs/api_keys.json') as Map<String, dynamic>;
  final config = Configuration.fromJson(json);
  final wordsApi = WordsApi(config);

  final doc = (await File(inputFilePath).readAsBytes()).buffer.asByteData();
  final request = ConvertDocumentRequest(doc, 'txt');
  final convert = await wordsApi.convertDocument(request);
  final convertedFile = File('$outputDirectory/${inputFilePath.split('/').last.split('.').first}.txt');
  convertedFile.writeAsBytes(convert.buffer.asInt8List());
}
