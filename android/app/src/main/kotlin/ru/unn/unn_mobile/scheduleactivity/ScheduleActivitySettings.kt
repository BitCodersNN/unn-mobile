// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

package ru.bitcodersnn.unnstudenthub.scheduleactivity

import android.content.Context
import org.json.JSONObject

internal data class ScheduleActivitySettings(
    val mode: String,
    val beforeMillis: Long,
    val initialMillis: Long,
) {
    companion object {
        const val PREFERENCES = "schedule_activity"
        const val SETTINGS = "settings"
        const val DISMISSED = "dismissed"

        fun read(context: Context): ScheduleActivitySettings {
            val json = context.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE)
                .getString(SETTINGS, null)?.let { runCatching { JSONObject(it) }.getOrNull() }
            fun minutes(key: String): Long {
                val value = json?.optInt(key, 10) ?: 10
                return (if (value in 0..60) value else 10) * 60_000L
            }
            return ScheduleActivitySettings(
                json?.optString("mode", "disabled") ?: "disabled",
                minutes("beforeMinutes"), minutes("initialMinutes"),
            )
        }
    }
}
