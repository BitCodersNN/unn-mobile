// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

package ru.bitcodersnn.unnstudenthub.schedulewidget

import android.content.Context
import android.content.Intent
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class ScheduleWidgetBridge(private val context: Context, engine: FlutterEngine, initialIntent: Intent?) {
    private val channel = MethodChannel(engine.dartExecutor.binaryMessenger,
        "ru.bitcodersnn.unnstudenthub/schedule_widget")
    private var pendingLaunch: Boolean = initialIntent?.getBooleanExtra(ScheduleWidgetProvider.OPEN_SCHEDULE, false) == true

    init {
        channel.setMethodCallHandler { call, result ->
            try {
                handle(call, result)
            } catch (error: Exception) {
                result.error("SCHEDULE_WIDGET_ERROR", error.message, null)
            }
        }
    }

    private fun handle(call: MethodCall, result: MethodChannel.Result) {
        val preferences = context.getSharedPreferences(ScheduleWidgetData.PREFERENCES, Context.MODE_PRIVATE)
        when (call.method) {
            "readCache" -> result.success(preferences.getString(ScheduleWidgetData.DATA_KEY, null))
            "writeCache", "writeCacheOrder" -> {
                val value = requireNotNull(call.arguments as? String)
                ScheduleWidgetData.decode(value)
                check(preferences.edit().putString(ScheduleWidgetData.DATA_KEY, value)
                    .remove(ScheduleWidgetData.PREVIOUS_DATA_KEY).commit())
                if (call.method == "writeCache") ScheduleWidgetProvider.updateAll(context)
                result.success(null)
            }
            "consumeLaunch" -> {
                val value = pendingLaunch
                pendingLaunch = false
                result.success(value)
            }
            else -> result.notImplemented()
        }
    }

    fun onNewIntent(intent: Intent) {
        if (!intent.getBooleanExtra(ScheduleWidgetProvider.OPEN_SCHEDULE, false)) return
        channel.invokeMethod("openSchedule", null, object : MethodChannel.Result {
            override fun success(result: Any?) { pendingLaunch = false }
            override fun error(code: String, message: String?, details: Any?) { pendingLaunch = true }
            override fun notImplemented() { pendingLaunch = true }
        })
    }
}
