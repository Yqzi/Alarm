import 'dart:async';

import 'package:adhan/home.dart';
import 'package:adhan/repositories/notification.dart';
import 'package:adhan/utilities.dart';
import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:timezone/data/latest.dart';
import 'package:background_fetch/background_fetch.dart';

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

  await Preferences.init();
  initializeTimeZones();
  await initBackgourndService();

  runApp(const MaterialApp(home: AdhanHome()));
  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
}

@pragma('vm:entry-point')
void backgroundFetchHeadlessTask(HeadlessTask task) async {
  String taskId = task.taskId;
  bool isTimeout = task.timeout;

  if (isTimeout) {
    print("[BackgroundFetch] Headless task timed-out: $taskId");
    BackgroundFetch.finish(taskId);
    return;
  }
  print('[BackgroundFetch] Headless event received. $taskId');

  if (taskId == "flutter_background_fetch") {
    Notif().scheduleNotification(
      DateTime.now().toString(),
      "NOT RUNNING TASK : " + taskId,
      DateTime.now().add(Duration(seconds: 10)),
      id: DateTime.now().second,
      sound: false,
    );
  }

  BackgroundFetch.finish(taskId);
}

Future<void> initBackgourndService() async {
  await BackgroundFetch.configure(
    BackgroundFetchConfig(
      minimumFetchInterval: 15,
      stopOnTerminate: false,
      enableHeadless: true,
      requiresBatteryNotLow: false,
      requiresCharging: false,
      requiresStorageNotLow: false,
      requiresDeviceIdle: false,
      requiredNetworkType: NetworkType.NONE,
      startOnBoot: true,
    ),
    (String taskId) async {
      print("NOT HEADLESS - BGF");
      BackgroundFetch.finish(taskId);
    },
    (String taskId) async {
      print('TIMEOUT');
      BackgroundFetch.finish(taskId);
    },
  );

  await BackgroundFetch.stop();
  await BackgroundFetch.start().then((value) => print("working $value"));
}
