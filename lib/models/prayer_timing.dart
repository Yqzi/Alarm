import 'package:adhan/create_prayer_button.dart';
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

  factory PrayerTiming.fromJson(Map<String, dynamic> json) {
    Map<String, Object?> m = json["timings"];
    return PrayerTiming(
      fajr: Prayer.name(fajrName, m, 0),
      dhuhr: Prayer.name(dhuhrName, m, 1),
      asr: Prayer.name(asrName, m, 2),
      maghrib: Prayer.name(maghribName, m, 3),
      isha: Prayer.name(ishaName, m, 4),
      sunrise: Prayer.name(riseName, m, 5),
      sunset: Prayer.name(setName, m, 6),
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
  NotificationStatus status;

  Prayer({
    required this.name,
    this.status = NotificationStatus.notification,
    required this.time,
    required this.id,
  });

  Prayer.name(
    this.name,
    Map<String, dynamic> m,
    this.id, [
    this.status = NotificationStatus.notification,
  ]) : time = _todayWithTime(m[name] as String);
}
