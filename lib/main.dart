import 'package:adhan/models/prayer_timing.dart';
import 'package:flutter/material.dart';
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

  await Alarm.init();

  runApp(const MaterialApp(home: Adhan()));
}

class Adhan extends StatefulWidget {
  const Adhan({super.key});

  @override
  State<Adhan> createState() => _AdhanState();
}

class _AdhanState extends State<Adhan> {
  late Future<PrayerTiming> futurePrayerTiming;
  late PrayerTimeAPI prayerTimeAPI;
  final alarmSettings = AlarmSettings(
    id: 42,
    dateTime: DateTime.now().add(Duration(seconds: 30)),
    assetAudioPath: 'assets/alarm.wav',
    loopAudio: true,
    vibrate: true,
    fadeDuration: 0.0,
    notificationBody: "body",
    notificationTitle: "title",
    enableNotificationOnKill: true,
  );

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
    // Alarm.set(alarmSettings: alarmSettings).then((value) => value);
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
      body: ListView(
        children: [
          Container(
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
                        // s.createAllNotifications();
                        return Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: PrayerButton(
                                    name: PrayerTiming.riseName,
                                    time: s.sunrise,
                                    formmatedTime: s.sunrise.format(context),
                                    color: Color.fromRGBO(230, 230, 250, 1),
                                    height: 100,
                                  ),
                                ),
                                Expanded(
                                  child: PrayerButton(
                                    name: PrayerTiming.setName,
                                    time: s.sunset,
                                    formmatedTime: s.sunset.format(context),
                                    color: Color.fromRGBO(230, 230, 250, 1),
                                    height: 100,
                                  ),
                                ),
                              ],
                            ),
                            Divider(),
                            PrayerButton(
                              name: PrayerTiming.fajrName,
                              time: s.fajr,
                              formmatedTime: s.fajr.format(context),
                              color: Color.fromRGBO(230, 230, 250, 1),
                            ),
                            PrayerButton(
                              name: PrayerTiming.dhuhrName,
                              time: s.dhuhr,
                              formmatedTime: s.dhuhr.format(context),
                              color: Color.fromRGBO(230, 230, 250, 1),
                            ),
                            PrayerButton(
                              name: PrayerTiming.asrName,
                              time: s.asr,
                              formmatedTime: s.asr.format(context),
                              color: Color.fromRGBO(230, 230, 250, 1),
                            ),
                            PrayerButton(
                              name: PrayerTiming.maghribName,
                              time: s.maghrib,
                              formmatedTime: s.maghrib.format(context),
                              color: Color.fromRGBO(230, 230, 250, 1),
                            ),
                            PrayerButton(
                              name: PrayerTiming.ishaName,
                              time: s.isha,
                              formmatedTime: s.isha.format(context),
                              color: Color.fromRGBO(230, 230, 250, 1),
                            ),
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
        ],
      ),
    );
  }
}
