import 'package:alarm/utilities.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class PrayerTiming {
  final TimeOfDay fajr;
  final TimeOfDay dhuhr;
  final TimeOfDay asr;
  final TimeOfDay maghrib;
  final TimeOfDay isha;
  final TimeOfDay sunrise;
  final TimeOfDay sunset;

  PrayerTiming({
    required this.fajr,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.sunrise,
    required this.sunset,
  });

  static String get fajrName => "Fajr";
  static String get dhuhrName => "Dhuhr";
  static String get asrName => "Asr";
  static String get maghribName => "Maghrib";
  static String get ishaName => "Isha";
  static String get riseName => "Sunrise";
  static String get setName => "Sunset";

  int _id = 0;

  factory PrayerTiming.fromJson(Map<String, dynamic> json) {
    Map<String, Object?> m = json["timings"];
    return PrayerTiming(
      fajr: _todayWithTime(m[fajrName] as String),
      dhuhr: _todayWithTime(m[dhuhrName] as String),
      asr: _todayWithTime(m[asrName] as String),
      maghrib: _todayWithTime(m[maghribName] as String),
      isha: _todayWithTime(m[ishaName] as String),
      sunrise: _todayWithTime(m[riseName] as String),
      sunset: _todayWithTime(m[setName] as String),
    );
  }

  Future<void> _createPrayerReminderNotif(
      TimeOfDay schedule, String name) async {
    _id += 1;
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: _id,
        channelKey: 'scheduled_channel',
        title: '${Emojis.animals_camel} Reminder!',
        body: "Time for $name",
        notificationLayout: NotificationLayout.Default,
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'MARK_DONE',
          label: "Mark Done",
        ),
      ],
      schedule: NotificationCalendar(
        hour: schedule.hour,
        minute: schedule.minute,
        second: 0,
        millisecond: 0,
      ),
    );
  }

  void createAllNotifications() {
    List<TimeOfDay> times = [
      fajr,
      dhuhr,
      asr,
      maghrib,
      isha,
      sunrise,
      sunset,
    ];
    List<String> names = [
      fajrName,
      dhuhrName,
      asrName,
      maghribName,
      ishaName,
      riseName,
      setName,
    ];

    for (var i = 0; i < times.length; i++) {
      _createPrayerReminderNotif(times[i], names[i]);
    }
  }
}

TimeOfDay _todayWithTime(String time) {
  List<String> times = time.split("(")[0].split(":");
  return TimeOfDay(hour: int.parse(times[0]), minute: int.parse(times[1]));
}
