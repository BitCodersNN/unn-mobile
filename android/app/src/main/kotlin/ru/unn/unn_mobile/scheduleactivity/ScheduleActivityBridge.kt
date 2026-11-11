// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

package ru.bitcodersnn.unnstudenthub.scheduleactivity

import android.Manifest
import android.app.Activity
import android.app.AlarmManager
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject

class ScheduleActivityBridge(private val activity: Activity, engine: FlutterEngine) {
    private var permissionResult: MethodChannel.Result? = null
    private val requestCode = 9402

    init {
        MethodChannel(engine.dartExecutor.binaryMessenger, "ru.bitcodersnn.unnstudenthub/schedule_activity")
            .setMethodCallHandler { call, result ->
                try {
                    handle(call, result)
                } catch (error: Exception) {
                    result.error("SCHEDULE_ACTIVITY_ERROR", error.javaClass.simpleName, null)
                }
            }
    }

    private fun handle(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "configure" -> {
                val value = requireNotNull(call.arguments as? String)
                JSONObject(value)
                activity.getSharedPreferences(ScheduleActivitySettings.PREFERENCES, Context.MODE_PRIVATE)
                    .edit().putString(ScheduleActivitySettings.SETTINGS, value).apply()
                ScheduleLiveUpdate.update(activity)
                result.success(null)
            }
            "status" -> {
                val supported = Build.VERSION.SDK_INT >= 36
                val manager = activity.getSystemService(NotificationManager::class.java)
                result.success(mapOf("supported" to supported,
                    "authorized" to (supported && manager.areNotificationsEnabled() && manager.canPostPromotedNotifications()),
                    "exactAlarms" to (Build.VERSION.SDK_INT < 31 || activity.getSystemService(AlarmManager::class.java).canScheduleExactAlarms())))
            }
            "requestPermission" -> {
                if (Build.VERSION.SDK_INT >= 36 && activity.checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED) {
                    if (permissionResult != null) { result.success(false); return }
                    permissionResult = result
                    activity.requestPermissions(arrayOf(Manifest.permission.POST_NOTIFICATIONS), requestCode)
                } else {
                    result.success(Build.VERSION.SDK_INT >= 36)
                }
            }
            "systemSettings", "exactAlarmSettings" -> {
                val intent = if (call.method == "exactAlarmSettings" && Build.VERSION.SDK_INT >= 31)
                    Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM, Uri.parse("package:${activity.packageName}"))
                else Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS).putExtra(Settings.EXTRA_APP_PACKAGE, activity.packageName)
                activity.startActivity(intent)
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    fun onRequestPermissionsResult(code: Int, grants: IntArray) {
        if (code != requestCode) return
        permissionResult?.success(grants.firstOrNull() == PackageManager.PERMISSION_GRANTED)
        permissionResult = null
        ScheduleLiveUpdate.update(activity)
    }
}
