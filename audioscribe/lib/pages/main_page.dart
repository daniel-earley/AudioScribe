import 'package:audioscribe/pages/book_details.dart';
import 'package:audioscribe/pages/uploadBook_page.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import 'package:audioscribe/components/app_header.dart';
import 'package:audioscribe/components/popup_circular_button.dart';
import 'package:audioscribe/pages/collection_page.dart';
import 'package:audioscribe/pages/home_page.dart';
import 'package:audioscribe/pages/settings_page.dart';
import 'package:audioscribe/utils/file_ops/read_json.dart';
import 'package:audioscribe/components/camera_preview.dart';
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
    const HomePage(key: ValueKey('HomePage')),
    const CollectionPage(key: ValueKey('CollectionPage')),
    const SettingsPage(key: ValueKey('SettingsPage'))
  ];

  /// Used to navigate to different screens/pages
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
    String? currentUser =
        FirebaseAuth.instance.currentUser?.email?.split('@')[0];
    switch (_selectedIndex) {
      case 0:
        return '${currentUser?[0].toUpperCase()}${currentUser?.substring(1).toLowerCase()}';
      case 1:
        return 'Your collection';
      case 2:
        return 'Settings';
      default:
        return 'AudioScribe';
    }
  }

  Future showModalOptions() {
    return showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return Container(
            decoration: const BoxDecoration(
                color: Color(0xFF242424),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15.0),
                  topRight: Radius.circular(15.0),
                )),
            child: SizedBox(
                height: 200,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // upload button
                      PopUpCircularButton(
                          buttonIcon: Icon(Icons.file_upload,
                              color: Colors.white, size: 35.0),
                          onTap: _uploadBook,
                          label: 'Upload'),

                      // horizontal spacing
                      const SizedBox(width: 60.0),

                      // camera button
                      PopUpCircularButton(
                          buttonIcon: const Icon(Icons.camera,
                              color: Colors.white, size: 35.0),
                          onTap: () => _navigateToCameraScreen(context),
                          label: 'Camera'),
                    ])),
          );
        });
  }

  Future<void> _uploadBook() async {
    // Use FilePicker to let the user select a text file
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt'],
    );

    if (result != null) {
      // Get the selected file
      PlatformFile file = result.files.first;

      // Read the file as a string
      String fileContent = await File(file.path!).readAsString();

      // // Use the path package to get the file name without extension
      // String fileName = path.basenameWithoutExtension(file.path!);

      // Call your custom function with the file content and file name
      _navigateToUploadBookPage(context, fileContent);
    } else {
      // User canceled the picker
      print("No file selected");
    }
  }

  void _navigateToCameraScreen(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => CameraScreen(),
    ));
  }

  void _navigateToUploadBookPage(BuildContext context, String text) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => UploadBookPage(text: text),
    ));
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
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _widgetOptions.elementAt(_selectedIndex),
                    // IndexedStack(
                    // 	index: _selectedIndex,
                    // 	children: _widgetOptions,
                    // )
                  ),
                )
              ],
            ),
          )
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
      onPressed: showModalOptions,
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
                icon: Icon(Icons.home,
                    size: 30.0,
                    color: _selectedIndex == 0
                        ? const Color(0xFF9260FC)
                        : Colors.white)),
            const Spacer(),
            const Spacer(),
            const SizedBox(width: 48),
            IconButton(
              onPressed: () => _onItemTapped(1),
              icon: Icon(Icons.bookmark,
                  size: 30.0,
                  color: _selectedIndex == 1
                      ? const Color(0xFF9260FC)
                      : Colors.white),
            ),
            const Spacer(),
          ],
        ));
  }
}
