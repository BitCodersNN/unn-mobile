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
    val coverage: List<Pair<Long, Long>>,
    val lessons: List<WidgetLesson>,
) {
    fun covers(start: Long, end: Long): Boolean =
        coverage.any { (weekStart, weekEnd) -> weekStart <= start && weekEnd >= end }

    companion object {
        const val PREFERENCES = "schedule_widget"
        const val DATA_KEY = "schedule_cache"
        const val PREVIOUS_DATA_KEY = "data"

        fun read(context: Context): ScheduleWidgetData? {
            val value = context.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE)
                .getString(DATA_KEY, null) ?: return null
            return runCatching { decode(value) }.getOrNull()
        }

        fun decode(value: String): ScheduleWidgetData? {
            val json = JSONObject(value)
            require(json.getInt("version") == 1)
            val entries = json.getJSONArray("entries")
            val configuration = json.optJSONObject("widget") ?: return null
            val coverage = mutableListOf<Pair<Long, Long>>()
            val lessons = mutableListOf<WidgetLesson>()
            for (index in 0 until entries.length()) {
                val entry = entries.getJSONObject(index)
                if (entry.getInt("ownerId") != configuration.getInt("ownerId") ||
                    entry.getString("type") != configuration.getString("type") ||
                    entry.getBoolean("useRasp") != configuration.getBoolean("useRasp") ||
                    !entry.isNull("id")) continue
                val week = entry.getJSONObject("schedule")
                coverage.add(week.getLong("start") to week.getLong("end"))
                val subjects = week.getJSONArray("subjects")
                for (subjectIndex in 0 until subjects.length()) {
                    val subject = subjects.getJSONObject(subjectIndex)
                    lessons.add(WidgetLesson(
                        title = subject.getString("name"),
                        type = subject.getString("type"),
                        location = listOf(subject.getString("auditorium"), subject.getString("building"))
                            .filter { it.isNotBlank() }.joinToString(" / "),
                        start = subject.getLong("start"),
                        end = subject.getLong("end"),
                    ))
                }
            }
            return ScheduleWidgetData(
                ownerLabel = configuration.getString("ownerLabel"),
                coverage = coverage,
                lessons = lessons.sortedBy { it.start },
            )
        }
    }
}
