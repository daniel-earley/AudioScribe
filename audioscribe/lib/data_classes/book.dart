class Book {
  late int bookId;
  late String title;
  late String author;
  late String textFileLocation;
  late String audioFileLocation;
  late String imageFileLocation;

  Book({required this.bookId, required this.title, required this.author, this.textFileLocation = '', this.audioFileLocation = '', this.imageFileLocation = ''});

  Map<String, Object?> toMap() {
    return {
      'id': bookId,
      'title': title,
      'author': author,
      'textFileLocation': textFileLocation,
      'audioFileLocation': audioFileLocation,
      'imageFileLocation': imageFileLocation
    };
  }

  Book.fromMap(Map map) {
    bookId = map['id'];
    title = map['title'];
    author = map['author'];
    textFileLocation = map['textFileLocation'];
    audioFileLocation = map['audioFileLocation'];
    imageFileLocation = map['imageFileLocation'];
  }
}