import 'package:adhan/models/prayer_timing.dart';
import 'package:adhan_dart/adhan_dart.dart';

class PrayerTimeCalculator {
  final double lat;
  final double long;

  PrayerTimeCalculator(this.lat, this.long);

  Future<PrayerTiming> getTimes() async {
    Coordinates coordinates = Coordinates(lat, long);

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

    return PrayerTiming.fromCalculator(timesList);
  }
}
