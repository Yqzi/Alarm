import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

String country = "Canada";
String state = "Alberta";
String city = "Edmonton";
String url =
    "http://api.aladhan.com/v1/calendarByAddress/2023/7?address=$city,$state,$country&method=2";

Map<String, String> headers = {
  "X-RapidAPI-Key": "PLACE HOLEDER!!!!!!!!!!!!!!!!!!!!!!!!!",
  "X-RapidAPI-Host": "aladhan.p.rapidapi.com"
};

class PrayerTiming {
  final String time;
  final String prayer;

  const PrayerTiming({required this.time, required this.prayer});

  factory PrayerTiming.fromJson(Map<String, dynamic> json) {
    return PrayerTiming(prayer: json['prayer'], time: json['time']);
  }
}

Future<PrayerTiming> getTimes() async {
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    return PrayerTiming.fromJson(jsonDecode(response.body));
  } else {
    throw Exception("failed to load times");
  }
}
