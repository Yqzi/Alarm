import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PrayerButton extends StatefulWidget {
  final TimeOfDay time;
  final String name;
  final String formmatedTime;
  final NotificationStatus status;
  final Color? color;
  final double height;
  final double? fontSize;

  const PrayerButton({
    super.key,
    required this.time,
    required this.name,
    required this.formmatedTime,
    this.color,
    this.height = 200,
    this.fontSize = 30,
    this.status = NotificationStatus.notification,
  });

  @override
  State<PrayerButton> createState() => _PrayerButtonState();
}

class _PrayerButtonState extends State<PrayerButton> {
  NotificationStatus state = NotificationStatus.mute;
  IconData icon = FontAwesomeIcons.volumeXmark;

  DateTime get notifTime {
    final now = new DateTime.now();
    return new DateTime(
      now.year,
      now.month,
      now.day,
      widget.time.hour,
      widget.time.minute,
    );
  }

  @override
  void initState() {
    state = widget.status;
    setIcon();
    super.initState();
  }

  void getState(value) {
    setState(() {
      state = value;
      setIcon();
    });
  }

  void setIcon() {
    if (state == NotificationStatus.mute) {
      icon = FontAwesomeIcons.volumeXmark;

      return;
    }
    if (state == NotificationStatus.notification) {
      icon = Icons.notifications;
      return;
    }
    if (state == NotificationStatus.alarm) {
      icon = Icons.volume_up;
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
                name: widget.name,
                formmatedTime: widget.formmatedTime,
                state: getState,
                status: state,
              ),
            );
          },
          child: Ink.image(
            alignment: Alignment(0, 0.5),
            height: widget.height,
            image: AssetImage('assets/${widget.name}.jpg'),
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
                      "${widget.name} - ${widget.formmatedTime}",
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
    super.key,
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
