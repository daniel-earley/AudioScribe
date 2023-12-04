import 'dart:async';

import 'package:audioscribe/app_constants.dart';
import 'package:audioscribe/components/bookInfoText.dart';
import 'package:audioscribe/components/image_container.dart';
import 'package:audioscribe/data_classes/bookmark.dart';
import 'package:audioscribe/services/audio_player_service.dart';
import 'package:audioscribe/utils/file_ops/read_json.dart';
import 'package:audioscribe/utils/interface/animated_fab.dart';
import 'package:audioscribe/utils/interface/snack_bar.dart';
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
        backgroundColor: AppColors.primaryAppColor,
      ),
      backgroundColor: const Color(0xFF303030),
      body: _buildAudioPlayerPage(),
      floatingActionButton: AnimatedFAB(
        listItems: const [
          Text('Home', style: TextStyle(color: Colors.white)),
          Text('Second Item', style: TextStyle(color: Colors.white)),
        ],
        onTapActions: [
          () => Navigator.popUntil(
              context, (Route<dynamic> route) => route.isFirst),
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

  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerCompleteSubscription;

  Duration? _duration;
  Duration? _position;
  PlayerState? _playerState;

  String get _durationText => _duration?.toString().split('.').first ?? '';
  String get _positionText => _position?.toString().split('.').first ?? '';

  late Map<String, dynamic> metadata;
  late List<dynamic> chapters;
  int chapterNumber = 0;

  @override
  void initState() {
    super.initState();
    audioManager = AudioManager();

    // Open Metadata.json
    loadMetadata();

    _initStreams();
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

  void _initStreams() {
    _durationSubscription = audioManager.onDurationChanged.listen((duration) {
      setState(() => _duration = duration);
    });

    _positionSubscription = audioManager.onPositionChanged.listen(
      (p) => setState(() => _position = p),
    );

    // When audio finishes playing
    _playerCompleteSubscription = audioManager.onPlayerComplete.listen((event) {
      if (metadata.containsKey("chapters")) {
        // Chapters found
        if (chapterNumber + 1 < chapters.length) {
          setState(() {
            _position = Duration.zero;
            chapterNumber++;
            audioManager.setSource(chapters[chapterNumber]["audioFilePath"]);
            audioManager.play();
          });
        } else {
          setState(() {
            _playerState = PlayerState.stopped;
            _position = Duration.zero;
            chapterNumber = 0;
            audioManager.setSource(chapters[chapterNumber]["audioFilePath"]);
            isPlaying = !isPlaying;
          });
        }
      } else {
        setState(() {
          _playerState = PlayerState.stopped;
          _position = Duration.zero;
          audioManager.setSource(metadata["audioFilePath"]);
          isPlaying = !isPlaying;
        });
      }
    });
  }

  Future<void> loadMetadata() async {
    try {
      metadata = await readJsonFile("${widget.audioBookPath}/metadata.json")
          as Map<String, dynamic>;

      // Check for chapters
      if (metadata.containsKey("chapters")) {
        // Found chapters
        chapters = metadata["chapters"];
        audioManager.setSource(chapters[chapterNumber]["audioFilePath"]);
      } else {
        audioManager.setSource(metadata["audioFilePath"]);
      }
    } catch (e) {
      // Handle any errors here
      print('Error loading JSON data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        // Audio Duration Slider
        Slider(
          onChanged: (value) {
            final duration = _duration;
            if (duration == null) {
              return;
            }
            final position = value * duration.inMilliseconds;
            audioManager.seek(Duration(milliseconds: position.round()));
          },
          value: (_position != null &&
                  _duration != null &&
                  _position!.inMilliseconds > 0 &&
                  _position!.inMilliseconds < _duration!.inMilliseconds)
              ? _position!.inMilliseconds / _duration!.inMilliseconds
              : 0.0,
          activeColor: Colors.deepPurpleAccent,
        ),
        Text(
          _position != null
              ? '$_positionText / $_durationText'
              : _duration != null
                  ? _durationText
                  : '',
          style: const TextStyle(
            fontSize: 16.0,
            color: Colors.white,
          ),
        ),
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
              icon: Icon(Icons.fast_forward, color: Colors.white),
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
