import 'package:flutter/material.dart';
import 'package:fluttertest/components/TimeContainer.dart';

class DigitalClockRenderer extends StatelessWidget {
  final DateTime time;
  final double digitWidth;
  final TextStyle? style;

  const DigitalClockRenderer({
    super.key,
    required this.time,
    this.digitWidth = 12.0,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TimeContainer(
              time: time.hour,
              digits: 2,
              digitWidth: digitWidth,
              suffix: ':',
              style: style,
            ),
            TimeContainer(
              time: time.minute,
              digits: 2,
              digitWidth: digitWidth,
              suffix: ':',
              style: style,
            ),
            TimeContainer(
              time: time.second,
              digits: 2,
              digitWidth: digitWidth,
              style: style,
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TimeContainer(
              time: time.millisecond,
              digits: 3,
              digitWidth: digitWidth,
              style: style,
            ),
          ],
        ),
      ],
    );
  }
}
