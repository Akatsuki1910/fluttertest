import 'package:flutter/material.dart';

class TimeContainer extends StatelessWidget {
  final int time;
  final int digits;
  final double digitWidth;
  final String? suffix;
  final TextStyle? style;

  const TimeContainer({
    super.key,
    required this.time,
    required this.digits,
    this.digitWidth = 12.0,
    this.suffix,
    this.style,
  });

  String get timeText => time.toString().padLeft(digits, '0');

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < digits; i++) ...[
          Container(
            alignment: Alignment.center,
            width: digitWidth,
            child: Text(
              timeText[i],
              style: style,
            ),
          ),
          if (i == digits - 1)
            Container(
              alignment: Alignment.center,
              child: Text(
                suffix ?? '',
                style: style,
              ),
            ),
        ],
      ],
    );
  }
}
