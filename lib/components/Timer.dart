import 'dart:async';

import 'package:flutter/material.dart';

import './ConsolidatedClock.dart';

class TimerBuilder extends StatefulWidget {
  const TimerBuilder({super.key});

  @override
  _TimerBuilderState createState() => _TimerBuilderState();
}

class _TimerBuilderState extends State<TimerBuilder> {
  late DateTime _time;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _time = DateTime.now();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _time = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(_) {
    return ConsolidatedClock(time: _time);
  }
}
