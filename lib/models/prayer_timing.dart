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

  factory PrayerTiming.fromCalculator(
      Map<String, dynamic> j, Preferences prefs, Notif n) {
    Map<String, Object?> m = j;
    return PrayerTiming(
      fajr: Prayer.name(fajrName, m, 0, prefs: prefs, notif: n),
      dhuhr: Prayer.name(dhuhrName, m, 1, prefs: prefs, notif: n),
      asr: Prayer.name(asrName, m, 2, prefs: prefs, notif: n),
      maghrib: Prayer.name(maghribName, m, 3, prefs: prefs, notif: n),
      isha: Prayer.name(ishaName, m, 4, prefs: prefs, notif: n),
      sunrise: Prayer.name(riseName, m, 5, s: _ns.mute, prefs: prefs, notif: n),
      sunset: Prayer.name(setName, m, 6, s: _ns.mute, prefs: prefs, notif: n),
    );
  }
}

TimeOfDay _todayWithTime(DateTime time) {
  return TimeOfDay.fromDateTime(time);
}

class Prayer {
  final String name;
  final TimeOfDay time;
  final int id;
  final Preferences prefs;
  NotificationStatus _status = NotificationStatus.notification;
  final Notif notif;

  Prayer({
    required this.name,
    required this.time,
    required this.id,
    required this.prefs,
    required this.notif,
  });

  Prayer.name(
    this.name,
    Map<String, dynamic> m,
    this.id, {
    required this.prefs,
    required this.notif,
    NotificationStatus s = NotificationStatus.notification,
  }) : time = _todayWithTime(m[name] as DateTime) {
    String x = prefs.load(name) ?? s.name;

    setStatus = NotificationStatus.values.firstWhere((e) => e.name == x);
  }

  void set setStatus(NotificationStatus s) {
    _status = s;
    prefs.save(name, _status.name);
    _setNotification();
  }

  NotificationStatus get status => _status;

  void _setNotification() async {
    if (_status == NotificationStatus.mute) {
      notif.cancelNotification(id);
      return;
    }
    bool sound = _status == NotificationStatus.alarm;
    notif.scheduleNotification(
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
      // now.hour,
      // now.minute,
      // now.second + 10,
      time.hour,
      time.minute,
    );
  }
}

typedef _ns = NotificationStatus;
