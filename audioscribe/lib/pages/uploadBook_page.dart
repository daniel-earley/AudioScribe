import 'package:audioscribe/data_classes/book.dart';
import 'package:audioscribe/services/txt_summary_service.dart';
import 'package:flutter/material.dart';
import 'package:audioscribe/utils/database/cloud_storage_manager.dart';
import 'package:audioscribe/utils/file_ops/book_to_speech.dart';

import '../utils/database/book_model.dart';

class UploadBookPage extends StatefulWidget {
  final String text;
  final VoidCallback? onUpload;

  const UploadBookPage({Key? key, required this.text, this.onUpload})
      : super(key: key);

  @override
  _UploadBookPageState createState() => _UploadBookPageState();
}

class _UploadBookPageState extends State<UploadBookPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _summaryController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submitBook() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      print('mp3 file location: ${widget.text}');
      int bookId = 0;
      String audioBookPath = '';
      String contentSummary = '';

      if (widget.text.endsWith('.mp3')) {
        print('mp3 file is being uploaded');
        bookId = DateTime.now().millisecondsSinceEpoch;
        audioBookPath = widget.text;
      } else {
        // If the form is valid, add the book to Firestore
        bookId = DateTime.now().millisecondsSinceEpoch;

        // generate a summary
        contentSummary =
            await TxtSummarizerService.summarizeTextGPT(widget.text);

        // generate the audio book for current context
        audioBookPath =
            await createAudioBook(widget.text, _titleController.text);
      }

      // Store the book on firestore
      await addBookToFirestore(
          bookId,
          _titleController.text,
          _authorController.text,
          contentSummary,
          audioBookPath,
          widget.text.endsWith('.mp3') ? 'AUDIO' : 'UPLOAD',
          0,
          0);

      // create new book object
      Book book = Book(
          bookId: bookId,
          title: _titleController.text,
          author: _authorController.text,
          audioFileLocation: audioBookPath,
          bookType: widget.text.endsWith('.mp3') ? 'AUDIO' : 'UPLOAD');

      // update book information to match LibrivoxBook
      book.bookType = widget.text.endsWith('.mp3') ? 'AUDIO' : 'UPLOAD';
      book.textFileLocation = contentSummary;
      book.audioFileLocation = audioBookPath;
      book.imageFileLocation = 'lib/assets/books/Default/textFile.png';

      // store the book in sqlite
      await BookModel().insertAPIBook(book.toLibrivoxBook());

      // Clear the text fields
      _titleController.clear();
      _authorController.clear();
      _summaryController.clear();

      setState(() {
        _isLoading = false;
      });
    }
    if (mounted) {
      Navigator.popUntil(context, (Route<dynamic> route) => route.isFirst);
      if (widget.onUpload != null) widget.onUpload!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF303030),
      appBar: AppBar(
        backgroundColor: const Color(0xFF524178),
        title: const Text('Add Book'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: <Widget>[
            TextFormField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Title',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color:
                          Colors.white), // Set underline color when not focused
                ),
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter the book title';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _authorController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Author',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color:
                          Colors.white), // Set underline color when not focused
                ),
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter the author\'s name';
                }
                return null;
              },
            ),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitBook,
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(const Color(0xFF524178)),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                  : const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
