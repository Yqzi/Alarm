import 'package:flutter/material.dart';

void main() {
  runApp(const Alarm());
}

class Alarm extends StatefulWidget {
  const Alarm({super.key});

  @override
  State<Alarm> createState() => _AlarmState();
}

class _AlarmState extends State<Alarm> {
  // This widget is the root of your application.
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
            Row(
              children: [
                Container(
                  decoration:
                      BoxDecoration(border: Border.all(color: Colors.black)),
                  width: MediaQuery.of(context).size.width / 2,
                  child: const Center(child: Text("PLACE HOLDER")),
                ),
                Container(
                  decoration:
                      BoxDecoration(border: Border.all(color: Colors.black)),
                  width: MediaQuery.of(context).size.width / 2,
                  child: const Center(child: Text("PLACE HOLDER 2")),
                ),
              ],
            ),
            SafeArea(
              child: Container(
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.black)),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height - 200,
                child: const Center(child: Text("PLACE HOLDER")),
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
