// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

package ru.bitcodersnn.unnstudenthub.schedule

data class ScheduleLesson(
    val title: String,
    val type: String,
    val location: String,
    val start: Long,
    val end: Long,
    val accentColor: Int? = null,
    val lecturer: String = "",
) {
    val identifier: String get() = "$start|$end|$title|$location"
}
