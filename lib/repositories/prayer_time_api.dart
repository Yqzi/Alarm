import 'dart:convert';
import 'dart:io';
import 'package:adhan/models/prayer_timing.dart';
import 'package:adhan/private.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class PrayerTimeAPI {
  final String lat;
  final String long;

  PrayerTimeAPI({required this.lat, required this.long});

  DateTime get _now => DateTime.now();

  String get url =>
      "https://api.aladhan.com/v1/calendar/${_now.year}?latitude=$lat&longitude=$long&method=2";
  static String fileName = 'prayerTimings';

  void saveCache(String s) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final File file = File('$path/$fileName');
    await file.writeAsString(s);
  }

  Future<PrayerTiming> getTimes() async {
    String? rb = await getCachedTimes();

    bool shouldOnline = rb == null || rb == '';

    if (!shouldOnline) {
      shouldOnline = jsonDecode(rb)['${_now.year}'] == null;
    }

    if (shouldOnline) {
      final response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode != 200) {
        throw Exception("failed to load times");
      }

      rb = '{"${_now.year}": ${response.body}}';
      saveCache(rb);
    }

    return PrayerTiming.fromJson(
      jsonDecode(rb!)['${_now.year}']['data']['${_now.month}'][_now.day - 1],
    );
  }

  Future<String?> getCachedTimes() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final File file = await File('$path/$fileName');

    if (await file.exists()) {
      String s = await file.readAsString();
      return s;
    }

    return null;
  }

  static void clearCache() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final File file = await File('$path/$fileName');
    if (file.existsSync()) await file.delete();
  }
}
