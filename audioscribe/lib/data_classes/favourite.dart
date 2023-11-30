import 'package:audioscribe/data_classes/book.dart';
import 'package:audioscribe/data_classes/librivox_book.dart';
import 'package:audioscribe/utils/database/book_model.dart';
import 'package:audioscribe/utils/database/cloud_storage_manager.dart';

class Favourite {
	late int bookId;

	Favourite({
		required this.bookId
	});

	Future<bool> favouriteBook(int bookId) async {
		try {
			BookModel bookModel = BookModel();
			// get user id
			String userId = getCurrentUserId();

			List<Map<String, dynamic>> bookData = await bookModel.getBookById(bookId);
			if (bookData.isEmpty) {
				print("Book with ID $bookId not found.");
				return false;
			}

			// convert bookid to book object
			LibrivoxBook book = LibrivoxBook.fromMap(bookData.first);

			// update book favourite status
			book.isFavourite = 1;

			// favourite a book in firestore
			await favouriteBookFirestore(userId, bookId);

			// favourite a book in sqlite
			await bookModel.updateLibrivoxBook(book);

			print("book $bookId added as favourite");

			return true;
		} catch (e) {
			print('$e');
			return false;
		}
	}

	Future<bool> unFavouriteBook(int bookId) async {
		try {
			BookModel bookModel = BookModel();
			// get user id
			String userId = getCurrentUserId();

			List<Map<String, dynamic>> bookData = await bookModel.getBookById(bookId);
			if (bookData.isEmpty) {
				print("Book with ID $bookId not found.");
				return false;
			}

			// convert bookid to book object
			LibrivoxBook book = LibrivoxBook.fromMap(bookData.first);

			// update book favourite status
			book.isFavourite = 0;

			// favourite book
			await removeFavouriteBookFirestore(userId, bookId);

			// favourite a book in sqlite
			await bookModel.updateLibrivoxBook(book);

			print("book $bookId removed as favourite");

			return false;
		} catch (e) {
			print('$e');
			return true;
		}
	}

}