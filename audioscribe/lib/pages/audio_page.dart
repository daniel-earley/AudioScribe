import 'package:audioscribe/components/bookInfoText.dart';
import 'package:audioscribe/components/image_container.dart';
import 'package:audioscribe/data_classes/bookmark.dart';
import 'package:audioscribe/pages/book_details.dart';
import 'package:audioscribe/pages/home_page.dart';
import 'package:audioscribe/pages/main_page.dart';
import 'package:audioscribe/utils/interface/animated_fab.dart';
import 'package:audioscribe/utils/interface/snack_bar.dart';
import 'package:audioscribe/services/audio_player_service.dart';
import 'package:flutter/material.dart';

class AudioPlayerPage extends StatefulWidget {
	final int bookId;
	final String imagePath;
	final String bookTitle;
	final String bookAuthor;
	final bool isBookmarked;
	final String audioBookPath;
	final Function(bool) onBookmarkChanged;

	const AudioPlayerPage(
		{Key? key,
			required this.bookId,
			required this.imagePath,
			required this.bookTitle,
			required this.bookAuthor,
			required this.isBookmarked,
			required this.audioBookPath,
			required this.onBookmarkChanged})
		: super(key: key);

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
			appBar: AppBar(
				title: Text('Now Playing ${widget.bookTitle}'),
				backgroundColor: const Color(0xFF524178),
			),
			backgroundColor: const Color(0xFF303030),
			body: _buildAudioPlayerPage(),
			floatingActionButton: AnimatedFAB(
				listItems: const [
					Text('Home', style: TextStyle(color: Colors.white)),
					Text('Second Item', style: TextStyle(color: Colors.white)),
				],
				onTapActions: [
					() => Navigator.popUntil(context, (Route<dynamic> route) => route.isFirst),
					() => print('Second Item Tapped'),
				],
			),
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
			if (mounted) {
				SnackbarUtil.showSnackbarMessage(
					context, '${widget.bookTitle} has been bookmarked', Colors.white);
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
				SnackbarUtil.showSnackbarMessage(
					context, 'Bookmark removed', Colors.white);
			}
		}
	}

	Widget _buildAudioPlayerPage() {
		return Stack(
			children: [
				SafeArea(
					child: Padding(
						padding: const EdgeInsets.symmetric(
							horizontal: 10.0, vertical: 10.0),
						child: Column(
							children: [
								// Image
								ImageContainer(imagePath: widget.imagePath),

								// book title
								const SizedBox(
									height: 20.0,
								),
								PrimaryInfoText(
									text: widget.bookTitle,
									color: Colors.white,
									fontSize: 20.0,
									fontWeight: FontWeight.w600),

								// book author
								const SizedBox(height: 10.0),
								PrimaryInfoText(
									text: widget.bookAuthor,
									color: Colors.white,
									fontSize: 16.0,
									fontWeight: FontWeight.w400),

								AudioControls(
									audioBookPath: widget.audioBookPath,
								)
							],
						))),
			],
		);
	}
}

class AudioControls extends StatefulWidget {
	final String audioBookPath;

	const AudioControls({Key? key, required this.audioBookPath})
		: super(key: key);

	@override
	_AudioControlsState createState() => _AudioControlsState();
}

class _AudioControlsState extends State<AudioControls> {
	bool isPlaying = false;
	late AudioManager audioManager;
	double _currentSliderValue =
	0; // This should reflect the current position of the audio.

	@override
	void initState() {
		super.initState();
		audioManager = AudioManager();

		audioManager.setSource(widget.audioBookPath);
	}

	void _togglePlayPause() {
		if (isPlaying) {
			audioManager.pause();
		} else {
			audioManager.play();
		}

		setState(() {
			isPlaying = !isPlaying;
		});
	}

	@override
	Widget build(BuildContext context) {
		return Column(
			children: <Widget>[
				// Your slider here
				Slider(
					value: _currentSliderValue,
					min: 0,
					max: 100, // This should be the total duration of the audio.
					onChanged: (value) {
						setState(() {
							_currentSliderValue = value;
							// Add logic to change the position of the audio
						});
					},
				),
				// Your start and end duration text here
// Your control buttons here
				Row(
					mainAxisAlignment: MainAxisAlignment.center,
					children: <Widget>[
						IconButton(
							icon: const Icon(Icons.fast_rewind, color: Colors.white),
							onPressed: () {
								audioManager.reverse();
							},
						),
						IconButton(
							iconSize: 64.0, // Makes the button larger
							icon: Icon(
								isPlaying
									? Icons.pause
									: Icons
									.play_arrow, // Choose the icon based on the playing state
								color: Colors.white),
							onPressed: _togglePlayPause, // Call the toggle function on press
						),
						IconButton(
							icon: const Icon(Icons.fast_forward, color: Colors.white),
							onPressed: () {
								audioManager.forward();
							},
						),
					],
				),
			],
		);
	}
}
