import 'package:flutter/material.dart';

class PrayerButton extends StatelessWidget {
  final TimeOfDay time;
  final String name;
  final String formmatedTime;
  final Color? color;
  final double height;

  const PrayerButton({
    super.key,
    required this.time,
    required this.name,
    required this.formmatedTime,
    this.color,
    this.height = 200,
  });

  DateTime datetime() {
    final now = new DateTime.now();
    return new DateTime(now.year, now.month, now.day, time.hour, time.minute);
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
                name: name,
                formmatedTime: formmatedTime,
              ),
            );
          },
          child: Ink.image(
            alignment: Alignment(0, 0.5),
            height: height,
            image: AssetImage('assets/$name.jpg'),
            fit: BoxFit.fitWidth,
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 6, left: 20),
                child: Text(
                  "$name - $formmatedTime",
                  style: TextStyle(
                    color: color,
                    fontSize: 20,
                    fontFamily: "AguafinaScript",
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum Boxes { alarm, notification, mute }

class _Dialog extends StatefulWidget {
  const _Dialog({
    super.key,
    required this.name,
    required this.formmatedTime,
  });

  final String name;
  final String formmatedTime;

  @override
  State<_Dialog> createState() => _DialogState();
}

class _DialogState extends State<_Dialog> {
  Boxes status = Boxes.mute;
  void boxSelected(Boxes box) {
    setState(() {
      status = box;
    });
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
              onPressed: () => boxSelected(Boxes.alarm),
              name: "Alarm",
              isSelected: status == Boxes.alarm,
            ),
            SizedBox(height: 5),
            _CheckBox(
              onPressed: () => boxSelected(Boxes.notification),
              name: "Notification",
              isSelected: status == Boxes.notification,
            ),
            SizedBox(height: 5),
            _CheckBox(
              onPressed: () => boxSelected(Boxes.mute),
              name: "Mute",
              isSelected: status == Boxes.mute,
            ),
            SizedBox(height: 5),
            Divider(),
            TextButton(
              onPressed: () {},
              child: Center(
                child: const Text('DONE'),
              ),
            ),
          ],
        ),
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(22),
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
