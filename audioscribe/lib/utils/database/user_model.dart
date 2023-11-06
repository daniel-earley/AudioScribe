import 'dart:math';

import 'package:audioscribe/data_classes/book.dart';
import 'db_utils.dart';
import 'book_model.dart';
import 'dart:async';
import 'package:audioscribe/data_classes/user.dart';
import 'package:sqflite/sqflite.dart';

class UserModel {
  /// Add a new user to the database.
  /// Should only be used when creating a user as the book list will not be added.
  Future<int> insertUser(User user) async {
    final db = await DbUtils.init();
    return db.insert(
      DbUtils.userDb,
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.fail,
    );
  }

  /// Retrieves all the users from the database including the user's book library
  Future<List<User>> getAllUsers() async {
    final db = await DbUtils.init();
    final List userMaps = await db.query(DbUtils.userDb);
    final BookModel bookModel = BookModel();
    List<User> users = [];
    for (Map map in userMaps) {
      users.add(await () async {
        User user = User.fromMap(map);
        user.bookLibrary = await bookModel.getAllBooksWithUser(user);
        return user;
      }());
    }
    return users;
  }

  /// Retrieves all the books that are in a user's library from the database
  Future<List<User>> getAllUsersWithBook(Book book) async {
    final db = await DbUtils.init();
    final List<User> users = [];
    final List userMap = await db.rawQuery(
        'SELECT ${DbUtils.userDb}.id, ${DbUtils.userDb}.username '
            'FROM ${DbUtils.userDb} INNER JOIN ${DbUtils.userBookDb} ON ${DbUtils.userDb}.id=${DbUtils.userBookDb}.userId '
            'WHERE bookId = ${book.bookId}');
    for (Map map in userMap) {
      users.add(User.fromMap(map));
    }
    return users;
  }

  /// This will add the book list to the database.
  Future updateUserBookLibrary(User user) async {
    final db = await DbUtils.init();
    for (Book book in user.bookLibrary) {
      db.insert(
        DbUtils.userBookDb,
        {
          'id': Random().nextInt(1000000),
          'userId': user.userId,
          'bookId': book.bookId
        },
        conflictAlgorithm: ConflictAlgorithm.ignore
      );
    }
  }

  /// Delete an user from the database
  Future<int> deleteUserWithId(int id) async {
    final db = await DbUtils.init();
    return db.delete(
      DbUtils.userDb,
      where: 'id = ?',
      whereArgs: [id]
    );
  }
}
