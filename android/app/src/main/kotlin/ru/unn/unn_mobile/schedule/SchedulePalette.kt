// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

package ru.bitcodersnn.unnstudenthub.schedule

import android.content.Context
import ru.bitcodersnn.unnstudenthub.R

internal object SchedulePalette {
    fun lessonAccent(context: Context, lesson: ScheduleLesson): Int =
        lesson.accentColor ?: context.getColor(R.color.schedule_accent)
}
