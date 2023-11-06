import 'package:audioscribe/app_constants.dart';
import 'package:audioscribe/components/home_page_book_row.dart';
import 'package:audioscribe/components/home_page_separator.dart';
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

	void _selectPage(AppPage page) {
		setState(() {
		  	_currentPage = page;
		});
		// Navigate to the selected page
		switch(page) {
			case AppPage.COLLECTION:
				Navigator.push(context, MaterialPageRoute(builder: (context) => CollectionPage()));
				break;
		  case AppPage.HOME:
		    // TODO: Handle this case.
		}
	}

	// signs user out
	void signOut() async {
		FirebaseAuth.instance.signOut();
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: const Color(0xFF303030),
			body: _buildHomePage(context),
            // floatingActionButton: _buildBottomActionButton(context),
            // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
            // bottomNavigationBar: _buildBottomBar(context),
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
							Padding(
								padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
								child: Row(
									mainAxisAlignment: MainAxisAlignment.spaceBetween,
									crossAxisAlignment: CrossAxisAlignment.center,
									children: [
										const Text(
											"AudioScribe",
											style: TextStyle(color: Colors.white, fontSize: 25.0),
										),
										IconButton(
											icon: const Icon(Icons.account_circle, size: 45.0, color: Colors.white),
											onPressed: () {
												showDialog(
													context: context,
													builder: (BuildContext context) {
														return AlertDialog(
															title: const Text('Profile'),
															content: Stack(
																children: [
																	const Text("Profile information"),
																	IconButton(
																		icon: const Icon(Icons.logout),
																		onPressed: () {
																			signOut();
																			Navigator.pop(context);
																		}
																	)
																],
															),
															actions: [
																TextButton(
																	child: Text('Close'),
																	onPressed: () {
																		Navigator.of(context).pop();
																	},
																)
															]
														);
													}
												);
											},
										)
									],
								),
							),

							// Search bar
							Container(
								padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
								child: TextField(
									keyboardType: TextInputType.text,
									decoration: InputDecoration(
										hintText: "Search for your favourite books",
										hintStyle: const TextStyle(color: Colors.white),
										prefixIcon: Icon(Icons.search, color: Colors.white),
										filled: true,
										fillColor: Colors.white12,
										contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
										border: OutlineInputBorder(
											borderSide: BorderSide.none,
											borderRadius: BorderRadius.circular(15.0),
										),
										enabledBorder: OutlineInputBorder(
											borderSide: BorderSide.none,
											borderRadius: BorderRadius.circular(15.0),
										),
										focusedBorder: OutlineInputBorder(
											borderSide: BorderSide.none,
											borderRadius: BorderRadius.circular(15.0),
										)
									),
								)
							),

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

    Widget _buildBottomActionButton(BuildContext context) {
        return FloatingActionButton(
			backgroundColor: Color(0xFF524178),
            onPressed: () {
                // Handle button tap
            },
            child: Icon(Icons.add, size: 35.0),
        );
    }

    Widget _buildBottomBar(BuildContext context) {
        return BottomAppBar(
            shape: const CircularNotchedRectangle(),
            notchMargin: 6.0,
            height: 40.0,
            color: Colors.black54,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                    // space before icon
                    Spacer(),

                    IconButton(
						icon: Icon(
							Icons.home,
							color: _currentPage == AppPage.HOME ? Color(0xFF9260FC) : Colors.white,
							size: 30.0
						),
						onPressed: () {
							setState(() {
							  	_currentPage = AppPage.HOME;
							});
                    	}),

                    // space between icons
                    Spacer(),
                    Spacer(),
                    SizedBox(width: 48),

                    IconButton(
						icon: Icon(
							Icons.bookmark,
							color: _currentPage == AppPage.COLLECTION ? Color(0xFF9260FC) : Colors.white,
							size: 30.0
						), onPressed: () {
							setState(() {
							  	_selectPage(AppPage.COLLECTION);
							});
                    	}),

					// space after icon
                    Spacer(),
                ],
            ),
        );
    }
}