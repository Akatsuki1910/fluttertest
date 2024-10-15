import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../components/sensors/snake.dart';

class SensorPage extends StatefulWidget {
  const SensorPage({super.key, this.title});

  final String? title;

  @override
  State<SensorPage> createState() => _SensorPageState();
}

String getNum(double? value) {
  return value?.toStringAsFixed(1) ?? '?';
}

String getMs(int? value) {
  return '${value?.toString() ?? '?'} ms';
}

void streamErrorHandler(BuildContext context, String errorText) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Sensor Not Found'),
        content: Text(errorText),
      );
    },
  );
}

int getInterval(DateTime? lastUpdate, DateTime now) {
  if (lastUpdate != null) {
    final interval = now.difference(lastUpdate);
    if (interval > const Duration(milliseconds: 20)) {
      return interval.inMilliseconds;
    }
  }

  return -1;
}

class _SensorPageState extends State<SensorPage> {
  static const int _snakeRows = 20;
  static const int _snakeColumns = 20;
  static const double _snakeCellSize = 10.0;

  UserAccelerometerEvent? _userAccelerometerEvent;
  AccelerometerEvent? _accelerometerEvent;
  GyroscopeEvent? _gyroscopeEvent;
  MagnetometerEvent? _magnetometerEvent;
  BarometerEvent? _barometerEvent;

  DateTime? _userAccelerometerUpdateTime;
  DateTime? _accelerometerUpdateTime;
  DateTime? _gyroscopeUpdateTime;
  DateTime? _magnetometerUpdateTime;
  DateTime? _barometerUpdateTime;

  int? _userAccelerometerLastInterval;
  int? _accelerometerLastInterval;
  int? _gyroscopeLastInterval;
  int? _magnetometerLastInterval;
  int? _barometerLastInterval;
  final _streamSubscriptions = <StreamSubscription<dynamic>>[];

