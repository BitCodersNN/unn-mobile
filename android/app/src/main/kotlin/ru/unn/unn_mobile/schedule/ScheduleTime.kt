// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

package ru.bitcodersnn.unnstudenthub.schedule

import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date
import java.util.Locale
import java.util.TimeZone

internal object ScheduleTime {
    private const val TIME_ZONE = "Europe/Moscow"

    fun dayStart(time: Long): Calendar =
        Calendar.getInstance(TimeZone.getTimeZone(TIME_ZONE)).apply {
            timeInMillis = time
            set(Calendar.HOUR_OF_DAY, 0)
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
        }

    fun format(time: Long, pattern: String): String =
        SimpleDateFormat(pattern, Locale.forLanguageTag("ru")).apply {
            timeZone = TimeZone.getTimeZone(TIME_ZONE)
        }.format(Date(time))
}
