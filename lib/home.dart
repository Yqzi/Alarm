import 'dart:async';

import 'package:adhan/models/prayer_timing.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:adhan/repositories/prayer_time_calculator.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'create_prayer_button.dart';

class AdhanHome extends StatefulWidget {
  const AdhanHome({super.key});

  @override
  State<AdhanHome> createState() => _AdhanHomeState();
}

class _AdhanHomeState extends State<AdhanHome> {
  final Color _color = Color.fromRGBO(230, 230, 250, 1);
  late Future<PrayerTiming> futureTimings;
  PrayerTimeCalculator? prayerTimeCalculator;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    futureTimings = getLocationAndPrayerTimings();
  }

  /// Uses a permission handler to obtain the location and capablity of displaying notifications,
  /// thus creating an instance using the permissions to create set each notifications respective to their location.
  Future<PrayerTiming> getLocationAndPrayerTimings() async {
    var location = Location();
    var serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        throw "NO";
      }
    }

    // Handles permissions regarding location.
    var _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        throw "NO";
      }
    }
    var currentLocation = await location.getLocation();

    prayerTimeCalculator = prayerTimeCalculator ??
        PrayerTimeCalculator(
          currentLocation.latitude!,
          currentLocation.longitude!,
        );

    // Handles permissions regarding notifications.
    bool isNotificationAllowed =
        await AwesomeNotifications().isNotificationAllowed();
    if (!isNotificationAllowed) {
      await showCustomDialog();
    }
    // done toerh

    initBackgourndService(prayerTimeCalculator!);
    setState(() => isLoading = false);
    // creates all prayer notifications.
    return await prayerTimeCalculator!.getTimes();
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
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text("ADHAN"),
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: RefreshIndicator(
        displacement: 20,
        onRefresh: () async {
          isLoading = true;
          futureTimings = getLocationAndPrayerTimings();
          setState(() => null);
        },
        child: ListView(
          children: [
            Container(
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

Future<void> initBackgourndService(PrayerTimeCalculator ptc) async {
  await BackgroundFetch.configure(
    BackgroundFetchConfig(
      minimumFetchInterval: 360,
      stopOnTerminate: false,
      enableHeadless: true,
      requiresBatteryNotLow: false,
      requiresCharging: false,
      requiresStorageNotLow: false,
      requiresDeviceIdle: false,
      requiredNetworkType: NetworkType.NONE,
      startOnBoot: true,
    ),
    (String taskId) async {
      ptc.getTimes();

      BackgroundFetch.finish(taskId);
    },
    (String taskId) async {
      BackgroundFetch.finish(taskId);
    },
  );

  await BackgroundFetch.stop();
  await BackgroundFetch.start();
}
