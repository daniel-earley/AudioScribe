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

  /// Retrieves user information with ID
  Future<User?> getUserByID(String id) async {
    final db = await DbUtils.init();

    // Query the database for a user with the given ID
    List<Map> maps =
        await db.query(DbUtils.userDb, where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    } else {
      return null;
    }
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

  /// get all book entries by user id
  Future<List<Map<String, dynamic>>> getUserBookEntries(String userId) async {
    final db = await DbUtils.init();
    final List<Map<String, dynamic>> result = await db.query(
      DbUtils.userBookDb,
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return result;
  }

  /// get all entries from the reference table userBookDb
  Future<List<Map<String, dynamic>>> getAllUserBookEntries() async {
    final db = await DbUtils.init();
    final List<Map<String, dynamic>> result =
        await db.query(DbUtils.userBookDb);
    return result;
  }

  /// get all books that is related to the user, using the reference table userBookDb
  Future<List<Map<String, dynamic>>> getAllUserBooks(String userId) async {
    final db = await DbUtils.init();
    var bookTbl = DbUtils.bookDb;
    var refTbl = DbUtils.userBookDb;

    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT 
        B.userId,
        B.bookId,
        A.title,
        A.author,
        A.textFileLocation,
        A.audioFileLocation,
        A.imageFileLocation
      FROM $bookTbl A
      INNER JOIN $refTbl B ON A.id = B.bookId
      WHERE B.userId = ?
      ''', [userId]);

    return result;
  }

  /// method to check if a book exists in as a bookmark for a user in the DB (checked in the frontend by using len() function)
  Future<List<Map<String, dynamic>>> checkBookIsBookmarked(
      String userId, int bookId) async {
    final db = await DbUtils.init();
    var bookTbl = DbUtils.bookDb;
    var refTbl = DbUtils.userBookDb;

    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT 
        B.userId,
        B.bookId
      FROM $bookTbl A
      INNER JOIN $refTbl B ON A.id = B.bookId
      WHERE B.userId = ? AND B.bookId = ?
      ''', [userId, bookId]);

    return result;
  }

  /// method to remove bookmark on a specified book by its given id
  Future deleteBookmark(String userId, int bookId) async {
    final db = await DbUtils.init();

    // delete row in ref table
    int result = await db.delete(DbUtils.userBookDb,
        where: 'userId = ? AND bookId = ?', whereArgs: [userId, bookId]);

    // returns num rows affected by operation
    return result;
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
          conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }

  /// method to insert a book
  Future<void> bookmarkBookForUser(String userId, int bookId) async {
    final db = await DbUtils.init();
    await db.insert(
      DbUtils.userBookDb,
      {
        // dont need id since its auto gen'd
        'userId': userId,
        'bookId': bookId,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  /// Method for updating user logged in status
  Future<void> updateLoggedInStatus(String userId, bool loggedIn) async {
    final db = await DbUtils.init();

    await db.update(DbUtils.userDb, {'loggedIn': loggedIn ? 1 : 0},
        where: 'id = ?', whereArgs: [userId]);
  }

  /// Delete an user from the database
  Future<int> deleteUserWithId(String id) async {
    final db = await DbUtils.init();
    return db.delete(DbUtils.userDb, where: 'id = ?', whereArgs: [id]);
  }

  /// deletes all books from bookDb (for testing)
  Future<void> deleteAllBooks() async {
    final db = await DbUtils.init();
    final List<Map> result = await db.rawQuery('''
      DELETE
      FROM ${DbUtils.bookDb}
      ''');
  }

  /// deletes all book references (for testing)
  Future<void> deleteAllBooksRef() async {
    final db = await DbUtils.init();
    final List<Map> result = await db.rawQuery('''
      DELETE
      FROM ${DbUtils.userBookDb}
      ''');
  }
}
