import 'package:audioscribe/app_constants.dart';
import 'package:audioscribe/components/app_header.dart';
import 'package:audioscribe/components/home_page_book_row.dart';
import 'package:audioscribe/components/home_page_separator.dart';
import 'package:audioscribe/components/search_bar.dart';
import 'package:audioscribe/pages/collection_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
	const HomePage({Key? key}) : super(key: key);

	@override
	_HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

	// current page
	AppPage _currentPage = AppPage.HOME;

	// create user var
	final user = FirebaseAuth.instance.currentUser!;

	// list of users book
	final List<Map<String, String>> userBooks = [
		{
			'image': 'lib/images/dummy_book_1.jpg',
			'title': 'The Psychology of Money'
		},
	];

	// list of recommendation books
	final List<Map<String, String>> recommendationBooks = [
		{
			'image': 'lib/images/dummy_book_1.jpg',
			'title': 'The Psychology of Money'
		},
		{
			'image': 'lib/images/dummy_book_2.jpg',
			'title': 'Atomic Habits'
		},
		{
			'image': 'lib/images/dummy_book_3.jpg',
			'title': 'Harry Potter and The Prisoner of Azkaban'
		},
		{
			'image': 'lib/images/dummy_book_3.jpg',
			'title': 'Harry Potter and The Prisoner of Azkaban'
		},
	];

	// signs user out
	void signOut() async {
		FirebaseAuth.instance.signOut();
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: const Color(0xFF303030),
			body: _buildHomePage(context),
		);
	}

	Widget _buildHomePage(BuildContext context) {
		// fallback for device back button
		setState(() {
		  	_currentPage = AppPage.HOME;
		});

		return Stack(
			children: [
				SafeArea(
					child: Column(
						children: [
							// Header (title + account circle)
							AppHeader(
								headerText: "AudioScribe",
								signout: () {
									signOut();
									Navigator.pop(context);
								}),

							// Search bar
							const AppSearchBar(hintText: "search for your favourite books"),

							// Separator
							const Separator(text: "Currently listening to..."),

							// Book Row 1
							BookRow(books: userBooks),

							// Separator
							const Separator(text: "Recommendations"),

							// Book Row 2
							BookRow(books: recommendationBooks),
						],
					),
				),
			],
		);
	}
}