import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _plugin.initialize(initSettings);

    // Prompt for notification permissions on modern Android 13+ architectures
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  static Future<void> triggerAlert({
    required int id,
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails
    androidChannelDetails = AndroidNotificationDetails(
      'smartbite_bakery_alerts',
      'Bakery System Alerts',
      channelDescription:
          'Notifications regarding inventory additions, shifts, and critical expiries',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidChannelDetails,
    );

    await _plugin.show(id, title, body, platformDetails);
  }
}
