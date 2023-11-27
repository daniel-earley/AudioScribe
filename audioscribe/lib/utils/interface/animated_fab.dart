import 'package:flutter/material.dart';

class AnimatedFAB extends StatefulWidget {
	final List<Widget> listItems;
	final List<VoidCallback> onTapActions;

	AnimatedFAB({
		super.key,
		required this.listItems,
		required this.onTapActions
	});

	@override
	_AnimatedFABState createState() => _AnimatedFABState();
}

class _AnimatedFABState extends State<AnimatedFAB> {
	bool isListVisible = false;
	IconData fabIcon = Icons.add;
	List<bool> itemVisibility = [false, false, false];

	@override
	void initState() {
		super.initState();
		itemVisibility = List.generate(widget.listItems.length, (_) => false);
	}

	@override
	Widget build(BuildContext context) {
		return Stack(
			alignment: Alignment.bottomRight,
			children: [
				_buildAnimatedList(),
				FloatingActionButton(
					onPressed: _toggleList,
					backgroundColor: const Color(0xFF242424),
					shape: const RoundedRectangleBorder(
						borderRadius: BorderRadius.all(Radius.circular(10.0))
					),
					child: AnimatedSwitcher(
						duration: const Duration(milliseconds: 200),
						transitionBuilder: (Widget child, Animation<double> animation) {
							return ScaleTransition(scale: animation, child: child);
						},
						child: Icon(
							fabIcon,
							size: 32.0,
							key: ValueKey<IconData>(fabIcon),
						),
					),
				),
			],
		);
	}

	void _toggleList() {
		if (isListVisible) {
			_reverseAnimateListItems();
		} else {
			setState(() {
				isListVisible = true;
				fabIcon = Icons.close;
				_animateListItems();
			});
		}
	}
	void _animateListItems() async {
		for (int i = 0; i < itemVisibility.length; i++) {
			await Future.delayed(Duration(milliseconds: i * 25));
			setState(() {
				itemVisibility[i] = true;
			});
		}
	}

	void _reverseAnimateListItems() async {
		for (int i = itemVisibility.length - 1; i >= 0; i--) {
			setState(() {
				itemVisibility[i] = false;
			});
			await Future.delayed(Duration(milliseconds: 100 - i * 250));
		}
		setState(() {
			isListVisible = false;
			fabIcon = Icons.list;
		});
	}

	Widget _buildAnimatedList() {
		return Visibility(
			visible: isListVisible || itemVisibility.contains(true),
			child: Padding(
				padding: const EdgeInsets.only(bottom: 60.0),
				child: Column(
					mainAxisSize: MainAxisSize.min,
					crossAxisAlignment: CrossAxisAlignment.end,
					children: [
						...List.generate(widget.listItems.length, (index) {
							return _buildAnimatedListItem(index);
						}),
						// _buildHorizontalList()
					],
				),
			)
		);
	}

	Widget _buildAnimatedListItem(int index) {
		return AnimatedScale(
			scale: itemVisibility[index] ? 1.0 : 0.0,
			duration: const Duration(milliseconds: 200),
			child: AnimatedOpacity(
				opacity: itemVisibility[index] ? 1.0 : 0.0,
				duration: const Duration(milliseconds: 200),
				child: GestureDetector(
					onTap: () {
						widget.onTapActions[index]();
					},
					child: Padding(
						padding: const EdgeInsets.symmetric(vertical: 2.0),
						child: Container(
							width: 100,
							height: 40,
							decoration: const BoxDecoration(
								borderRadius: BorderRadius.all(Radius.circular(10.0)),
								color: Color(0xFF474747),
							),
							child: Center(
								child: widget.listItems[index],
							),
						),
					),
				)
			)
		);
	}

	Widget _buildHorizontalList() {
		return AnimatedOpacity(
			opacity: isListVisible ? 1.0 : 0.0,
			duration: Duration(milliseconds: 300),
			child: AnimatedScale(
				scale: isListVisible ? 1.0 : 0.0,
				duration: Duration(milliseconds: 300),
				child: Row(
					mainAxisAlignment: MainAxisAlignment.end,
					children: [
						Container(
							width: 48,
							height: 40,
							decoration: const BoxDecoration(
								color: Color(0xFF474747),
								borderRadius: BorderRadius.all(Radius.circular(10.0)),
							),
							child: const Padding(
								padding: EdgeInsets.all(2.0),
								child: Icon(Icons.home_outlined, color: Colors.white),
							),
						),
						const SizedBox(width: 2.0),
						Container(
							width: 48,
							height: 40,
							decoration: const BoxDecoration(
								color: Color(0xFF474747),
								borderRadius: BorderRadius.all(Radius.circular(10.0)),
							),
							child: const Padding(
								padding: EdgeInsets.all(2.0),
								child: Icon(Icons.bookmark_outline, color: Colors.white),
							),
						),
					],
				),
			),
		);
	}


}
