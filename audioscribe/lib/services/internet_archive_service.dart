import 'package:audioplayers/audioplayers.dart';
import 'package:audioscribe/data_classes/book.dart';
import 'package:http/http.dart';
import 'dart:convert';

const _metadata = "https://archive.org/metadata/";
const _commonParams = "q=collection:(librivoxaudio)&fl=runtime,avg_rating,num_reviews,title,description,identifier,creator,date,downloads,subject,item_size";

const _latestBooksApi = "https://archive.org/advancedsearch.php?$_commonParams&sort[]=addeddate desc&output=json";

const _mostDownloaded = "https://archive.org/advancedsearch.php?$_commonParams&sort[]=downloads desc&rows=10&page=1&output=json";
const query="title:(secret tomb) AND collection:(librivoxaudio)";

class ArchiveApiProvider {
	Client client = Client();

	Future<List<Map<String, dynamic>>> fetchBooks(int offset, int limit) async {
		final response = await client.get(Uri.parse("$_latestBooksApi&rows=$limit&page=${offset/limit + 1}"));
		Map resJson = json.decode(response.body);

		// Cast each element to Map<String, dynamic>
		List<Map<String, dynamic>> allbooks = (resJson['response']['docs'] as List)
			.map((item) => item as Map<String, dynamic>)
			.where((item) => !item['identifier'].toString().contains('.poem'))
			.toList();

		// print('books: ${allbooks.map((item) => item['title'])}');
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
				audioUrls.add({ 'file': url, 'chapter': chapter });
			}
		}

		return audioUrls;
	}

	Future<List<Map<String, dynamic>>> fetchTopDownloads() async {
		final response = await client.get(Uri.parse(_mostDownloaded));
		Map resJson = json.decode(response.body);

		List<Map<String, dynamic>> allbooks = (resJson['response']['docs'] as List)
			.map((item) => item as Map<String, dynamic>)
			.toList();

		return allbooks;
	}

  	@override
  	Future<void> setOnPlayer(AudioPlayer player) {
  	  	// TODO: implement setOnPlayer
  	  	throw UnimplementedError();
  	}

}