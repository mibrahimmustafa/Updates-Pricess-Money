/// No-op stub used on web (browser notifications out of MVP scope).
Future<bool> requestNotifyPermission() async => false;

Future<void> initNotifications() async {}

Future<void> showPriceAlertNotification({
  required String title,
  required String body,
}) async {}
