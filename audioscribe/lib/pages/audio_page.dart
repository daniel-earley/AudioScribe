import 'package:audioscribe/components/bookInfoText.dart';
import 'package:audioscribe/components/image_container.dart';
import 'package:audioscribe/data_classes/bookmark.dart';
import 'package:audioscribe/pages/book_details.dart';
import 'package:audioscribe/pages/main_page.dart';
import 'package:audioscribe/utils/interface/snack_bar.dart';
import 'package:flutter/material.dart';

class AudioPlayerPage extends StatefulWidget {
	final int bookId;
	final String imagePath;
	final String bookTitle;
	final String bookAuthor;
	final bool isBookmarked;
	final Function(bool) onBookmarkChanged;

	const AudioPlayerPage({
		Key? key,
		required this.bookId,
		required this.imagePath,
		required this.bookTitle,
		required this.bookAuthor,
		required this.isBookmarked,
		required this.onBookmarkChanged
	}) : super(key : key);

	@override
	_AudioPlayerPage createState() => _AudioPlayerPage();
}

class _AudioPlayerPage extends State<AudioPlayerPage> {
	late bool isBookBookmarked = widget.isBookmarked;
	late Bookmark bookmarkManager;

	@override
	void initState() {
		super.initState();
		bookmarkManager = Bookmark(
			bookTitle: widget.bookTitle,
			bookAuthor: widget.bookAuthor,
		);
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: const Color(0xFF303030),
			body: _buildAudioPlayerPage()
		);
	}

	/// handles adding bookmark for book
	void handleAddBookmark(int bookId) async {
		bool _isBookBookmarked = await bookmarkManager.addBookmark(bookId);
		if (_isBookBookmarked) {
			setState(() {
				isBookBookmarked = true;
			});
			widget.onBookmarkChanged(true);
			if(mounted) {
				SnackbarUtil.showSnackbarMessage(context, '${widget.bookTitle} has been bookmarked', Colors.white);
			}
		}
	}

	/// handles removing bookmark for book
	void handleRemoveBookmark(int bookId) async {
		bool _isBookBookmarked = await bookmarkManager.removeBookmark(bookId);
		if (!_isBookBookmarked) {
			setState(() {
				isBookBookmarked = false;
			});
			widget.onBookmarkChanged(false);
			if (mounted) {
				SnackbarUtil.showSnackbarMessage(context, 'Bookmark removed', Colors.white);
			}
		}
	}

	Widget _buildAudioPlayerPage() {
		return Stack(
			children: [
				SafeArea(
					child: Padding(
						padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
						child: Column(
							children: [
								// Header section
								Row(
									mainAxisAlignment: MainAxisAlignment.spaceBetween,
									children: [
										// back arrow
										IconButton(
											icon: const Icon(Icons.arrow_back, color: Colors.white, size: 35.0),
											onPressed: () {
												Navigator.of(context).pop(); // Close the current page
											},
										),

										// title
										const Text(
											'Now Playing',
											textAlign: TextAlign.center,
											style: TextStyle(color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.w400)
										),

										// bookmark
										IconButton(
											icon: Icon(isBookBookmarked ? Icons.bookmark : Icons.bookmark_outline, color: Colors.white, size: 42.0),
											onPressed: () {
												if (isBookBookmarked) {
													// print('Removing bookmark for ${widget.bookId}');
													handleRemoveBookmark(widget.bookId);
												} else {
													// print('Adding bookmark for ${widget.bookId}');
													handleAddBookmark(widget.bookId);
												}
											},
										),
									],
								),

								// Image
								ImageContainer(imagePath: widget.imagePath),

								// book title
								const SizedBox(height: 20.0,),
								PrimaryInfoText(text: widget.bookTitle, color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.w600),

								// book author
								const SizedBox(height: 10.0),
								PrimaryInfoText(text: widget.bookAuthor, color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.w400)
							],
						)
					)
				),
			],
		);
	}
}