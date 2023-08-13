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
        channelKey: 'Prayer_channel',
        channelName: 'Prayer Channel',
        defaultColor: Colors.teal,
        locked: true,
        importance: NotificationImportance.Max,
        channelShowBadge: true,
        channelDescription: null,
        defaultPrivacy: NotificationPrivacy.Public,
      ),
    ],
  );

  initializeTimeZones();

  runApp(MaterialApp(
    home: AdhanHome(),
    theme: ThemeData.dark(),
  ));
  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
}

// Runs a check every 6 hours to initilize new notifications.
@pragma('vm:entry-point')
void backgroundFetchHeadlessTask(HeadlessTask task) async {
  SharedPreferencesAndroid.registerWith();
  String taskId = task.taskId;
  bool isTimeout = task.timeout;

  if (DateTime.now().hour >= 1) {
    BackgroundFetch.finish(taskId);
    return;
  }

  if (isTimeout) {
    BackgroundFetch.finish(taskId);
    return;
  }

  if (taskId == "flutter_background_fetch") {
    final PrayerTimeCalculator prayerTimeCalculator =
        PrayerTimeCalculator.fromCache();
    prayerTimeCalculator.getTimes();
  }

  BackgroundFetch.finish(taskId);
}
