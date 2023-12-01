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

	/// Get user collection book (defined by UPLOAD type, favourited or bookmarked)
	Future<List<LibrivoxBook>> getCollectionBooks() async {
		final db = await DbUtils.init();
		final List<Map<String, dynamic>> bookMaps = await db.query(
			DbUtils.bookDb,
			where: "isFavourite = ? OR isBookmark = ?",
			whereArgs: [1, 1]
		);

		List<LibrivoxBook> books = bookMaps.map((map) => LibrivoxBook.fromMap(map)).toList();

		return books;
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

	/// GET book information by book type
	Future<List<Book>> getBookByType(String bookType) async {
		final db = await DbUtils.init();
		final List<Map<String, dynamic>> bookMaps = await db.query(
			DbUtils.bookDb,
			where: 'bookType = ?', // This is your WHERE clause
			whereArgs: [bookType], // Replace with the actual bookType value
		);

		List<Book> books = bookMaps.map((bookMap) => Book.fromMap(bookMap)).toList();

		return books;
	}

	/// GET favourited book
	Future<List<LibrivoxBook>> getFavouritedBooks(int isFavourited) async {
		final db = await DbUtils.init();
		final List<Map<String, dynamic>> bookMaps = await db.query(
			DbUtils.bookDb,
			where: 'isFavourite = ?', // This is your WHERE clause
			whereArgs: [isFavourited], // Replace with the actual bookType value
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

	/// Update the book row in the database for a given librivox Book object
	Future<int> updateLibrivoxBook(LibrivoxBook book) async {
		final db = await DbUtils.init();
		return db.update(
			DbUtils.bookDb,
			{
				'title': book.title,
				'author': book.author,
				'date': book.date,
				'identifier': book.identifier,
				'runtime': book.runtime,
				'description': book.description,
				'rating': book.rating,
				'numberReviews': book.numberReviews,
				'downloads': book.downloads,
				'size': book.size,
				'imageFileLocation': book.imageFileLocation,
				'bookType': book.bookType,
				'isFavourite': book.isFavourite,
				'isBookmark': book.isBookmark
			},
			where: 'id = ?',
			whereArgs: [book.id]
		);
	}

	/// Delete a book from the database
	Future<int> deleteBookWithId(int id) async {
		final db = await DbUtils.init();
		return db.delete(DbUtils.bookDb, where: 'id = ?', whereArgs: [id]);
	}
}
