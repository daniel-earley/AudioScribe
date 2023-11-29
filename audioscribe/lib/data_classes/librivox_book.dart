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
  this.imageFileLocation = ''});

  Book toBook({int audioFileIndex = 0}) {
    return Book(
      bookId: identifier.hashCode,
      title: title,
      author: author,
      imageFileLocation: imageFileLocation,
      audioFileLocation: audioFileIndex == 0 ? '' : audioFiles[audioFileIndex]
    );
  }
}