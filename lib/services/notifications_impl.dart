import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final _plugin = FlutterLocalNotificationsPlugin();

/// Requests permission (Android 13+ / iOS) then initializes the plugin.
/// Returns true when notifications are usable.
Future<bool> requestNotifyPermission() async {
  try {
    if (Platform.isAndroid) {
      final granted = await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      return granted ?? true;
    }
    return true;
  } catch (_) {
    return false;
  }
}

Future<void> initNotifications() async {
  try {
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );
  } catch (_) {}
}

Future<void> showPriceAlertNotification({
  required String title,
  required String body,
}) async {
  try {
    await _plugin.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000 % 2147483647,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'price_alerts',
          'Price alerts',
          channelDescription: 'Alerts when metal prices reach targets',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  } catch (_) {}
}
