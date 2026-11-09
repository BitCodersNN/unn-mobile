// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

package ru.bitcodersnn.unnstudenthub.schedulewidget

import android.content.Context
import android.content.Intent
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import ru.bitcodersnn.unnstudenthub.schedule.ScheduleNavigation
import ru.bitcodersnn.unnstudenthub.schedule.ScheduleSnapshotProvider
import ru.bitcodersnn.unnstudenthub.scheduleactivity.ScheduleLiveUpdate

class ScheduleWidgetBridge(private val context: Context, engine: FlutterEngine, initialIntent: Intent?) {
    private val channel = MethodChannel(engine.dartExecutor.binaryMessenger,
        "ru.bitcodersnn.unnstudenthub/schedule_widget")
    private var pendingLaunch: Boolean = ScheduleNavigation.isScheduleIntent(initialIntent)

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
        val provider = ScheduleSnapshotProvider(context)
        when (call.method) {
            "read" -> result.success(provider.readJson())
            "write" -> {
                val value = requireNotNull(call.arguments as? String)
                provider.writeJson(value)
                ScheduleWidgetProvider.updateAll(context)
                ScheduleLiveUpdate.update(context)
                result.success(null)
            }
            "clear" -> {
                provider.clear()
                ScheduleWidgetProvider.updateAll(context)
                ScheduleLiveUpdate.clear(context)
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
        if (!ScheduleNavigation.isScheduleIntent(intent)) return
        channel.invokeMethod("openSchedule", null, object : MethodChannel.Result {
            override fun success(result: Any?) { pendingLaunch = false }
            override fun error(code: String, message: String?, details: Any?) { pendingLaunch = true }
            override fun notImplemented() { pendingLaunch = true }
        })
    }
}
