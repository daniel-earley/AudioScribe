import 'book.dart';

class LibrivoxBook {
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

  LibrivoxBook({
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
  this.bookType = 'API'
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
      'bookType': bookType
    };
  }

  factory LibrivoxBook.fromMap(Map<String, dynamic> map) {
    return LibrivoxBook(
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
    );
  }

  // Factory constructor to create a Librivox object from a Map
  factory LibrivoxBook.fromJson(Map<String, dynamic> json) {
    String imageUrl = "https://archive.org/services/get-item-image.php?identifier=${json['identifier']}";
    return LibrivoxBook(
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