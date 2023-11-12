import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

Future<String> saveFile(String filename, String content) async {
	final directory = await getApplicationDocumentsDirectory();
	final file = File('${directory.path}/$filename');
	print(file);
	return file.path;
}