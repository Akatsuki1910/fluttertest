import 'package:flutter/material.dart';

class ClockCenterCircle extends StatelessWidget {
  final double size;
  final Color color;

  const ClockCenterCircle({
    super.key,
    this.size = 30,
    this.color = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(
          color: Colors.black,
          width: size * 0.15,
        ),
        shape: BoxShape.circle,
      ),
    );
  }
}
