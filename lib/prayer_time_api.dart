import 'dart:convert';
import 'package:alarm/private.dart';
import 'package:http/http.dart' as http;

String country = "Canada";
String state = "Alberta";
String city = "Edmonton";
String url =
    "http://api.aladhan.com/v1/calendarByAddress/2023/7?address=$city,$state,$country&method=2";

class PrayerTiming {
  final Map timings;
  const PrayerTiming({required this.timings});

  factory PrayerTiming.fromJson(Map<String, dynamic> json) {
    return PrayerTiming(timings: json['data'][0]["timings"]);
  }

  PrayerTiming.fromJson2(Map<String, dynamic> json)
      : timings = json['data'][0]["timings"];
}

Future<PrayerTiming> getTimes() async {
  final response = await http.get(Uri.parse(url), headers: headers);

  if (response.statusCode == 200) {
    return PrayerTiming.fromJson(jsonDecode(response.body));
  } else {
    throw Exception("failed to load times");
  }
}
