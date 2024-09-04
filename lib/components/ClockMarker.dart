import 'dart:math';

import 'package:flutter/material.dart';

class ClockMarker extends StatelessWidget {
  final int index;
  final int stops;
  final double radius;
  final double markerWidth;
  final double markerHeight;
  final Color markerColor;
  final double fontSize;
  final Color fontColor;
  final int representativeSplit;
  final int maxRepresentative;

  const ClockMarker({
    super.key,
    required this.index,
    this.stops = 60,
    required this.radius,
    required this.markerWidth,
    required this.markerHeight,
    this.markerColor = Colors.black54,
    required this.fontSize,
    this.fontColor = Colors.black,
    this.representativeSplit = 12,
    this.maxRepresentative = 12,
  })  : assert(maxRepresentative % representativeSplit == 0),
        assert(maxRepresentative >= representativeSplit),
        assert(stops % maxRepresentative == 0),
        assert(stops >= maxRepresentative);

  // マーカーではなく、数字として描画する部分かどうかの判別
  bool get isRepresentative => index % (stops / representativeSplit) == 0;
  // 代表数字のテキスト
  String get representativeText {
    final index = this.index == 0 ? stops : this.index;
    return (maxRepresentative * (index / stops)).toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        // 回転軸はContainerの中央にあるので、必ず回転してから移動
        ..rotateZ(2.0 * pi * (index / stops))
        // 0などintで渡してもdoubleに変換されずエラーが出るので注意
        ..translate(0.0, -radius),
      child: !isRepresentative
          ? Container(
              width: markerWidth,
              height: markerHeight,
              color: markerColor,
            )
          : Container(
              width: fontSize * 2,
              alignment: Alignment.center,
              // 数字が読めるように上記Transformの回転を相殺する
              transform: Matrix4.identity()
                ..rotateZ(-2.0 * pi * (index / stops)),
              transformAlignment: Alignment.center,
              child: Text(
                representativeText,
                style: TextStyle(
                  color: fontColor,
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
    );
  }
}
