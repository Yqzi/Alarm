import 'package:adhan/models/prayer_timing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:timezone/timezone.dart';

class PrayerButton extends StatefulWidget {
  final Prayer prayer;
  final Color? color;
  final double height;
  final double? fontSize;

  const PrayerButton({
    super.key,
    this.color,
    this.height = 200,
    this.fontSize = 30,
    required this.prayer,
  });

  @override
  State<PrayerButton> createState() => _PrayerButtonState();
}

class _PrayerButtonState extends State<PrayerButton> {
  NotificationStatus state = NotificationStatus.mute;
  IconData icon = FontAwesomeIcons.volumeXmark;
  Notif notif = Notif();

  DateTime get notifTime {
    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute,
      now.second + 10,
      // widget.prayer.time.hour,
      // widget.prayer.time.minute,
    );
  }

  @override
  void initState() {
    print(widget.prayer.time);
    state = widget.prayer.status;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await notif.initializeNotification();
      setState(() {
        setIcon();
      });
    });

    super.initState();
  }

  void getState(value) {
    setState(() {
      state = value;
      setIcon();
    });
  }

  void create_mute() async {
    (await Notif._flutterLocalNotificationsPlugin).cancel(widget.prayer.id);
  }

  void omnipotentNotif(bool sound) async {
    notif.scheduleNotification(
      widget.prayer.name,
      widget.prayer.name == "Sunrise"
          ? "Who's gonna carry the boats?"
          : widget.prayer.name == "Sunset"
              ? "The sun has fallen"
              : "It is time for Salat",
      notifTime,
      id: widget.prayer.id,
      sound: sound,
    );
  }

  void setIcon() {
    if (state == NotificationStatus.mute) {
      icon = FontAwesomeIcons.volumeXmark;
      create_mute();
      return;
    }
    if (state == NotificationStatus.notification) {
      icon = Icons.notifications;
      omnipotentNotif(false);
      return;
    }
    if (state == NotificationStatus.alarm) {
      icon = Icons.volume_up;
      omnipotentNotif(true);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(28),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => _Dialog(
                name: widget.prayer.name,
                formmatedTime: widget.prayer.time.format(context),
                state: getState,
                status: state,
              ),
            );
          },
          child: Ink.image(
            alignment: Alignment(0, 0.5),
            height: widget.height,
            image: AssetImage('assets/${widget.prayer.name}.jpg'),
            fit: BoxFit.fitWidth,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                      padding: const EdgeInsets.only(top: 8, right: 20),
                      child: Icon(icon, color: widget.color)),
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 6, left: 20),
                    child: Text(
                      "${widget.prayer.name} - ${widget.prayer.time.format(context)}",
                      style: TextStyle(
                        color: widget.color,
                        fontSize: widget.fontSize,
                        fontFamily: "AguafinaScript",
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum NotificationStatus { alarm, notification, mute }

class _Dialog extends StatefulWidget {
  const _Dialog({
    required this.name,
    required this.formmatedTime,
    required this.state,
    required this.status,
  });

  final String name;
  final String formmatedTime;
  final void Function(dynamic) state;
  final NotificationStatus status;

  @override
  State<_Dialog> createState() => _DialogState();
}

class _DialogState extends State<_Dialog> {
  NotificationStatus status = NotificationStatus.notification;

  void boxSelected(NotificationStatus box) {
    setState(() {
      status = box;
      widget.state(status);
    });
  }

  @override
  void initState() {
    status = widget.status;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${widget.name} - ${widget.formmatedTime}'),
      actions: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CheckBox(
              onPressed: () => boxSelected(NotificationStatus.alarm),
              name: "Alarm",
              isSelected: status == NotificationStatus.alarm,
            ),
            SizedBox(height: 5),
            _CheckBox(
              onPressed: () => boxSelected(NotificationStatus.notification),
              name: "Notification",
              isSelected: status == NotificationStatus.notification,
            ),
            SizedBox(height: 5),
            _CheckBox(
              onPressed: () => boxSelected(NotificationStatus.mute),
              name: "Mute",
              isSelected: status == NotificationStatus.mute,
            ),
            SizedBox(height: 5),
            Divider(),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Center(
                child: const Text('DONE'),
              ),
            ),
          ],
        ),
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(20),
        ),
      ),
    );
  }
}

class _CheckBox extends StatelessWidget {
  final String name;
  final bool isSelected;
  final void Function() onPressed;
  const _CheckBox({
    required this.name,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
        child: Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(width: 2),
              ),
              child: SizedBox(width: 20, height: 20),
            ),
            SizedBox(width: 15),
            Text(
              name,
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

class Notif {
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  final AndroidInitializationSettings _androidInitializationSettings =
      AndroidInitializationSettings('mipmap/ic_launcher');

  Future<void> initializeNotification() async {
    InitializationSettings initializationSettings =
        InitializationSettings(android: _androidInitializationSettings);
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> scheduleNotification(
    String title,
    String body,
    DateTime time, {
    required int id,
    bool sound = true,
  }) async {
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'dddddddd',
      'channelName',
      importance: Importance.max,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound('a'),
      autoCancel: false,
      playSound: sound,
    );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    await _flutterLocalNotificationsPlugin.zonedSchedule(id, title, body,
        TZDateTime.from(time, local), await notificationDetails,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  }
}
