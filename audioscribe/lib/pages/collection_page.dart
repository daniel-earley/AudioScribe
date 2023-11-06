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

		);
	}
}