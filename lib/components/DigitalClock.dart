import 'package:flutter/material.dart';

timeText(time, digits) {
  return time.toString().padLeft(digits, '0');
}

const digitWidth = 12.0;

const style = TextStyle(
  fontSize: 18,
  color: Colors.red,
  fontWeight: FontWeight.bold,
);

class DigitalClockRenderer extends StatelessWidget {
  final DateTime time;

  const DigitalClockRenderer({
    super.key,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          timeText(time.hour, 2) +
              ':' +
              timeText(time.minute, 2) +
              ':' +
              timeText(time.second, 2),
          style: style,
        ),
        Text(
          timeText(time.millisecond, 3),
          style: style,
        ),
      ],
    );
  }
}
