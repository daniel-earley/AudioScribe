import 'package:audioscribe/data_classes/book.dart';
import 'package:audioscribe/data_classes/librivox_book.dart';
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
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Insert a Librivox book into the database
  Future<int> insertAPIBook(LibrivoxBook book) async {
    final db = await DbUtils.init();
    return db.insert(
      DbUtils.bookDb,
      book.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
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


  /// GET book information by book type
  Future<List<LibrivoxBook>> getBooksByType(String bookType) async {
    final db = await DbUtils.init();
    final List<Map<String, dynamic>> bookMaps = await db.query(
      DbUtils.bookDb,
      where: 'bookType = ?', // This is your WHERE clause
      whereArgs: [bookType], // Replace with the actual bookType value
    );

    List<LibrivoxBook> books = bookMaps.map((bookMap) => LibrivoxBook.fromMap(bookMap)).toList();

    return books;
  }

  /// GET book information by book title
  Future<List<LibrivoxBook>> getBooksByTitle(String bookTitle) async {
    final db = await DbUtils.init();
    final List<Map<String, dynamic>> bookMaps = await db.query(
      DbUtils.bookDb,
      where: 'title = ?', // This is your WHERE clause
      whereArgs: [bookTitle], // Replace with the actual bookType value
    );

    List<LibrivoxBook> books = bookMaps.map((bookMap) => LibrivoxBook.fromMap(bookMap)).toList();

    return books;
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

  /// Update the book row in the database for a given Book object
  Future<int> updateBook(Book book) async {
    final db = await DbUtils.init();
    return db.update(DbUtils.bookDb, book.toMap());
  }

  /// Delete a book from the database
  Future<int> deleteBookWithId(int id) async {
    final db = await DbUtils.init();
    return db.delete(DbUtils.bookDb, where: 'id = ?', whereArgs: [id]);
  }
}
