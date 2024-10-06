package com.example.fluttertest

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // BatteryActivity を初期化し、FlutterEngineを渡す
        BatteryActivity(this, flutterEngine)
    }
}
