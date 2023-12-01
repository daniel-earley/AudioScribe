import 'dart:io';

import 'package:flutter/material.dart';

class ImageContainer extends StatelessWidget {
	final String imagePath;

	const ImageContainer({
		Key? key,
		required this.imagePath
	}) : super(key: key);

	@override
	Widget build(BuildContext context) {
		bool isNetworkImage = imagePath.startsWith('https://');
		bool isAssetImage = imagePath.startsWith('lib/assets');

		// Create the appropriate ImageProvider based on the image path
		ImageProvider imageProvider;
		if (isNetworkImage) {
			imageProvider = NetworkImage(imagePath);
		} else if (isAssetImage) {
			imageProvider = AssetImage(imagePath);
		} else {
			File imageFile = File(imagePath);
			imageProvider = FileImage(imageFile);
		}
		return Container(
			width: MediaQuery.of(context).size.width * 0.6,
			height: MediaQuery.of(context).size.width * 0.8,
			decoration: BoxDecoration(
				color: Colors.white,
				borderRadius: BorderRadius.circular(4),
				boxShadow: [
					BoxShadow(
						color: Colors.black.withOpacity(0.2),
						blurRadius: 3,
						offset: const Offset(0, 2),
					)
				],
				image: DecorationImage(
					image: imageProvider,
					fit: BoxFit.fill	 // Changed from BoxFit.fill to BoxFit.cover
				),
			),
		);
	}
}