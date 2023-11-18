import 'package:flutter/material.dart';

class ImageContainer extends StatelessWidget {
	final String imagePath;

	const ImageContainer({
		Key? key,
		required this.imagePath
	}) : super(key: key);

	@override
	Widget build(BuildContext context) {
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
					image: AssetImage(imagePath),
					fit: BoxFit.fill	 // Changed from BoxFit.fill to BoxFit.cover
				),
			),
		);
	}
}