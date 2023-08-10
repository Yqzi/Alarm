import 'package:adhan/models/prayer_timing.dart';
import 'package:adhan_dart/adhan_dart.dart';

class PrayerTimeCalculator {
  final double lat;
  final double long;

  static PrayerTimeCalculator? instance;

  PrayerTimeCalculator._new(
    this.lat,
    this.long,
  );

  factory PrayerTimeCalculator.create(
      {required double lat, required double long}) {
    instance = instance ?? PrayerTimeCalculator._new(lat, long);
    return instance!;
  }

  DateTime get _now => DateTime.now();

  Future<PrayerTiming> getTimes() async {
    Coordinates coordinates = Coordinates(lat, long);

    // Parameters
    CalculationParameters params = CalculationMethod.MuslimWorldLeague();
    params.madhab = Madhab.Hanafi;
    PrayerTimes prayerTimes = PrayerTimes(
      coordinates,
      DateTime.now(),
      params,
      precision: true,
    );

    // Prayer times
    DateTime fajrTime = prayerTimes.fajr!;
    DateTime sunriseTime = prayerTimes.sunrise!;
    DateTime dhuhrTime = prayerTimes.dhuhr!;
    DateTime asrTime = prayerTimes.asr!;
    DateTime maghribTime = prayerTimes.maghrib!;
    DateTime ishaTime = prayerTimes.isha!;

    Map<String, dynamic> timesList = {
      "Fajr": fajrTime,
      "Sunrise": sunriseTime,
      "Dhuhr": dhuhrTime,
      "Asr": asrTime,
      "Maghrib": maghribTime,
      "Sunset": maghribTime,
      "Isha": ishaTime,
    };

    return PrayerTiming.fromCalculator(timesList);
  }
}
