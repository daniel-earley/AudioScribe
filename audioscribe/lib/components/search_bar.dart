import 'dart:io';

import 'package:audioscribe/app_constants.dart';
import 'package:audioscribe/components/image_container.dart';
import 'package:flutter/material.dart';

GlobalKey _searchBarKey = GlobalKey();

class AppSearchBar extends StatefulWidget {
	final String hintText;
	final List<Map<String, dynamic>> allItems;

	const AppSearchBar({
		super.key,
		required this.hintText,
		required this.allItems,
	});

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
	final FocusNode _focusNode = FocusNode();
	final TextEditingController _controller = TextEditingController();
	List<Map<String, dynamic>> filteredItems = [];

	final LayerLink _layerLink = LayerLink();
	OverlayEntry? _overlayEntry;

	@override
	void initState() {
		super.initState();
		_focusNode.addListener(() {
			if (!_focusNode.hasFocus) {
				_filterItems(''); // Reset filtered items, assuming this method sets the state
				_hideOverlay();
			}
		});
	}

	void _filterItems(String enteredKeyword) {
		List<Map<String, dynamic>> results = [];
		if (enteredKeyword.isEmpty) {
			print("is empty filtered list");
			_hideOverlay();
		} else {
			results = widget.allItems.where((mapItem) =>
				mapItem['item']!.toLowerCase().contains(enteredKeyword.toLowerCase())
			).toList();
			_showOverlay(context);
		}

		setState(() {
			filteredItems = results;
		});
	}

	void _showOverlay(BuildContext context) {
		final RenderBox renderBox = _searchBarKey.currentContext?.findRenderObject() as RenderBox;
		final size = renderBox.size;
		final position = renderBox.localToGlobal(Offset.zero);

		if (_overlayEntry != null) {
			_overlayEntry!.markNeedsBuild();
		} else {
			_overlayEntry = OverlayEntry(
				builder: (context) => Positioned(
					width: size.width, // Adjust the width as needed
					child: CompositedTransformFollower(
						link: _layerLink,
						showWhenUnlinked: false,
						offset: Offset(position.dx, 60), // Adjust the offset as needed
						child: Material(
							color: AppColors.secondaryAppColor,
							elevation: 4.0,
							child: ListView.builder(
								shrinkWrap: true,
								physics: const NeverScrollableScrollPhysics(),
								itemCount: filteredItems.length,
								itemBuilder: (context, index) {
									Map<String, dynamic> book = filteredItems[index];

									File imageFile = File(filteredItems[index]['image']);
									return Padding(
										padding: const EdgeInsets.all(10.0),
										child: GestureDetector(
											onTap: () {
												print('${filteredItems.length} $index');
												print('clicked item: ${filteredItems[index]['image']} ${filteredItems[index]['item']}');
											},
											child: Row(
												crossAxisAlignment: CrossAxisAlignment.center,
												children: [
													SizedBox(
														 width: 50,
														 height: 70,
														 child: ImageContainer(imagePath: filteredItems[index]['image']),
													),
													Flexible(
														child: Padding(
															padding: const EdgeInsets.only(left: 10.0),
															child: Text(
																filteredItems[index]['item']!,
																style: const TextStyle(color: Colors.white, fontSize: 18.0),
																textAlign: TextAlign.left,
															),
														)
													)
												],
											),
										)
									);
								}
							),
						),
					),
				),
			);
			Overlay.of(context).insert(_overlayEntry!);
		}
	}

	void _hideOverlay() {
		_overlayEntry?.remove();
		_overlayEntry = null;
	}

	@override
	Widget build(BuildContext context) {
		return CompositedTransformTarget(
			link: _layerLink,
			child: Container(
					padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
					child: TextField(
						focusNode: _focusNode,
						key: _searchBarKey,
						keyboardType: TextInputType.text,
						controller: _controller,
						style: const TextStyle(color: Colors.white),
						onChanged: (value) {
							_filterItems(value);
						},
						decoration: InputDecoration(
							hintText: widget.hintText,
							hintStyle: const TextStyle(color: Colors.white),
							prefixIcon: const Icon(Icons.search, color: Colors.white),
							filled: true,
							fillColor: Colors.white12,
							contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
							border: OutlineInputBorder(
								borderSide: BorderSide.none,
								borderRadius: BorderRadius.circular(15.0),
							),
							enabledBorder: OutlineInputBorder(
								borderSide: BorderSide.none,
								borderRadius: BorderRadius.circular(15.0),
							),
							focusedBorder: OutlineInputBorder(
								borderSide: BorderSide.none,
								borderRadius: BorderRadius.circular(15.0),
							)
						),
					),
			),
		);
	}

	@override
	void dispose() {
		_focusNode.dispose();
		_controller.dispose();
		_hideOverlay();
		super.dispose();
	}
}