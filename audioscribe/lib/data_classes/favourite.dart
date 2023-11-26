import 'package:audioscribe/utils/database/cloud_storage_manager.dart';

class Favourite {
	late int bookId;


	Favourite({
		required this.bookId
	});

	Future<bool> favouriteBook(int bookId) async {
		try {
			// get user id
			String userId = getCurrentUserId();

			// favourite a book
			await favouriteBookFirestore(userId, bookId);

			print("book $bookId added as favourite");

			return true;
		} catch (e) {
			print('$e');
			return false;
		}
	}

	Future<bool> unFavouriteBook(int bookId) async {
		try {
			// get user id
			String userId = getCurrentUserId();

			// favourite book
			await removeFavouriteBookFirestore(userId, bookId);

			print("book $bookId removed as favourite");

			return false;
		} catch (e) {
			print('$e');
			return true;
		}
	}
}