import 'package:flutter/material.dart';
import 'package:fluttertest/components/Ticker.dart';
import 'package:fluttertest/components/Timer.dart';

class ClockPage extends StatefulWidget {
  const ClockPage({super.key});

  @override
  _ClockPageState createState() => _ClockPageState();
}

class _ClockPageState extends State<ClockPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          children: [
            Expanded(
                child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Column(children: [
                      Text('Timer-driven Clock'),
                      Expanded(
                        child: TimerBuilder(),
                      )
                    ]))),
            Divider(thickness: 6),
            Expanded(
                child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Column(children: [
                      Text('Ticker-driven Clock'),
                      Expanded(
                        flex: 9,
                        child: TickerBuilder(),
                      ),
                    ]))),
          ],
        ),
      ),
    );
  }
}
