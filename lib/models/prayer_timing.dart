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

  factory PrayerTiming.fromJson(Map<String, dynamic> json) {
    Map<String, Object?> m = json['data'][DateTime.now().day - 1]["timings"];
    return PrayerTiming(
      fajr: _todayWithTime(m["Fajr"] as String),
      dhuhr: _todayWithTime(m["Dhuhr"] as String),
      asr: _todayWithTime(m["Asr"] as String),
      maghrib: _todayWithTime(m["Maghrib"] as String),
      isha: _todayWithTime(m["Isha"] as String),
      sunrise: _todayWithTime(m["Sunrise"] as String),
      sunset: _todayWithTime(m["Sunset"] as String),
    );
  }
}

TimeOfDay _todayWithTime(String time) {
  List<String> times = time.replaceAll("(MDT)", "").split(":");
  return TimeOfDay(hour: int.parse(times[0]), minute: int.parse(times[1]));
}
