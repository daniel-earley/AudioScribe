import 'dart:io';

import 'package:flutter/material.dart';

class BookCard extends StatelessWidget {
  final String bookTitle;
  final String bookImage;
  final String bookAuthor;

  BookCard({
    super.key,
    required this.bookTitle,
    required this.bookAuthor,
    required this.bookImage,
  });

  @override
  Widget build(BuildContext context) {
    bool isNetworkImage = bookImage.startsWith('https://');
    bool isAssetImage = bookImage.startsWith('lib/assets');

    Widget imageWidget;

    if (isNetworkImage) {
      imageWidget = Image.network(
        bookImage,
        fit: BoxFit.fill,
        errorBuilder:
            (BuildContext context, Object error, StackTrace? stackTrace) {
          print('error loading networking image: $bookImage');
          // Handle network image loading error
          return const Icon(Icons.error);
        },
      );
    } else if (isAssetImage) {
      imageWidget = Image.asset(
        bookImage,
        fit: BoxFit.fill,
        errorBuilder:
            (BuildContext context, Object error, StackTrace? stackTrace) {
          print('error loading asset image: $bookImage');
          // Handle network image loading error
          return const Icon(Icons.error);
        },
      );
    } else {
      File imageFile = File(bookImage);
      imageWidget = Image.file(
        imageFile,
        fit: BoxFit.fill,
        errorBuilder:
            (BuildContext context, Object error, StackTrace? stackTrace) {
          print('error loading image file: $bookImage');
          // Handle network image loading error
          return const Icon(Icons.error);
        },
      );
    }

    return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0), color: Colors.white),
        clipBehavior: Clip.antiAlias,
        child: GridTile(
            footer: Container(
                padding: const EdgeInsets.all(4.0),
                color: Colors.black87,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Book name
                    Text(
                      bookTitle,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.left,
                    ),

                    // Spacing
                    SizedBox(height: 10.0),

                    // Book Title
                    Text(
                      bookAuthor,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w400),
                      textAlign: TextAlign.left,
                    )
                  ],
                )),
            child: imageWidget));
  }
}
