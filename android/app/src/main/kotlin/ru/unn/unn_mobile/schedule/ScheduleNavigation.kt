// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

package ru.bitcodersnn.unnstudenthub.schedule

import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import ru.bitcodersnn.unnstudenthub.MainActivity

internal object ScheduleNavigation {
    private const val OPEN_SCHEDULE = "open_schedule_widget"

    fun isScheduleIntent(intent: Intent?): Boolean =
        intent?.getBooleanExtra(OPEN_SCHEDULE, false) == true

    fun pendingIntent(context: Context): PendingIntent {
        val intent = Intent(context, MainActivity::class.java).apply {
            action = OPEN_SCHEDULE
            putExtra(OPEN_SCHEDULE, true)
            addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP)
        }
        return PendingIntent.getActivity(context, 0, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
    }
}
