import 'package:alarm/models/prayer_timing.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:alarm/repositories/prayer_time_api.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

void main() {
  AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'basic_channel',
        channelName: 'basic Notifications',
        defaultColor: Colors.teal,
        importance: NotificationImportance.High,
        channelShowBadge: true,
        channelDescription: null,
      ),
      NotificationChannel(
        channelKey: 'scheduled_channel',
        channelName: 'Scheduled Notifications',
        defaultColor: Colors.teal,
        locked: true,
        importance: NotificationImportance.High,
        channelShowBadge: true,
        channelDescription: null,
      )
    ],
  );
  runApp(const MaterialApp(home: Alarm()));
}

class Alarm extends StatefulWidget {
  const Alarm({super.key});

  @override
  State<Alarm> createState() => _AlarmState();
}

class _AlarmState extends State<Alarm> {
  late Future<PrayerTiming> futurePrayerTiming;
  late PrayerTimeAPI prayerTimeAPI;

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

    // other
    bool isNotificationAllowed =
        await AwesomeNotifications().isNotificationAllowed();
    if (!isNotificationAllowed) {
      await showCustomDialog();
    }
    // done toerh

    return await prayerTimeAPI.getTimes();
  }

  Future<dynamic> showCustomDialog() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Allow Notifications'),
        content: const Text('Allow Notifications'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              "Don't Allow",
              style: TextStyle(color: Colors.grey, fontSize: 18),
            ),
          ),
          TextButton(
            onPressed: () => AwesomeNotifications()
                .requestPermissionToSendNotifications()
                .then((_) => Navigator.pop(context)),
            child: const Text(
              "Allow",
              style: TextStyle(
                  color: Colors.teal,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: Container(
        decoration: BoxDecoration(border: Border.all(color: Colors.black)),
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            Center(
              child: FutureBuilder<PrayerTiming>(
                future: getLocationAndPrayerTimings(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var s = snapshot.data!;
                    s.createAllNotifications();
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
                    return Text('${snapshot.error}');
                  }
                  return const CircularProgressIndicator();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
