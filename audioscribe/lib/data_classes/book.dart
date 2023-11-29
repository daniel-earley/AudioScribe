class Book {
  late int bookId;
  late String title;
  late String author;
  late String textFileLocation;
  late String audioFileLocation;
  late String imageFileLocation;

  // to differentiate between api book
  late String bookType;

  Book({required this.bookId, required this.title, required this.author, this.textFileLocation = '', this.audioFileLocation = '', this.imageFileLocation = '', this.bookType = ''});

  Map<String, Object?> toMap() {
    return {
      'id': bookId,
      'title': title,
      'author': author,
      'textFileLocation': textFileLocation,
      'audioFileLocation': audioFileLocation,
      'imageFileLocation': imageFileLocation,
      'bookType': bookType
    };
  }

  Book.fromMap(Map map) {
    bookId = map['id'] as int? ?? 0; // Default to 0 or another appropriate value if null.
    title = map['title'] as String? ?? 'Unknown Title'; // Provide a default string if null.
    author = map['author'] as String? ?? 'Unknown Author';
    textFileLocation = map['textFileLocation'] as String? ?? '';
    audioFileLocation = map['audioFileLocation'] as String? ?? '';
    imageFileLocation = map['imageFileLocation'] as String? ?? '';
    bookType = map['bookType'] as String? ?? '';
  }


  @override
  String toString() {
    return 'Book(bookId: $bookId, title: "$title", author: "$author", textFileLocation: "$textFileLocation", audioFileLocation: "$audioFileLocation", imageFileLocation: "$imageFileLocation")';
  }
}