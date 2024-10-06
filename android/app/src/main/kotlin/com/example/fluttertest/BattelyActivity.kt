package com.example.fluttertest

import android.content.Context
import android.os.BatteryManager
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import android.util.Log
import android.widget.Toast

class BatteryActivity(private val context: Context, flutterEngine: FlutterEngine) {

    init {
        Log.d("BatteryActivity", "BatteryActivity initialized")
        Toast.makeText(context, "BatteryActivity initialized", Toast.LENGTH_SHORT).show()

        // チャンネル名をアプリケーションに基づく一意な名前に変更
        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.example.fluttertest/battery")
        channel.setMethodCallHandler { call, result ->
            
            if (call.method == "getBatteryInfo") {

                // Flutterから渡されたデータを取得
                val text = call.argument<String>("text") ?: "Not Message..."
                val num = call.argument<Int>("num") ?: 0
                val message = makeMessage(text, num)

                // バッテリー残量を取得
                val level = getBatteryLevel()

                // Flutterへ返す情報を作成
                val res = mapOf(
                    "device" to "Android",
                    "level" to level,
                    "message" to message,
                )
                result.success(res)

            } else {
                result.notImplemented()
            }
        }
    }

    // メッセージ作成
    private fun makeMessage(text: String, num: Int): String {
        val mark = "-"
        var message = ""
        for (i in 1..num) {
            message += mark
        }
        message += text
        for (i in 1..num) {
            message += mark
        }
        return message
    }

    // バッテリー残量を取得
    private fun getBatteryLevel(): Int {
        // バッテリーサービスからバッテリーの状態を取得
        val manager = context.getSystemService(Context.BATTERY_SERVICE) as BatteryManager
        val batteryLevel: Int = manager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
        return batteryLevel
    }
}
