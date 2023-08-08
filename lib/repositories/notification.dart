import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart';

class Notif {
  static final _flnp _notifPlugin = _flnp();

  static Future<bool> initializeNotification() async {
    final _ais _androidS = _ais('mipmap/ic_launcher');
    InitializationSettings initSet = InitializationSettings(android: _androidS);
    await _notifPlugin.initialize(initSet);
    return true;
  }

  static bool? _isInitialized;

  static Future<void> cancelNotification(int id) async {
    _notifPlugin.cancel(id);
  }

  static Future<void> scheduleNotification(
    String title,
    String body,
    DateTime time, {
    required int id,
    bool sound = false,
  }) async {
    _isInitialized = _isInitialized ?? await initializeNotification();
    _and ands = _and(
      'channelID: ' + sound.toString(),
      'channelName: ',
      importance: Importance.max,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound('a'),
      autoCancel: false,
      playSound: sound,
    );

    NotificationDetails nd = NotificationDetails(android: ands);

    await _notifPlugin.zonedSchedule(
      id,
      title,
      body,
      TZDateTime.from(time, local),
      nd,
      uiLocalNotificationDateInterpretation: _uilnf.absoluteTime,
    );
  }
}

typedef _flnp = FlutterLocalNotificationsPlugin;
typedef _uilnf = UILocalNotificationDateInterpretation;
typedef _ais = AndroidInitializationSettings;
typedef _and = AndroidNotificationDetails;
