import 'package:audioscribe/components/app_header.dart';
import 'package:audioscribe/pages/collection_page.dart';
import 'package:audioscribe/pages/home_page.dart';
import 'package:audioscribe/pages/settings_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
	@override
	_MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
	int _selectedIndex = 0;
	bool _switchOn = true;

	void _toggleSwitch(bool newValue) {
		setState(() {
			_switchOn = newValue;
		});
	}

	// list of widgets
	final List<Widget> _widgetOptions = [
		const HomePage(),
		const CollectionPage(),
		const SettingsPage()
	];

	void _onItemTapped(int index) {
		setState(() {
		  	_selectedIndex = index;
		});
	}

	// sign user out
	void signOut() async {
		FirebaseAuth.instance.signOut();
	}

	String currentPageHeaderTitle() {
		switch(_selectedIndex) {
			case 0:
				return 'AudioScribe';
			case 1:
				return 'Your collection';
			case 2:
				return 'Settings';
			default:
				return 'AudioScribe';
		}
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: const Color(0xFF303030),
			body: Stack(
				children: [
					SafeArea(
						child: Column(
						children: [
							AppHeader(
								headerText: currentPageHeaderTitle(),
								onTap: () => _onItemTapped(2),
								currentScreen: _selectedIndex,
								isSwitched: _switchOn,
								onToggle: _toggleSwitch,
							),
							Expanded(
								child: IndexedStack(
									index: _selectedIndex,
									children: _widgetOptions,
								),
							)
						],
					),)
				],
			),
			floatingActionButton: _buildBottomActionButton(context),
			floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
			bottomNavigationBar: _buildBottomBar(context),
		);
	}
	
	Widget _buildBottomActionButton(BuildContext context) {
		return FloatingActionButton(
			backgroundColor: const Color(0xFF524178),
			onPressed: () {},
			child: const Icon(Icons.add, size: 35.0),
		);
	}

	Widget _buildBottomBar(BuildContext context) {
		return BottomAppBar(
			shape: const CircularNotchedRectangle(),
			notchMargin: 6.0,
			height: 40.0,
			color: Colors.black54,
			child: Row(
				mainAxisAlignment: MainAxisAlignment.spaceEvenly,
				children: [
					const Spacer(),
					
					IconButton(
						onPressed: () => _onItemTapped(0),
						icon: Icon(Icons.home, size: 30.0, color: _selectedIndex == 0 ? const Color(0xFF9260FC) : Colors.white)
					),
					
					const Spacer(),
					const Spacer(),
					const SizedBox(width: 48),
					
					IconButton(
						onPressed: () => _onItemTapped(1),
						icon: Icon(Icons.bookmark, size: 30.0, color: _selectedIndex == 1 ? const Color(0xFF9260FC) : Colors.white),
					),
					
					const Spacer(),
				],
			)
		);
	}
}