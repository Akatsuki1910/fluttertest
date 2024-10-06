import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BattelyPage extends StatefulWidget {
  const BattelyPage({super.key});

  @override
  State<BattelyPage> createState() => _BattelyPageState();
}

class _BattelyPageState extends State<BattelyPage> {
  /* @POINT1 : メソッドチャンネルを作成 */
  static const batteryChannel =
      MethodChannel('com.example.fluttertest/battery');
  // バッテリーの残量
  String batteryLevel = 'Waiting...';
  String message = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[Text(batteryLevel), Text(message)])),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await getBatteryInfo(); // バッテリー情報を取得
        },
        tooltip: 'Get Battery Level',
        child: const Icon(Icons.battery_full),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future getBatteryInfo() async {
    String devName = 'Not...';
    int level = 0;
    String devMessage = 'ERROR';

    try {
      /* @POINT2 : パラメータを作成して、プラットフォームの関数呼び出し */
      final arguments = {
        'text': 'Flutter',
        'num': 5,
      };
      final res =
          await batteryChannel.invokeMethod('getBatteryInfo', arguments);

      /* @POINT3 : プラットフォームからの結果を解析取得 */
      devName = res['device'];
      level = res['level'];
      devMessage = res['message'];
    } on PlatformException catch (e) {
      batteryLevel = "Failed to get battery level: '${e.message}'.";
    }

    // 画面を再描画する
    setState(() {
      batteryLevel = '$devName:$level%';
      message = devMessage;
    });
  }
}
