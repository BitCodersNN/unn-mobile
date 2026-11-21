// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

package ru.bitcodersnn.unnstudenthub.schedule

import org.json.JSONArray
import org.json.JSONObject
import java.util.Calendar

data class ScheduleSnapshot(
    val ownerLabel: String,
    val validFrom: Long,
    val validUntil: Long,
    val lessons: List<ScheduleLesson>,
)

internal class ScheduleCache private constructor(
    private val widget: JSONObject?,
    private val entries: JSONArray,
    private val subjectColors: JSONObject?,
) {
    fun snapshot(now: Long = System.currentTimeMillis()): ScheduleSnapshot? {
        val configuration = widget ?: return null
        val start = ScheduleTime.dayStart(now).apply {
            val daysSinceMonday = (get(Calendar.DAY_OF_WEEK) + 5) % 7
            add(Calendar.DAY_OF_MONTH, -daysSinceMonday)
        }
        val from = start.timeInMillis
        val until = start.apply { add(Calendar.DAY_OF_MONTH, 14) }.timeInMillis
        val weeks = (0 until entries.length()).mapNotNull { index ->
            val entry = entries.getJSONObject(index)
            if (entry.getInt("ownerId") != configuration.getInt("ownerId") ||
                entry.getString("type") != configuration.getString("type") ||
                entry.getBoolean("useRasp") != configuration.getBoolean("useRasp") ||
                !entry.isNull("id")
            ) return@mapNotNull null
            entry.getJSONObject("schedule").takeIf {
                it.getLong("start") >= from && it.getLong("end") <= until
            }
        }.sortedBy { it.getLong("start") }
        if (weeks.isEmpty()) return null
        return ScheduleSnapshot(
            ownerLabel = configuration.getString("ownerLabel"),
            validFrom = weeks.first().getLong("start"),
            validUntil = weeks.last().getLong("end"),
            lessons = weeks.flatMap { week ->
                val subjects = week.getJSONArray("subjects")
                List(subjects.length()) { index ->
                    val subject = subjects.getJSONObject(index)
                    val type = subject.getString("type")
                    ScheduleLesson(
                        title = subject.getString("name"),
                        type = type,
                        location = listOf(subject.getString("auditorium"), subject.getString("building"))
                            .filter { it.isNotBlank() }.joinToString(" / "),
                        start = subject.getLong("start"),
                        end = subject.getLong("end"),
                        accentColor = subjectColors?.takeIf { it.has(type) }?.getLong(type)?.toInt(),
                        lecturer = subject.getString("lecturer"),
                    )
                }
            }.sortedBy { it.start },
        )
    }

    companion object {
        fun decode(value: String): ScheduleCache {
            val json = JSONObject(value)
            require(json.getInt("version") == 1)
            return ScheduleCache(json.optJSONObject("widget"), json.getJSONArray("entries"), json.optJSONObject("subjectColors"))
        }
    }
}
