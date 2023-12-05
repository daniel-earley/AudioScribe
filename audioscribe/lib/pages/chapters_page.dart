import 'package:audioscribe/app_constants.dart';
import 'package:audioscribe/components/image_container.dart';
import 'package:flutter/material.dart';

class ChaptersPage extends StatelessWidget {
	final String bookTitle;
	final String image;
	final List<Map<String, dynamic>> chapterData;
	final Function(int) onChapterSelected;

	const ChaptersPage({
		super.key,
		required this.bookTitle,
		required this.chapterData,
		required this.image,
		required this.onChapterSelected
	});

	void initState() {
		print('$bookTitle, $chapterData, $image');
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: AppColors.secondaryAppColor,
			appBar: AppBar(
				title: Text(bookTitle),
				backgroundColor: AppColors.primaryAppColor,
			),
			body: SafeArea(
				child: Padding(
					padding: const EdgeInsets.all(10.0),
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							// Header
							_buildHeader(),

							// Chapters Title
							const SizedBox(height: 10.0),
							const Text('Chapters',
								style: TextStyle(color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.w400),
							),
							// chapters list

							Expanded(child: _buildChapterList())
						],
					),
				),
			)
		);
	}


	Widget _buildHeader() {
		return Column(
			children: [
				Row(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						// image
						SizedBox(
							height: 100,
							width: 70,
							child: ImageContainer(imagePath: image),
						),
						// title
						Padding(
							padding: const EdgeInsets.all(10.0),
							child: Text(bookTitle, style: const TextStyle(color: Colors.white, fontSize: 20.0))
						),
					],
				),

				// horizontal rule
				Container(
					margin: const EdgeInsets.only(top: 5.0),
					height: 1.0,
					color: Colors.white24
				),
			],
		);
	}

	Widget _buildChapterList() {
		return ListView.builder(
			shrinkWrap: true,
			itemCount: chapterData.length,
			itemBuilder: (context, index) {
				var data = chapterData[index];
				print(data);
				return GestureDetector(
					onTap: () {
						onChapterSelected(index);
						Navigator.of(context).pop();
					},
					child: Padding(
						padding: const EdgeInsets.all(2.0),
						child: Container(
							decoration: const BoxDecoration(
								color: AppColors.secondaryAppColor
							),
							child: Row(
								children: [
									const Padding(
										padding: EdgeInsets.all(4.0),
										child: Icon(Icons.play_circle_fill, color: Colors.white),
									),
									Flexible(
										child: Padding(
											padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 5.0),
											child: Text(
												data['chapter'] ?? "${data['chapterNumber']} : ${data['chapterTitle']}",
												style: const TextStyle(color: Colors.white, fontSize: 18.0))
										)
									)
								],
							),
						),
					),
				);
			},
		);
	}
}