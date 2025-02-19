import 'package:audioplayers/audioplayers.dart';
import 'package:audioscribe/data_classes/librivox_book.dart';
import 'package:http/http.dart';
import 'dart:convert';

const _metadata = "https://archive.org/metadata/";
const _commonParams =
    "q=collection:(librivoxaudio)&fl=runtime,avg_rating,num_reviews,title,description,identifier,creator,date,downloads,subject,item_size";

const _latestBooksApi =
    "https://archive.org/advancedsearch.php?$_commonParams&sort[]=addeddate desc&output=json";

const _mostDownloaded =
    "https://archive.org/advancedsearch.php?$_commonParams&sort[]=downloads desc&rows=10&page=1&output=json";
const query = "title:(secret tomb) AND collection:(librivoxaudio)";

/// Deval Panchal
/// Credits for code for this class was retrieved from (https://github.com/lohanidamodar/flutter_audiobooks_app)
/// With the help of this person open source audiobook app we were able to decipher its usage thanks
/// to the fetch links provided.
/// The code was modified to match the structure of our code, but the general idea for retrieving books
/// from a free service was from this person.

class ArchiveApiProvider {
  Client client = Client();

  Future<List<Map<String, dynamic>>> fetchBooks(int offset, int limit) async {
    final response = await client.get(
        Uri.parse("$_latestBooksApi&rows=$limit&page=${offset / limit + 1}"));
    Map resJson = json.decode(response.body);

    // Cast each element to Map<String, dynamic>
    List<Map<String, dynamic>> allbooks = (resJson['response']['docs'] as List)
        .map((item) => item as Map<String, dynamic>)
        .where((item) => !item['identifier'].toString().contains('.poem'))
        .toList();

    return allbooks;
  }

  Future<List<Map<String, String>>> fetchAudioFiles(String? bookId) async {
    final response = await client.get(Uri.parse("$_metadata/$bookId/files"));
    Map resJson = json.decode(response.body);

    List<dynamic> files = resJson['result'] ?? [];
    List<Map<String, String>> audioUrls = [];

    for (var file in files) {
      // using file['format'] == LibriVox Apple Audiobook, will give preview listen
      if (file['format'] == '64Kbps MP3') {
        String url = "https://archive.org/download/$bookId/${file['name']}";
        String chapter = file['title'] ?? 'Unknown title';
        audioUrls.add({'file': url, 'chapter': chapter});
      }
    }

    return audioUrls;
  }

  Future<List<LibrivoxBook>> fetchTopDownloads() async {
    final response = await client.get(Uri.parse(_mostDownloaded));
    Map resJson = json.decode(response.body);

    List<LibrivoxBook> allbooks = (resJson['response']['docs'] as List)
        .map((item) => LibrivoxBook.fromJson(item))
        .toList();

    return allbooks;
  }

  @override
  Future<void> setOnPlayer(AudioPlayer player) {
    // TODO: implement setOnPlayer
    throw UnimplementedError();
  }
}
