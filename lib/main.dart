import 'package:adhan/home.dart';
import 'package:adhan/repositories/prayer_time_calculator.dart';
import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:timezone/data/latest.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:shared_preferences_android/shared_preferences_android.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'scheduled_channel',
        channelName: 'Scheduled Notifications',
        defaultColor: Colors.teal,
        locked: true,
        importance: NotificationImportance.Max,
        channelShowBadge: true,
        channelDescription: null,
      ),
    ],
  );

  initializeTimeZones();

  runApp(const MaterialApp(home: AdhanHome()));
  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
}

@pragma('vm:entry-point')
void backgroundFetchHeadlessTask(HeadlessTask task) async {
  SharedPreferencesAndroid.registerWith();
  String taskId = task.taskId;
  bool isTimeout = task.timeout;

  if (DateTime.now().hour > 6) {
    BackgroundFetch.finish(taskId);
    return;
  }

  if (isTimeout) {
    print("[BackgroundFetch] Headless task timed-out: $taskId");
    BackgroundFetch.finish(taskId);
    return;
  }
  print('[BackgroundFetch] Headless event received. $taskId');

  if (taskId == "flutter_background_fetch") {
    print("Before Location await");
    print("After Location await");
    final PrayerTimeCalculator prayerTimeCalculator =
        PrayerTimeCalculator.fromCache();
    prayerTimeCalculator.getTimes();
  }

  BackgroundFetch.finish(taskId);
}
