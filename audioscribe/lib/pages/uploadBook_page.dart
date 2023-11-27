import 'package:audioscribe/pages/main_page.dart';
import 'package:audioscribe/services/txt_summary_service.dart';
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
			int bookId = DateTime.now().millisecondsSinceEpoch;

			// generate a summary
			// String contentSummary = await TxtSummarizerService.SummarizeText(widget.text);
			String contentSummary = await TxtSummarizerService.summarizeTextGPT(widget.text);

			// generate the audio book for current context
			String audioBookPath =
			await createAudioBook(widget.text, _titleController.text);

			// Store the book on firestore
			await addBookToFirestore(bookId, _titleController.text,
				_authorController.text, contentSummary, audioBookPath);

			// Clear the text fields
			_titleController.clear();
			_authorController.clear();
			_summaryController.clear();
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
							onPressed: _submitBook,
							child: Text('Submit'),
							style: ButtonStyle(
								backgroundColor: MaterialStateProperty.all(Color(0xFF524178)),
							),
						),
					],
				),
			),
		);
	}
}
