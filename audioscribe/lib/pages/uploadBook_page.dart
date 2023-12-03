import 'package:audioscribe/data_classes/book.dart';
import 'package:audioscribe/data_classes/librivox_book.dart';
import 'package:audioscribe/pages/home_page.dart';
import 'package:audioscribe/pages/main_page.dart';
import 'package:audioscribe/services/txt_summary_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:audioscribe/utils/database/cloud_storage_manager.dart';
import 'package:audioscribe/utils/file_ops/book_to_speech.dart';

import '../utils/database/book_model.dart';

class UploadBookPage extends StatefulWidget {
  final String text;
  final VoidCallback? onUpload;

  UploadBookPage({Key? key, required this.text, this.onUpload})
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
      // If the form is valid, add the book to Firestore
      int bookId = DateTime.now().millisecondsSinceEpoch;

      // generate a summary
      // String contentSummary = await TxtSummarizerService.SummarizeText(widget.text);
      // String contentSummary = await TxtSummarizerService.summarizeTextGPT(widget.text);
      String contentSummary =
          "trying not to use up tokens so delete this before pushing and use gpt";

      // generate the audio book for current context
      String audioBookPath =
          await createAudioBook(widget.text, _titleController.text);

      // Store the book on firestore
      await addBookToFirestore(bookId, _titleController.text,
          _authorController.text, contentSummary, audioBookPath, 'UPLOAD');

      // create new book object
      Book book = Book(
          bookId: bookId,
          title: _titleController.text,
          author: _authorController.text,
          audioFileLocation: audioBookPath,
          bookType: 'UPLOAD');

      // update book information to match LibrivoxBook
      book.bookType = 'UPLOAD';
      book.textFileLocation = contentSummary;
      book.audioFileLocation = audioBookPath;
      book.imageFileLocation = 'lib/assets/books/Default/textFile.png';

      // print('${book.bookType}, ${book.textFileLocation}, ${book.audioFileLocation}, ${book.imageFileLocation}');

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
      // Navigator.of(context).pop();
      // Navigator.pop(context, true);
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
        title: Text('Add Book'),
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
