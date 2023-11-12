import 'package:audioscribe/data_classes/book.dart';
import 'package:audioscribe/utils/database/book_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

Future<void> getBookInformation() async {
	await dotenv.load(fileName: ".env");
	final gutenbergAPIKey = dotenv.env['GUTENBERG_API'];
	const String bookId = '15';
	const String url = 'https://project-gutenberg-api.p.rapidapi.com/books/$bookId';

	// no api key
	if (gutenbergAPIKey!.isEmpty) {
		print("Sorry, you do not have an API Key for Gutenberg");
		return;
	}

	final headers = {
		"Content-Type": "application/json",
		"X-RapidAPI-Key": gutenbergAPIKey,
		"X-RapidAPI-Host": "project-gutenberg-api.p.rapidapi.com"
	};

	try {
		print("fetching book data...");
		final response = await http.get(Uri.parse(url), headers: headers);
		if (response.statusCode == 200) {
			final bookData = json.decode(response.body);
			final int bookId = int.parse(bookData['id']);
			final String title = bookData['title'].replaceAll(RegExp(r'[^\w\s]+'), '').replaceAll(' ', '_');
			final String author = bookData['authors'][0]['name'];
			final String textFileUrl = bookData['formats']['text/plain; charset=us-ascii'] ?? '';
			final String imageUrl = bookData['formats']['image/jpeg'] ?? '';
			String filePath = '';
			String imagePath = '';

			print('Title: $title');
			print('Author: $author');
			print('Text File URL: $textFileUrl');
			print("json obj: $bookData");


			// Define the directory path for storing the book text
			final directory = await getApplicationDocumentsDirectory();
			final bookPath = '${directory.path}/books/text/$title';

			// Create the directory if it doesn't exist
			await Directory(bookPath).create(recursive: true);

			if (imageUrl.isNotEmpty) {
				final imageResponse = await http.get(Uri.parse(imageUrl));
				if (imageResponse.statusCode == 200) {
					imagePath = '${directory.path}/books/covers/$title.jpg';
					final File imageFile = File(imagePath);

					// write the image data to the file
					await imageFile.writeAsBytes(imageResponse.bodyBytes);

					print('Book cover image saved to $imagePath');
				} else {
					print('Failed to load book cover image');
				}
			} else {
				print('Book cover image Url not found');
			}

			// If there's a text file URL, download the book text
			if (textFileUrl.isNotEmpty) {
				final textResponse = await http.get(Uri.parse(textFileUrl));
				if (textResponse.statusCode == 200) {
					filePath = '$bookPath/$title.txt';
					final File file = File(filePath);

					// write the book text to the file
					await file.writeAsString(textResponse.body);

					print('Book text saved to $filePath');
				}
			} else {
				print('Failed to load book information');
			}

			// get database instance
			Book newBook = Book(
				bookId: bookId,
				title: title,
				author: author,
				textFileLocation: textFileUrl.isNotEmpty ? filePath : '',
				imageFileLocation: imageUrl.isNotEmpty ? imagePath : ''
			);

			BookModel bookModel = BookModel();
			// insert book
			await bookModel.insertBook(newBook);
			print('Inserted book with id $bookId');
		}
		print("fetched book data.");
	} catch (e) {
		print('Error occurred while fetching book data: $e');
	}
}
