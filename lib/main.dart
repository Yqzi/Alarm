import 'package:alarm/models/prayer_timing.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:alarm/repositories/prayer_time_api.dart';

void main() {
  runApp(const Alarm());
}

class Alarm extends StatefulWidget {
  const Alarm({super.key});

  @override
  State<Alarm> createState() => _AlarmState();
}

class _AlarmState extends State<Alarm> {
  late Future<PrayerTiming> futurePrayerTiming;
  late final PrayerTimeAPI prayerTimeAPI;

  Future<PrayerTiming> getLocationAndPrayerTimings() async {
    var location = Location();
    var serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        throw "this no work";
      }
    }

    var _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        throw "NO";
      }
    }
    var currentLocation = await location.getLocation();

    // TODO find
    prayerTimeAPI = PrayerTimeAPI(
      lat: currentLocation.latitude.toString(),
      long: currentLocation.longitude.toString(),
    );
    return await prayerTimeAPI.getTimes();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Color(0xFFf9f9f9),
        appBar: AppBar(
          backgroundColor: Color(0xFFf9f9f9),
          elevation: 0.0,
          centerTitle: true,
          title: const Text(
            "ADHAN",
            style: TextStyle(color: Colors.black),
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.menu,
              color: Colors.black,
            ),
            onPressed: () {},
          ),
        ),
        body: Column(
          children: [
            SafeArea(
              child: Container(
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.black)),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height - 200,
                child: Center(
                  child: FutureBuilder<PrayerTiming>(
                    future: getLocationAndPrayerTimings(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        print(snapshot.data);
                        var s = snapshot.data!;
                        return Column(
                          children: [
                            Text("Fajr: ${s.fajr.format(context)}"),
                            Text("Sunrise: ${s.sunrise.format(context)}"),
                            Text("Dhuhr: ${s.dhuhr.format(context)}"),
                            Text("Asr: ${s.asr.format(context)}"),
                            Text("Maghrib: ${s.maghrib.format(context)}"),
                            Text("Sunset: ${s.sunset.format(context)}"),
                            Text("Isha: ${s.isha.format(context)}"),
                          ],
                        );
                      } else if (snapshot.hasError) {
                        print('${snapshot.data}');
                        return Text('${snapshot.error}');
                      }
                      print('lele');
                      return const CircularProgressIndicator();
                    },
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Container(
                height: 126,
              ),
            )
          ],
        ),
      ),
    );
  }
}
