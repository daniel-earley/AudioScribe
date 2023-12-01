import 'book.dart';
import 'dart:math';

class LibrivoxBook {
	int id;
	String title;
	String author;
	String date;
	String identifier;
	String runtime;
	String description;
	double rating;
	int numberReviews;
	int downloads;
	int size;
	List<String> audioFiles = [];
	String imageFileLocation;
	String bookType;
	int isFavourite;
	int isBookmark;
	String audioFileLocation;

	LibrivoxBook({
		required this.id,
		required this.title,
		required this.author,
		required this.date,
		required this.identifier,
		required this.runtime,
		required this.description,
		required this.rating,
		required this.numberReviews,
		required this.downloads,
		required this.size,
		this.imageFileLocation = '',
		this.bookType = 'API',
		this.isFavourite = 0,
		this.isBookmark = 0,
		this.audioFileLocation = ''
	});

	Book toBook({int audioFileIndex = 0}) {
		return Book(
			bookId: identifier.hashCode,
			title: title,
			author: author,
			imageFileLocation: imageFileLocation,
			audioFileLocation: audioFileIndex == 0 ? '' : audioFiles[audioFileIndex],
			bookType: 'API'
		);
	}

	Map<String, dynamic> toMap() {
		return {
			'id': id,
			'title': title,
			'author': author,
			'date': date,
			'identifier': identifier,
			'runtime': runtime,
			'description': description,
			'rating': rating,
			'numberReviews': numberReviews,
			'downloads': downloads,
			'size': size,
			'imageFileLocation': imageFileLocation,
			'bookType': bookType,
			'isFavourite': isFavourite,
			'isBookmark': isBookmark,
			'audioFileLocation': audioFileLocation,
		};
	}

	factory LibrivoxBook.fromMap(Map<String, dynamic> map) {
		return LibrivoxBook(
			id: map['id'],
			title: map['title'] ?? 'Unknown title',
			author: map['author'] ?? 'Unknown author',
			date: map['date'] ?? 'No date',
			identifier: map['identifier'] ?? 'No identifier',
			runtime: map['runtime'] ?? 'Unknown runtime',
			description: map['description'] ?? 'No description',
			rating: map['rating']?.toDouble() ?? 0.0,
			numberReviews: map['numberReviews'] ?? 0,
			downloads: map['downloads'] ?? 0,
			size: map['size'] ?? 0,
			imageFileLocation: map['imageFileLocation'] ?? '',
			bookType: map['bookType'] ?? '',
			isFavourite: map['isFavourite'] ?? 0,
			isBookmark: map['isBookmark'] ?? 0,
			audioFileLocation: map['audioFileLocation'] ?? '',
		);
	}

	// Factory constructor to create a Librivox object from a Map
	factory LibrivoxBook.fromJson(Map<String, dynamic> json) {
		String imageUrl = "https://archive.org/services/get-item-image.php?identifier=${json['identifier']}";
		int generateUniqueId() {
			var now = DateTime.now();
			var random = Random();

			return now.millisecondsSinceEpoch + random.nextInt(1000);
		}
		return LibrivoxBook(
			id: generateUniqueId(),
			title: json['title'] ?? 'Unknown title',
			author: json['creator'] ?? 'Librivox',
			date: json['date'] ?? 'No date',
			identifier: json['identifier'] ?? 'No identifier',
			runtime: json['runtime'] ?? 'Unknown runtime',
			description: json['description'] ?? 'No description',
			rating: (json['avg_rating'] ?? 0).toDouble(),
			numberReviews: json['num_reviews'] ?? 0,
			downloads: json['downloads'] ?? 0,
			size: json['item_size'] ?? 0,
			imageFileLocation: imageUrl
		);
	}





}