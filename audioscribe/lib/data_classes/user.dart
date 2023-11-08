import 'book.dart';

class User {
  late String userId;
  late String username;
  late List<Book> bookLibrary;

  User({required this.userId, required this.username, required this.bookLibrary});

  Map<String, Object?> toMap() {
    return {
      'id': userId,
      'username': username
    };
  }

  User.fromMap(Map map) {
    userId = map['id'];
    username = map['username'];
    bookLibrary = [];
  }

  @override
  String toString() {
    return 'User{userId: $userId, username: $username, bookLibrary: $bookLibrary}';
  }

}