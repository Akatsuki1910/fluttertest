import 'package:flutter/material.dart';
import 'package:fluttertest/components/AnalogClock.dart';
import 'package:fluttertest/components/DigitalClock.dart';

class ConsolidatedClock extends StatelessWidget {
  final DateTime time;

  const ConsolidatedClock({super.key, required this.time});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // horizontalは真ん中に配置、verticalは上から120に配置
        Positioned.fill(
          top: 120,
          child: DigitalClockRenderer(
            time: time,
            digitWidth: 12,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // 真ん中に配置
        Positioned.fill(
          child: AnalogClockRenderer(time: time),
        ),
      ],
    );
  }
}