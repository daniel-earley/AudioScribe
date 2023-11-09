import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

Future<void> getBookInformation() async {
	await dotenv.load(fileName: ".env");
	final gutenbergAPIKey = dotenv.env['GUTENBERG_API'];
	print(gutenbergAPIKey);
}