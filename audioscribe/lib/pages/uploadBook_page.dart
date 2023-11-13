import 'package:audioscribe/pages/main_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:audioscribe/utils/database/cloud_storage_manager.dart';
import 'package:audioscribe/utils/file_ops/book_to_speech.dart';

class UploadBookPage extends StatefulWidget {
  final String text;

  UploadBookPage({Key? key, required this.text}) : super(key: key);

  @override
  _UploadBookPageState createState() => _UploadBookPageState();
}

class _UploadBookPageState extends State<UploadBookPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _summaryController = TextEditingController();

  Future<void> _submitBook() async {
    if (_formKey.currentState!.validate()) {
      // If the form is valid, add the book to Firestore
      int bookId = DateTime.now()
          .millisecondsSinceEpoch; // Or generate a unique ID as per your logic
      await addBookToFirestore(
        bookId,
        _titleController.text,
        _authorController.text,
        _summaryController.text,
      );

      createAudioBook(widget.text, _titleController.text);

      // Clear the text fields
      _titleController.clear();
      _authorController.clear();
      _summaryController.clear();
      // Optionally, show a success message or navigate to another page
    }
    _navigateToMainPage(context);
  }

  void _navigateToMainPage(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => MainPage(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Book'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: <Widget>[
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter the book title';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _authorController,
              decoration: InputDecoration(labelText: 'Author'),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter the author\'s name';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _summaryController,
              decoration: InputDecoration(labelText: 'Summary'),
              maxLines: 4, // Allows for multiline input
            ),
            ElevatedButton(
              onPressed: _submitBook,
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
