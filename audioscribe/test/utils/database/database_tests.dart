import 'package:audioscribe/data_classes/book.dart';
import 'package:audioscribe/data_classes/user.dart';
import 'package:test/test.dart';

import 'package:audioscribe/utils/database/user_model.dart';
import 'package:audioscribe/utils/database/book_model.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  test('database ops work as expected', () async {

    databaseFactory = databaseFactoryFfi;

    final BookModel bookModel = BookModel();
    final UserModel userModel = UserModel();
    User userA = User(userId: 1234, username: "George1212", bookLibrary: []);
    User userB = User(userId: 1235, username: "Alex2121", bookLibrary: []);

    Book bookA = Book(bookId: 1, title: "How to use a db", author: 'Anon1');
    Book bookB = Book(bookId: 3, title: "How to Not use a db", author: 'Anon2');
    Book bookC =
        Book(bookId: 2, title: "How to Really use a db", author: 'Anon3');

    userModel.insertUser(userA);
    userModel.insertUser(userB);

    bookModel.insertBook(bookA);
    bookModel.insertBook(bookB);
    bookModel.insertBook(bookC);

    userA.bookLibrary.add(bookA);
    userA.bookLibrary.add(bookB);
    userB.bookLibrary.add(bookB);
    userB.bookLibrary.add(bookC);

    userModel.updateUserBookLibrary(userA);
    userModel.updateUserBookLibrary(userB);

    List<User> users = await userModel.getAllUsers();

    for (var user in users) {
      print(user.userId);
      print(user.username);
      for (Book book in user.bookLibrary) {
        print(book.bookId);
        print(book.title);
        print(book.author);
      }
    }

    userModel.deleteUserWithId(userA.userId);
    userModel.deleteUserWithId(userB.userId);

    bookModel.deleteBookWithId(bookA.bookId);
    bookModel.deleteBookWithId(bookB.bookId);
    bookModel.deleteBookWithId(bookC.bookId);


    expect(true, true);
  });
}
