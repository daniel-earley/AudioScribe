import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:audioscribe/utils/file_ops/read_json.dart';

class TxtSummarizerService {
  /// summarize text using GPT
  static Future<String> summarizeTextGPT(String content) async {
    final APIKEY = await getApiKey('openAI');
    var url = Uri.parse(
        'https://api.openai.com/v1/engines/text-davinci-003/completions');

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $APIKEY',
    };

    var requestBody = jsonEncode({
      "prompt":
          "Summarize the following text in 2 concise sentences, similar to a summarizing a book: $content",
      "max_tokens": 150
    });

    try {
      var response = await http.post(url, headers: headers, body: requestBody);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        String text = data['choices'][0]['text'].trim();

        String cleannedText = text.replaceAll(RegExp(r'[^\w\s\.,!?;:]'), '');
        return cleannedText;
      } else {
        return 'Failed to summarize text: ${response.statusCode}, ${response.body}';
      }
    } catch (e) {
      return 'An error occurred: $e';
    }
  }
}
