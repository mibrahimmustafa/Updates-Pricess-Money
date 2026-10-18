/// Platform-neutral notifications facade.
library;
///
/// Web builds compile the no-op stub; native builds use the real plugin via
/// conditional import so `dart:io` never leaks into web compilation.
export 'notifications_stub.dart' if (dart.library.io) 'notifications_impl.dart'
    show initNotifications, showPriceAlertNotification, requestNotifyPermission;
