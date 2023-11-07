import 'package:audioscribe/components/app_header.dart';
import 'package:audioscribe/components/book_grid.dart';
import 'package:audioscribe/components/search_bar.dart';
import 'package:flutter/material.dart';


class CollectionPage extends StatefulWidget {
	const CollectionPage({Key? key}): super(key: key);

	@override
	_CollectionPageState createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {


	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: const Color(0xFF303030),
			body: _buildCollectionPage(context)
		);
	}

	Widget _buildCollectionPage(BuildContext context) {
		return Stack(
			children: [
				SafeArea(
					child: Column(
						children: [
							// Search bar
							AppSearchBar(hintText: "search for your favourite books"),

							// Book grid
							Expanded(child: BookGridView()),
						],
					)
				)
			],
		);
	}
}