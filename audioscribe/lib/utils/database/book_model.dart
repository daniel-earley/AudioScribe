import 'package:audioscribe/data_classes/book.dart';
import 'db_utils.dart';
import 'dart:async';
import 'package:audioscribe/data_classes/user.dart';
import 'package:sqflite/sqflite.dart';

class BookModel {
  /// Insert a book into the database
  Future<int> insertBook(Book book) async {
    final db = await DbUtils.init();
    return db.insert(
      DbUtils.bookDb,
      book.toMap(),
      conflictAlgorithm: ConflictAlgorithm.fail,
    );
  }

  /// Retrieves all the books from the database
  Future<List<Book>> getAllBooks() async {
    final db = await DbUtils.init();
    final List bookMaps = await db.query(DbUtils.bookDb);
    List<Book> books = [];
    for (Map map in bookMaps) {
      books.add(Book.fromMap(map));
    }
    return books;
  }

  /// Get book information by a given ID
  Future<List<Map<String, dynamic>>> getBookById(int bookId) async {
    final db = await DbUtils.init();
    final List<Map<String, dynamic>> bookMaps = await db.query(
      DbUtils.bookDb,
      where: 'id = ?',
      whereArgs: [bookId]
    );

    return bookMaps;
  }

  /// Retrieves all the books that is linked to a user
  Future<List<Book>> getAllBooksWithUser(User user) async {
    final db = await DbUtils.init();
    final List<Book> books = [];
    final List bookMap = await db.rawQuery(
        'SELECT ${DbUtils.bookDb}.id, ${DbUtils.bookDb}.title, ${DbUtils.bookDb}.author, ${DbUtils.bookDb}.textFileLocation, ${DbUtils.bookDb}.audioFileLocation, ${DbUtils.bookDb}.imageFileLocation '
        'FROM ${DbUtils.bookDb} INNER JOIN ${DbUtils.userBookDb} ON ${DbUtils.bookDb}.id=${DbUtils.userBookDb}.bookId '
        'WHERE userId = ${user.userId}');
    for (Map map in bookMap) {
      books.add(Book.fromMap(map));
    }
    return books;
  }

  /// Delete a book from the database
  Future<int> deleteBookWithId(int id) async {
    final db = await DbUtils.init();
    return db.delete(DbUtils.bookDb, where: 'id = ?', whereArgs: [id]);
  }
}
