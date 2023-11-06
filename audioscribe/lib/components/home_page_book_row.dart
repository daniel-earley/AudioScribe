import 'package:flutter/material.dart';

class BookRow extends StatefulWidget {
	final List<Map<String, String>> books;

	const BookRow({
		super.key,
		required this.books
	});

	@override
	_BookRow createState() => _BookRow();
}

class _BookRow extends State<BookRow> {
	@override
	Widget build(BuildContext context) {
		return Container(
			padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
			height: 200,
			child: ListView.builder(
				scrollDirection: Axis.horizontal,
				itemCount: widget.books.length,
				itemBuilder: (context, index) {
					return Container(
						width: 120,
						padding: EdgeInsets.all(8.0),
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								AspectRatio(
									aspectRatio: 0.7,
									child: Container(
										decoration: BoxDecoration(
											color: Colors.white,
											borderRadius: BorderRadius.circular(4),
											boxShadow: [
												BoxShadow(
													color: Colors.black.withOpacity(0.2),
													blurRadius: 3,
													offset: Offset(0, 2),
												),
											],
											image: DecorationImage(
												image: AssetImage(widget.books[index]['image']!),
												fit: BoxFit.fill
											),
										),
									),
								),
								SizedBox(height: 8),

								Text(
									widget.books[index]['title']!,
									textAlign: TextAlign.center,
									style: TextStyle(
										color: Colors.white,
										fontSize: 10,
										fontWeight: FontWeight.w500
									),
									maxLines: 2,
									overflow: TextOverflow.ellipsis,
								)
							],
						)
					);
				}
			),
		);
	}
}