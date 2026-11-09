// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

package ru.bitcodersnn.unnstudenthub.schedulewidget

import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date
import java.util.Locale
import java.util.TimeZone

internal object ScheduleWidgetTime {
    fun dayStart(time: Long): Calendar =
        Calendar.getInstance(TimeZone.getTimeZone(ScheduleWidgetData.TIME_ZONE)).apply {
            timeInMillis = time
            set(Calendar.HOUR_OF_DAY, 0)
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
        }

    fun format(time: Long, pattern: String): String =
        SimpleDateFormat(pattern, Locale.forLanguageTag("ru")).apply {
            timeZone = TimeZone.getTimeZone(ScheduleWidgetData.TIME_ZONE)
        }.format(Date(time))
}
