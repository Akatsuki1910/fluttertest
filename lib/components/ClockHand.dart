import 'package:flutter/material.dart';

class ClockHand extends StatelessWidget {
  final double angle;
  final double thickness;
  final double length;
  final Color color;
  final Color? shadowColor;

  const ClockHand({
    super.key,
    required this.angle,
    required this.thickness,
    required this.length,
    required this.color,
    this.shadowColor,
  });

  @override
  Widget build(BuildContext context) {
    return Transform(
      alignment: Alignment.bottomCenter,
      transform: Matrix4.identity()
        ..translate(0.0, -length / 2)
        ..rotateZ(angle),
      child: Container(
        width: thickness,
        height: length,
        decoration: BoxDecoration(
          color: color,
          boxShadow: [
            if (shadowColor != null)
              BoxShadow(
                color: shadowColor!,
                blurRadius: 12,
                spreadRadius: 1,
              )
          ],
          borderRadius: BorderRadius.circular(thickness),
        ),
      ),
    );
  }
}
