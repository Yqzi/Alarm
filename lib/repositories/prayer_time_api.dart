import 'dart:convert';
import 'package:adhan/models/prayer_timing.dart';
import 'package:adhan/private.dart';
import 'package:http/http.dart' as http;

class PrayerTimeAPI {
  final String lat;
  final String long;

  PrayerTimeAPI({required this.lat, required this.long});

  String get url =>
      "https://api.aladhan.com/v1/calendar/2023/7?latitude=$lat&longitude=$long&method=2";

  Future<PrayerTiming> getTimes() async {
    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      return PrayerTiming.fromJson(
        jsonDecode(response.body)['data'][DateTime.now().day - 1],
      );
    } else {
      throw Exception("failed to load times");
    }
  }
}
