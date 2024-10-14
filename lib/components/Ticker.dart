import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import './ConsolidatedClock.dart';

class TickerBuilder extends StatefulWidget {
  const TickerBuilder({super.key});

  @override
  _TickerBuilderState createState() => _TickerBuilderState();
}

class _TickerBuilderState extends State<TickerBuilder>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  late DateTime _time;

  @override
  void initState() {
    super.initState();
    _time = DateTime.now();
    _ticker = createTicker((_) {
      setState(() {
        _time = DateTime.now();
      });
    });
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(_) {
    return ConsolidatedClock(time: _time);
  }
}
