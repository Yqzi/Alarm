import 'dart:async';

import 'package:adhan/models/prayer_timing.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:location/location.dart';
import 'package:adhan/repositories/prayer_time_api.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:alarm/alarm.dart';
import 'create_prayer_button.dart';

void main() async {
  AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'scheduled_channel',
        channelName: 'Scheduled Notifications',
        defaultColor: Colors.teal,
        locked: true,
        importance: NotificationImportance.Max,
        channelShowBadge: true,
        channelDescription: null,
      ),
    ],
  );

  await Alarm.init();

  runApp(const MaterialApp(home: Adhan()));
}

class Adhan extends StatefulWidget {
  const Adhan({super.key});

  @override
  State<Adhan> createState() => _AdhanState();
}

class _AdhanState extends State<Adhan> {
  late PrayerTimeAPI prayerTimeAPI;
  bool hasInternet = false;

  late Future<PrayerTiming> futureTimings;

  @override
  void initState() {
    super.initState();
    InternetConnectionChecker().onStatusChange.listen((event) {
      hasInternet = event == InternetConnectionStatus.connected;
    });
    futureTimings = getLocationAndPrayerTimings(shouldClear);
  }

  bool shouldClear = false;
  bool isLoading = true;

  final Color _color = Color.fromRGBO(230, 230, 250, 1);

  Future<PrayerTiming> getLocationAndPrayerTimings([bool clear = false]) async {
    bool online = false;

    online = hasInternet;
    print(online);

    if (clear && online) PrayerTimeAPI.clearCache();
    print(online);
    shouldClear = false;

    var location = Location();
    var serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        throw "NO";
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

    setState(() => isLoading = false);
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
      body: RefreshIndicator(
        displacement: 20,
        onRefresh: () async {
          shouldClear = true;
          isLoading = true;
          futureTimings = getLocationAndPrayerTimings(shouldClear);
          setState(() => null);
        },
        child: ListView(
          children: [
            Container(
              decoration:
                  BoxDecoration(border: Border.all(color: Colors.black)),
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  if (isLoading) LinearProgressIndicator(),
                  Center(
                    child: FutureBuilder<PrayerTiming>(
                      future: futureTimings,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          var s = snapshot.data!;
                          return Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: PrayerButton(
                                      prayer: s.sunrise,
                                      color: _color,
                                      height: 100,
                                      fontSize: 20,
                                    ),
                                  ),
                                  Expanded(
                                    child: PrayerButton(
                                      prayer: s.sunset,
                                      color: _color,
                                      height: 100,
                                      fontSize: 20,
                                    ),
                                  ),
                                ],
                              ),
                              Divider(),
                              PrayerButton(
                                prayer: s.fajr,
                                color: _color,
                              ),
                              PrayerButton(
                                prayer: s.dhuhr,
                                color: _color,
                              ),
                              PrayerButton(
                                prayer: s.asr,
                                color: _color,
                              ),
                              PrayerButton(
                                prayer: s.maghrib,
                                color: _color,
                              ),
                              PrayerButton(
                                prayer: s.isha,
                                color: _color,
                              ),
                            ],
                          );
                        } else if (snapshot.hasError) {
                          return Text('${snapshot.error}');
                        }
                        return const Column();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
