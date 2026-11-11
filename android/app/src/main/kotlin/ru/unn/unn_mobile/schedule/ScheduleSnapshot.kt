// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

package ru.bitcodersnn.unnstudenthub.schedule

import org.json.JSONObject

data class ScheduleSnapshot(
    val ownerLabel: String,
    val validFrom: Long,
    val validUntil: Long,
    val lessons: List<ScheduleLesson>,
) {
    companion object {
        const val SCHEMA_VERSION = 2

        fun decode(value: String): ScheduleSnapshot {
            val json = JSONObject(value)
            require(json.getInt("version") == SCHEMA_VERSION)
            val lessons = json.getJSONArray("lessons")
            return ScheduleSnapshot(
                ownerLabel = json.getString("ownerLabel"),
                validFrom = json.getLong("validFrom"),
                validUntil = json.getLong("validUntil"),
                lessons = List(lessons.length()) { index ->
                    val lesson = lessons.getJSONObject(index)
                    ScheduleLesson(
                        title = lesson.getString("title"),
                        type = lesson.getString("type"),
                        location = lesson.getString("location"),
                        start = lesson.getLong("start"),
                        end = lesson.getLong("end"),
                        accentColor = if (lesson.isNull("accentColor")) null
                            else lesson.getLong("accentColor").toInt(),
                        lecturer = lesson.optString("lecturer", ""),
                    )
                }.sortedBy { it.start },
            )
        }
    }
}
