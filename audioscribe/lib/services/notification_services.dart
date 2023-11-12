import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'dart:math';

import 'package:audioscribe/utils/database/book_model.dart';
import '../data_classes/book.dart';

class NotificationService {
	static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

	static Future<void> initialize() async {
		const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('ic_stat_book');
		const InitializationSettings initializationSettings = InitializationSettings(
			android: initializationSettingsAndroid
		);
		await _notificationsPlugin.initialize(initializationSettings);
	}

	static Future<void> showWelcomeNotification() async {
		var androidDetails = const AndroidNotificationDetails(
			'channelId', 'channelName',
			channelDescription: 'channelDescription',
			importance: Importance.max,
			priority: Priority.high,
		);

		var generalNotificationDetails = NotificationDetails(
			android: androidDetails
		);

		await _notificationsPlugin.show(
			0,
			'Welcome to AudioScribe!',
			'Explore and bookmark your favourite books',
			generalNotificationDetails
		);
	}

	static Future<void> sendRandomBookRecommendation() async {
		var androidDetails = const AndroidNotificationDetails(
		'channelId', 'channelName',
		channelDescription: 'channelDescription',
		importance: Importance.max,
		priority: Priority.high,
		);

		var generalNotificationDetails = NotificationDetails(
		android: androidDetails
		);

		while (true) {
			await Future.delayed(const Duration(minutes: 1));

			String notifTitle = "Have you read this book?";

			String notifBody = 'We think that you might like to read ${await _getRandomBook()}';

			await _notificationsPlugin.show(
					0,
					notifTitle,
					notifBody,
					generalNotificationDetails
			);
		}
	}

	static Future<String> _getRandomBook() async {
		BookModel bookModel = BookModel();

		List<Book> books = await bookModel.getAllBooks();

		if (books.isNotEmpty) {
			int randomIndex = Random().nextInt(books.length);

			return books[randomIndex].title;
		} else {
			return '';
		}
	}
}