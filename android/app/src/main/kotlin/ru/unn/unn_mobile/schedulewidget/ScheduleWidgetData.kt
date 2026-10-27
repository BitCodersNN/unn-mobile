// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

package ru.bitcodersnn.unnstudenthub.schedulewidget

import android.content.Context
import org.json.JSONObject

data class WidgetLesson(
    val title: String,
    val type: String,
    val location: String,
    val start: Long,
    val end: Long,
)

data class ScheduleWidgetData(
    val ownerLabel: String,
    val validFrom: Long,
    val validUntil: Long,
    val lessons: List<WidgetLesson>,
) {
    companion object {
        const val PREFERENCES = "schedule_widget"
        const val DATA_KEY = "data"

        fun read(context: Context): ScheduleWidgetData? {
            val value = context.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE)
                .getString(DATA_KEY, null) ?: return null
            return runCatching { decode(value) }.getOrNull()
        }

        fun decode(value: String): ScheduleWidgetData {
            val json = JSONObject(value)
            require(json.getInt("version") == 1)
            val lessons = json.getJSONArray("lessons")
            return ScheduleWidgetData(
                ownerLabel = json.getString("ownerLabel"),
                validFrom = json.getLong("validFrom"),
                validUntil = json.getLong("validUntil"),
                lessons = List(lessons.length()) { index ->
                    val lesson = lessons.getJSONObject(index)
                    WidgetLesson(
                        title = lesson.getString("title"),
                        type = lesson.getString("type"),
                        location = lesson.getString("location"),
                        start = lesson.getLong("start"),
                        end = lesson.getLong("end"),
                    )
                }.sortedBy { it.start },
            )
        }
    }
}
