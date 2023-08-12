import 'package:adhan/models/prayer_timing.dart';
import 'package:adhan/repositories/notification.dart';
import 'package:adhan/utilities.dart';
import 'package:adhan_dart/adhan_dart.dart';

class PrayerTimeCalculator {
  late final double lat;
  late final double long;

  final Preferences prefs = Preferences();
  final Notif notif = Notif();

  PrayerTimeCalculator(this.lat, this.long);

  PrayerTimeCalculator.fromCache();

  Future<PrayerTiming> getTimes() async {
    await prefs.init();
    Coordinates coordinates;

    try {
      coordinates = Coordinates(lat, long);
    } catch (e) {
      coordinates = prefs.loadCoord()!;
      lat = coordinates.latitude;
      long = coordinates.longitude;
    }

    // Parameters
    CalculationParameters params = CalculationMethod.NorthAmerica();
    params.madhab = Madhab.Hanafi;
    PrayerTimes prayerTimes = PrayerTimes(
      coordinates,
      DateTime.now(),
      params,
      precision: true,
    );

    // Prayer times
    DateTime fajrTime = prayerTimes.fajr!.toLocal();
    DateTime sunriseTime = prayerTimes.sunrise!.toLocal();
    DateTime dhuhrTime = prayerTimes.dhuhr!.toLocal();
    DateTime asrTime = prayerTimes.asr!.toLocal();
    DateTime maghribTime = prayerTimes.maghrib!.toLocal();
    DateTime ishaTime = prayerTimes.isha!.toLocal();

    Map<String, dynamic> timesList = {
      PrayerTiming.fajrName: fajrTime,
      PrayerTiming.riseName: sunriseTime,
      PrayerTiming.dhuhrName: dhuhrTime,
      PrayerTiming.asrName: asrTime,
      PrayerTiming.maghribName: maghribTime,
      PrayerTiming.setName: maghribTime,
      PrayerTiming.ishaName: ishaTime,
    };

    prefs.saveCoord(coordinates);
    return PrayerTiming.fromCalculator(timesList, prefs, notif);
  }
}
