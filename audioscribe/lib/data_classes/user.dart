import 'book.dart';

class User {
  late String userId;
  late String username;
  late List<Book> bookLibrary;
  late bool loggedIn;

  User(
      {required this.userId,
      required this.username,
      required this.bookLibrary,
      required this.loggedIn});

  Map<String, Object?> toMap() {
    return {'id': userId, 'username': username, 'loggedIn': loggedIn ? 1 : 0};
  }

  User.fromMap(Map map) {
    userId = map['id'];
    username = map['username'];
    bookLibrary = [];
    loggedIn = map['loggedIn'] == 1;
  }

  @override
  String toString() {
    return 'User{userId: $userId, username: $username, bookLibrary: $bookLibrary, loggedIn: $loggedIn}';
  }
}
