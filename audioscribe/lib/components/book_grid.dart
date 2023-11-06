import 'package:flutter/material.dart';

class Book {
	final String title;
	final String imageUrl;
	final String author;

	Book(this.title, this.imageUrl, this.author);
}

class BookGridView extends StatefulWidget {
	@override
	_BookGridViewState createState() => _BookGridViewState();
}

class _BookGridViewState extends State<BookGridView> {
	final List<Book> books = [
		Book('The Psychology of Money', 'lib/images/dummy_book_1.jpg', 'Morgan Housel'),
		Book('Atomic Habit', 'lib/images/dummy_book_2.jpg', 'James Clear'),
		Book('Harry Potter and The Prisoner of Azkaban', 'lib/images/dummy_book_3.jpg', 'J.K. Rowling'),
		Book('The World of Ice and fire', 'lib/images/dummy_book_4.jpg', 'George R. R. Martin'),
	];

	@override
	Widget build(BuildContext context) {
		return GridView.builder(
			padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
			gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
				crossAxisCount: 2,
				crossAxisSpacing: 15,
				mainAxisSpacing: 15,
				childAspectRatio: 0.6
			),
			itemCount: books.length,
			itemBuilder: (context, index) {
				final book = books[index];
				return Container(
					decoration: BoxDecoration(
						borderRadius: BorderRadius.circular(10),
						color: Colors.white,
					),
					clipBehavior: Clip.antiAlias,
					child: GridTile(
						footer: Container(
							padding: const EdgeInsets.all(4),
							color: Colors.black87,
							child: Text(
								book.title,
								style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
								textAlign: TextAlign.center,
							),
						),
						child: Image.asset(
							book.imageUrl,
							fit: BoxFit.cover
						),
					),
				);
			}
		);
	}
}