import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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
}