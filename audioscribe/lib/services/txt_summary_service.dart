import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:audioscribe/utils/file_ops/read_json.dart';

class TxtSummarizerService {
  /// Summarizes a txt file into a given number of sentences.
  static Future<String> txtSummary(String filePath, int numberOfSentences) async {
    var client = http.Client();
    var fileText = await (File(filePath).readAsString());
    var url = Uri.https(
        'meaningcloud-summarization-v1.p.rapidapi.com',
        '/summarization-1.0',
        {'sentences': '$numberOfSentences', 'txt': fileText});
    var response = await client.get(url, headers: {
      "Accept": 'application/json',
      'X-RapidAPI-Key': await getApiKey('txtSummarizer'),
      'X-RapidAPI-Host': 'meaningcloud-summarization-v1.p.rapidapi.com'
    });

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['summary'];
    } else {
      return 'Could not summarize with response code ${response.statusCode}, ${response.body}';
    }
  }

  /// summarizes text into a given number of sentences
  static Future<String> SummarizeText(String content) async {
      var client = http.Client();
      var requestQuery = Uri.https(
          'meaningcloud-summarization-v1.p.rapidapi.com',
          '/summarization-1.0',
          { "sentences": '${2}', "txt": content }
      );
      var response = await client.get(requestQuery, headers: {
          "Accept": 'application/json',
          'X-RapidAPI-Key': await getApiKey('txtSummarizer'),
          'X-RapidAPI-Host': 'meaningcloud-summarization-v1.p.rapidapi.com'
      });

      print('summarizer response: ${jsonDecode(response.body)['summary']}');

      if (response.statusCode == 200) {
          return jsonDecode(response.body)['summary'];
      } else {
          return 'Text summarization could not be performed: ${response.statusCode}, ${response.body}';
      }
  }
}