  Duration sensorInterval = SensorInterval.normalInterval;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Center(
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(width: 1.0, color: Colors.black38),
              ),
              child: SizedBox(
                height: _snakeRows * _snakeCellSize,
                width: _snakeColumns * _snakeCellSize,
                child: Snake(
                  rows: _snakeRows,
                  columns: _snakeColumns,
                  cellSize: _snakeCellSize,
                ),
              ),
            ),
          ),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(4),
              4: FlexColumnWidth(2),
            },
            children: [
              const TableRow(
                children: [
                  SizedBox.shrink(),
                  Text('X'),
                  Text('Y'),
                  Text('Z'),
                  Text('Interval'),
                ],
              ),
              TableRow(
                children: [
                  const Text('UserAccelerometer'),
                  Text(getNum(_userAccelerometerEvent?.x)),
                  Text(getNum(_userAccelerometerEvent?.y)),
                  Text(getNum(_userAccelerometerEvent?.z)),
                  Text(getMs(_userAccelerometerLastInterval)),
                ],
              ),
              TableRow(
                children: [
                  const Text('Accelerometer'),
                  Text(getNum(_accelerometerEvent?.x)),
                  Text(getNum(_accelerometerEvent?.y)),
                  Text(getNum(_accelerometerEvent?.z)),
                  Text(getMs(_accelerometerLastInterval)),
                ],
              ),
              TableRow(
                children: [
                  const Text('Gyroscope'),
                  Text(getNum(_gyroscopeEvent?.x)),
                  Text(getNum(_gyroscopeEvent?.y)),
                  Text(getNum(_gyroscopeEvent?.z)),
                  Text(getMs(_gyroscopeLastInterval)),
                ],
              ),
              TableRow(
                children: [
                  const Text('Magnetometer'),
                  Text(getNum(_magnetometerEvent?.x)),
                  Text(getNum(_magnetometerEvent?.y)),
                  Text(getNum(_magnetometerEvent?.z)),
                  Text(getMs(_magnetometerLastInterval)),
                ],
              ),
            ],
          ),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(4),
              1: FlexColumnWidth(3),
              2: FlexColumnWidth(2),
            },
            children: [
              const TableRow(
                children: [
                  SizedBox.shrink(),
                  Text('Pressure'),
                  Text('Interval'),
                ],
              ),
              TableRow(
                children: [
                  const Text('Barometer'),
                  Text('${getNum(_barometerEvent?.pressure)} hPa'),
                  Text(getMs(_barometerLastInterval)),
                ],
              ),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Update Interval:'),
              SegmentedButton(
                segments: [
                  ButtonSegment(
                    value: SensorInterval.gameInterval,
                    label: Text('Game\n'
                        '(${SensorInterval.gameInterval.inMilliseconds}ms)'),
                  ),
                  ButtonSegment(
                    value: SensorInterval.uiInterval,
                    label: Text('UI\n'
                        '(${SensorInterval.uiInterval.inMilliseconds}ms)'),
                  ),
                  ButtonSegment(
                    value: SensorInterval.normalInterval,
                    label: Text('Normal\n'
                        '(${SensorInterval.normalInterval.inMilliseconds}ms)'),
                  ),
                  const ButtonSegment(
                    value: Duration(milliseconds: 500),
                    label: Text('500ms'),
                  ),
                  const ButtonSegment(
                    value: Duration(seconds: 1),
                    label: Text('1s'),
                  ),
                ],
                selected: {sensorInterval},
                showSelectedIcon: false,
                onSelectionChanged: (value) {
                  setState(() {
                    sensorInterval = value.first;
                    userAccelerometerEventStream(
                        samplingPeriod: sensorInterval);
                    accelerometerEventStream(samplingPeriod: sensorInterval);
                    gyroscopeEventStream(samplingPeriod: sensorInterval);
                    magnetometerEventStream(samplingPeriod: sensorInterval);
                    barometerEventStream(samplingPeriod: sensorInterval);
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }
  }

  @override
  void initState() {
    super.initState();
    _streamSubscriptions.add(
      userAccelerometerEventStream(samplingPeriod: sensorInterval).listen(
        (event) {
          final now = event.timestamp;
          setState(() {
            _userAccelerometerEvent = event;
            int interval = getInterval(_userAccelerometerUpdateTime, now);
            if (interval != -1) {
              _userAccelerometerLastInterval = interval;
            }
          });
          _userAccelerometerUpdateTime = now;
        },
        onError: (e) {
          showDialog(
              context: context,
              builder: (context) {
                return const AlertDialog(
                  title: Text('Sensor Not Found'),
                  content: Text(
                      "It seems that your device doesn't support User Accelerometer Sensor"),
                );
              });
        },
        cancelOnError: true,
      ),
    );
    _streamSubscriptions.add(
      accelerometerEventStream(samplingPeriod: sensorInterval).listen(
        (event) {
          final now = event.timestamp;
          setState(() {
            _accelerometerEvent = event;
            final interval = getInterval(_accelerometerUpdateTime, now);
            if (interval != -1) {
              _accelerometerLastInterval = interval;
            }
          });
          _accelerometerUpdateTime = now;
        },
        onError: (e) {
          if (!mounted) return;
          streamErrorHandler(context,
              "It seems that your device doesn't support Accelerometer Sensor");
        },
        cancelOnError: true,
      ),
    );
    _streamSubscriptions.add(
      gyroscopeEventStream(samplingPeriod: sensorInterval).listen(
        (event) {
          final now = event.timestamp;
          setState(() {
            _gyroscopeEvent = event;
            final interval = getInterval(_gyroscopeUpdateTime, now);
            if (interval != -1) {
              _gyroscopeLastInterval = interval;
            }
          });
          _gyroscopeUpdateTime = now;
        },
        onError: (e) {
          if (!mounted) return;
          streamErrorHandler(context,
              "It seems that your device doesn't support Gyroscope Sensor");
        },
        cancelOnError: true,
      ),
    );
    _streamSubscriptions.add(
      magnetometerEventStream(samplingPeriod: sensorInterval).listen(
        (event) {
          final now = event.timestamp;
          setState(() {
            _magnetometerEvent = event;
            final interval = getInterval(_magnetometerUpdateTime, now);
            if (interval != -1) {
              _magnetometerLastInterval = interval;
            }
          });
          _magnetometerUpdateTime = now;
        },
        onError: (e) {
          if (!mounted) return;
          streamErrorHandler(context,
              "It seems that your device doesn't support Magnetometer Sensor");
        },
        cancelOnError: true,
      ),
    );
    _streamSubscriptions.add(
      barometerEventStream(samplingPeriod: sensorInterval).listen(
        (event) {
          final now = event.timestamp;
          setState(() {
            _barometerEvent = event;
            final interval = getInterval(_barometerUpdateTime, now);
            if (interval != -1) {
              _barometerLastInterval = interval;
            }
          });
          _barometerUpdateTime = now;
        },
        onError: (e) {
          if (!mounted) return;
          streamErrorHandler(context,
              "It seems that your device doesn't support Barometer Sensor");
        },
        cancelOnError: true,
      ),
    );
  }
}
