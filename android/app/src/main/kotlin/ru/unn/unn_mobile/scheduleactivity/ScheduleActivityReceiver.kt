// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 BitCodersNN

package ru.bitcodersnn.unnstudenthub.scheduleactivity

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class ScheduleActivityReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == ScheduleLiveUpdate.DISMISS) {
            intent.getStringExtra(ScheduleLiveUpdate.LESSON_ID)?.let { ScheduleLiveUpdate.dismiss(context, it) }
        } else {
            ScheduleLiveUpdate.update(context)
        }
    }
}
