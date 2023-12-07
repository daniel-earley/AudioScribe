import 'dart:io';

import 'package:audioscribe/app_constants.dart';
import 'package:flutter/material.dart';

class ImageContainer extends StatelessWidget {
  final String imagePath;
  String? bookType;
  double? size;

  ImageContainer({Key? key, required this.imagePath, this.bookType, this.size})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isNetworkImage = imagePath.startsWith('https://');
    bool isAssetImage = imagePath.startsWith('lib/assets');

    // Create the appropriate ImageProvider based on the image path
    ImageProvider imageProvider;
    Widget imageWidget;
    if (isNetworkImage) {
      // imageProvider = NetworkImage(imagePath);
      imageWidget = Image.network(
        imagePath,
        fit: BoxFit.fill,
      );
    } else if (isAssetImage) {
      // imageProvider = AssetImage(imagePath);
      imageWidget = Icon(
        bookType == 'AUDIO' ? Icons.music_note : Icons.notes,
        size: size ?? 32.0,
        color: AppColors.primaryAppColorBrighter,
      );
    } else {
      File imageFile = File(imagePath);
      // imageProvider = FileImage(imageFile);
      imageWidget = Image.file(imageFile, fit: BoxFit.fill);
    }
    return Container(
      width: MediaQuery.of(context).size.width * 0.6,
      height: MediaQuery.of(context).size.width * 0.8,
      decoration: BoxDecoration(
        color: AppColors.secondaryAppColor,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 3,
            offset: const Offset(0, 2),
          )
        ],
        // image: DecorationImage(
        // 	image: imageProvider,
        // 	fit: BoxFit.fill	 // Changed from BoxFit.fill to BoxFit.cover
        // ),
      ),
      child: imageWidget,
    );
  }
}
