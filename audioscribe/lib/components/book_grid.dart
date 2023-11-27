import 'package:audioscribe/pages/book_details.dart';
import 'package:flutter/material.dart';

class BookGridView extends StatefulWidget {
  final List<Map<String, dynamic>> books;
  final Function(int index, String title, String author, String image,
      String summary, String audioBookPath) onBookSelected;

  const BookGridView(
      {super.key, required this.books, required this.onBookSelected});

  @override
  _BookGridViewState createState() => _BookGridViewState();
}

class _BookGridViewState extends State<BookGridView> {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 0.6),
        itemCount: widget.books.length,
        itemBuilder: (context, index) {
          final book = widget.books[index];
          return GestureDetector(
            onTap: () {
              print('book grid (34) current book selected: $book');
              widget.onBookSelected(book['id'], book['title'], book['author'],
                  book['image'], book['summary'], book['audioBookPath']);
            },
            child: Container(
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
                    book['title'],
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                child: Image.asset(book['image'], fit: BoxFit.cover),
              ),
            ),
          );
        });
  }
}
