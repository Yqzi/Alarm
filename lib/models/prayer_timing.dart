import 'package:adhan/create_prayer_button.dart';
import 'package:adhan/repositories/notification.dart';
import 'package:adhan/utilities.dart';
import 'package:flutter/material.dart';

class PrayerTiming {
  final Prayer fajr;
  final Prayer dhuhr;
  final Prayer asr;
  final Prayer maghrib;
  final Prayer isha;
  final Prayer sunrise;
  final Prayer sunset;

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

  factory PrayerTiming.fromJson(Map<String, dynamic> j) {
    Map<String, Object?> m = j["timings"];
    return PrayerTiming(
      fajr: Prayer.name(fajrName, m, 0),
      dhuhr: Prayer.name(dhuhrName, m, 1),
      asr: Prayer.name(asrName, m, 2),
      maghrib: Prayer.name(maghribName, m, 3),
      isha: Prayer.name(ishaName, m, 4),
      sunrise: Prayer.name(riseName, m, 5, s: NotificationStatus.mute),
      sunset: Prayer.name(setName, m, 6, s: NotificationStatus.mute),
    );
  }
}

TimeOfDay _todayWithTime(String time) {
  List<String> times = time.split("(")[0].split(":");
  return TimeOfDay(hour: int.parse(times[0]), minute: int.parse(times[1]));
}

class Prayer {
  final String name;
  final TimeOfDay time;
  final int id;
  NotificationStatus _status = NotificationStatus.notification;

  Prayer({
    required this.name,
    required this.time,
    required this.id,
  });

  Prayer.name(
    this.name,
    Map<String, dynamic> m,
    this.id, {
    NotificationStatus s = NotificationStatus.notification,
  }) : time = _todayWithTime(m[name] as String) {
    String x = Preferences.load(name) ?? s.name;

    setStatus = NotificationStatus.values.firstWhere((e) => e.name == x);
  }

  void set setStatus(NotificationStatus s) {
    _status = s;
    Preferences.save(name, _status.name);
    _setNotification();
  }

  NotificationStatus get status => _status;

  void _setNotification() async {
    if (_status == NotificationStatus.mute) {
      Notif.cancelNotification(id);
      return;
    }
    bool sound = _status == NotificationStatus.alarm;
    Notif.scheduleNotification(
      name,
      name == "Sunrise"
          ? "Who's gonna carry the boats?"
          : name == "Sunset"
              ? "The sun has fallen"
              : "It is time for Salat",
      _notifTime,
      id: id,
      sound: sound,
    );
  }

  DateTime get _notifTime {
    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute,
      now.second + 10,
      // widget.prayer.time.hour,
      // widget.prayer.time.minute,
    );
  }
}
