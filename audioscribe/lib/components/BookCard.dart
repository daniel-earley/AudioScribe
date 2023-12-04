import 'dart:io';

import 'package:audioscribe/app_constants.dart';
import 'package:flutter/material.dart';

class BookCard extends StatelessWidget {
	final String bookTitle;
	final String bookImage;
	final String bookAuthor;
	String? bookType;

	BookCard({
		super.key,
		required this.bookTitle,
		required this.bookAuthor,
		required this.bookImage,
		this.bookType,
	});

	@override
	Widget build(BuildContext context) {
		bool isNetworkImage = bookImage.startsWith('https://');
		bool isAssetImage = bookImage.startsWith('lib/assets');

		// print('image: $bookImage');

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
			imageWidget = Icon(
				bookType == 'AUDIO' ? Icons.music_note : Icons.notes,
				size: 42.0,
				color: AppColors.primaryAppColorBrighter,
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
				borderRadius: BorderRadius.circular(10.0), color: AppColors.secondaryAppColor),
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
							const SizedBox(height: 10.0),

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
				child: imageWidget)
		);
	}
}
